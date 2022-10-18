// ignore_for_file: unused_field

import 'package:audioplayers/audioplayers.dart';

import 'package/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marshmallow/models/user.dart';
import 'package:marshmallow/screens/result/result.dart';
import 'package:marshmallow/screens/setting/setting.dart';
import 'package:marshmallow/services/firebase.dart';
import 'package:marshmallow/utils/colors.dart';
import 'package:marshmallow/utils/text.dart';
import 'package:marshmallow/utils/utils.dart';
import 'package:marshmallow/widgets/button.dart';
import 'package:image_picker/image_picker.dart';
import 'package:marshmallow/services/models.dart';
import 'package:tflite/tflite.dart';

enum GameStatus { go, stop }
var _getArguments = Get.arguments;
String _code = _getArguments[0];
GameUser _currentPlayer = _getArguments[1];

class GameZone extends StatefulWidget {
  GameZone({Key? key}) : super(key: key);

  @override
  _GameZoneState createState() => _GameZoneState();
}

class _GameZoneState extends State<GameZone> {
  GameStatus currentGameStatus = GameStatus.go;
  // final player = AudioCache();
  final player = AudioPlayer();
  late Future<String> uid;
  final _auth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;
  bool _isHost = false;
  late bool _userLoaded;
  XFile? pickedImage;
  List? _result = [];
  String _name = "";
  static List<GameUser> globalAllPlayersInfoList = [];

  @override
  void initState() {
    super.initState();
    checkFirebaseUser();
    loadModel(0);
    _printInfo();
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // List<GameUser> allPlayersInfoList = [];
    // List<String> allPlayersUID = [];

    var scaffoldKey = GlobalKey<ScaffoldState>();
    var size = MediaQuery.of(context).size;
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: backgroundBlue,
      drawer: PlayerDrawer(code: _code),
      body: SafeArea(
        child: Container(
          color: backgroundBlue,
          height: 800,
          //MAIN STREAM
          // child: currentGameStatus == GameStatus.stop
          //     ? Text("GAME OVER")
          //     : StreamBuilder<DocumentSnapshot>(
          child: StreamBuilder<DocumentSnapshot>(
              stream: firestore.collection('GameRooms').doc(_code).snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Something went wrong');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: Text(" "));
                }
                try {
                  dynamic gameDoc = snapshot.data;

                  Map<String, dynamic> gameData = gameDoc != null
                      ? gameDoc.data() as Map<String, dynamic>
                      : Map();

                  //Navigate Players Subscribed to Firebase to Result Screen
                  if (gameData['isOver'] == false) {
                    //call ending sequence
                    // setState(() {
                    // });
                    // currentGameStatus = GameStatus.go;

                    return Column(
                      children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              point2style(data: 'ROUND '),
                              point2style(
                                  data: gameData['currentRound'].toString())
                            ]),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 35),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                alignment: Alignment.topLeft,
                                width: 66,
                                child: IconButton(
                                  onPressed: () async {
                                    scaffoldKey.currentState!.openDrawer();
                                  },
                                  icon: Icon(Icons.menu),
                                ),
                              ),
                              Container(
                                width: 150,
                                height: 40,
                                alignment: Alignment.center,
                                decoration: new BoxDecoration(
                                  color: pink,
                                  border: Border.all(color: darkGrey),
                                ),
                                child: Text(
                                    gameData['keywords']
                                        [gameData['currentRound'] - 1],
                                    style: head1style()),
                              ),
                              if (_isHost)
                                if (gameData['currentRound'] < 10)
                                  SkipButton(gameData['currentRound'])
                                else
                                  EndButton()
                              else
                                SizedBox(width: 66)
                            ],
                          ),
                        ),

                        //RECORDS STREAM
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: size.width * 0.1),
                          child: SizedBox(
                            height: size.height * 0.63,
                            child: RecordStream(code: _code, name: _name),
                          ),
                        ),
                        Spacer(),
                        bigButtonTheme('📷 사진 업로드', () {
                          getImageFromGallery(gameData['keywords']
                              [gameData['currentRound'] - 1]);
                        }),
                      ],
                    );
                  } else {
                    // return Center(child: Text(gameData['players'][0]));
                    return ResultPage(
                      currentPlayerUIDS: gameData['players'],
                      currentPlayer: _currentPlayer,
                    );
                  }
                } on Exception catch (e) {
                  throw Center(
                    child: Text(' '),
                  );
                }
              }),
        ),
      ),
    );
  }

  _printInfo() {
    if (_currentPlayer.type == UserType.host) {
      setState(() {
        _isHost = true;
      });
    }
    print('Host?: $_isHost');

    printUserData();
  }

  void printUserData() {
    print('currentPlayer_uid: ${_currentPlayer.uid}');
    print('currentPlayer_id: ${_currentPlayer.id}');
    print('currentPlayer_type: ${_currentPlayer.type}');
    print('currentPlayer_avatarIndex: ${_currentPlayer.avatarIndex}');
    print('currentPlayer_localToken: ${_currentPlayer.localToken}');
    print('currentPlayer_globalToken: ${_currentPlayer.globalToken}');
  }

  void playSound(String filename) {
    player.play(UrlSource('sounds/$filename'));
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    Get.offAll(WelcomePage());
  }

  Widget SkipButton(int currentRound) {
    return Container(
      width: 66,
      height: 24,
      child: OutlinedButton(
        child: Text('Skip', style: body4style()),
        style: OutlinedButton.styleFrom(
          backgroundColor: blue,
          side: BorderSide(color: darkGrey),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: () async {
          playSound('metalClick.wav');
          // playSound('note1.wav');

          if (currentRound < 10) {
            //MAKE SOUND metalClick.ogg
            await firestoreIncreaseRound(_code);
          } else {
            //TODO GO TO RESULT
          }
        },
      ),
    );
  }

  Widget EndButton() {
    return Container(
      width: 66,
      height: 24,
      child: OutlinedButton(
        child: Text('End', style: body4style()),
        style: OutlinedButton.styleFrom(
          backgroundColor: blue,
          side: BorderSide(color: darkGrey),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: () async {
          //different ending sound
          playSound('metalClick.wav');
          // Get.off(ResultPage(),arguments: currentPlayersUID);
          //set isOver to true
          await firestoreSetRoundOver(_code); //make
        },
      ),
    );
  }

  Future getImageFromGallery(String currentKey) async {
    var tempStore = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (tempStore != null) {
      setState(() {
        pickedImage = XFile(tempStore.path);
      });
      await applyModelOnImage(pickedImage);
      //call resultfunction
      // print('$currentKey, $_name');
      handleResult(
          currentKey, _name, _code, _currentPlayer.id, _currentPlayer.uid);
    } else {
      return 0;
    }
  }

  applyModelOnImage(XFile? file) async {
    var res = await Tflite.runModelOnImage(
        path: file!.path,
        numResults: 2,
        threshold: 0.5,
        imageMean: 127.5,
        imageStd: 127.5);
    setState(() {
      _result = res;
      print(_result);

      String str = _result![0]["label"].toString();
      _name = str;
    });
  }

  // Future<void> _setFirebaseRound(_roundNumber) async {
  //   print('setFirebaseROund CALLED');
  //   await firestore
  //       .collection('GameRooms')
  //       .get()
  //       .then((QuerySnapshot querySnapshot) {
  //     querySnapshot.docs.forEach((doc) {
  //       _roundNumber = doc["currentRound"];

  //       print('roundNumber INITIATE:$_roundNumber');
  //     });
  //   });
  // }
}

class PlayerDrawer extends StatelessWidget {
  PlayerDrawer({required this.code});
  String code;

  @override
  Widget build(BuildContext context) {
    print('drawer build called');
    // allPlayersUID = [];
    // allPlayersInfoList = [];
    return StreamBuilder<DocumentSnapshot>(
      stream: firestore.collection('GameRooms').doc(_code).snapshots(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          return Drawer(child: Text('Something went wrong'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Drawer(child: CircularProgressIndicator());
        }
        try {
          // print('try catch');
          dynamic gameDoc = snapshot.data;
          Map<String, dynamic> gameData =
              gameDoc != null ? gameDoc.data() as Map<String, dynamic> : Map();

          return FutureBuilder<List<GameUser>>(
              future: getFutureFirebaseAllUsersData(gameData['players']),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasData == false) {
                  return Drawer(
                      child: Center(child: CircularProgressIndicator()));
                } else if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Drawer(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                  );
                } else {
                  List<GameUser> userList = snapshot.data;
                  return Drawer(
                      child: ListView(padding: EdgeInsets.zero, children: [
                    DrawerHeader(
                        padding: EdgeInsets.only(left: 30, bottom: 20),
                        decoration: BoxDecoration(
                          color: blue,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.asset('assets/m.png', width: 30),
                            SizedBox(height: 10),
                            Text('참여코드', style: body2style()),
                            SizedBox(height: 10),
                            Text(code, style: head1style()),
                          ],
                        )),
                    SizedBox(height: 10),
                    ListView.separated(
                        separatorBuilder: (BuildContext context, int index) =>
                            const Divider(),
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        padding: EdgeInsets.all(8),
                        itemCount: userList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
                            padding: EdgeInsets.only(left: 30),
                            height: 40,
                            child: Row(
                              children: [
                                Image.asset(
                                    avatarRepository[
                                        userList[index].avatarIndex],
                                    height: 25),
                                SizedBox(width: 20),
                                Text(
                                  userList[index].id.toString(),
                                  style: body5style(),
                                ),
                              ],
                            ),
                          );
                        }),
                  ]));
                }
              });
        } on Exception catch (e) {
          return Drawer(child: Text('Try Catch Err'));
        }
      },
    );
  }
}

class RecordStream extends StatelessWidget {
  RecordStream({required this.code, required this.name});
  String code;
  String name;
  final player = AudioCache();
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: firestore
          .collection('GameRooms')
          .doc(code)
          .collection('Records')
          .orderBy('time')
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: Text(" "));
        }

        try {
          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data()! as Map<String, dynamic>;
              //per document
              if (data['type'] == 'success') {
                //성공했을 때

                return Container(
                  height: 99,
                  margin: EdgeInsets.only(top: 40),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: darkGrey.withOpacity(0.1),
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.all(Radius.circular(15))),
                  child: ListTile(
                    title: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Image.asset(
                        'assets/m.png',
                        width: 22,
                        height: 17,
                      ),
                    ),
                    subtitle: Text(
                      data['record'],
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              } else {
                //실패했을 때
                return Container(
                  margin: EdgeInsets.only(bottom: 30),
                  height: 20,
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    subtitle: Text(data['record'],
                        textAlign: TextAlign.center, style: body4style()),
                  ),
                );
              }
            }).toList(),
          );
        } on Exception catch (e) {
          return Text(' ');
        }
      },
    );
  }
}
