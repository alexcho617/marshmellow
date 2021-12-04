// ignore_for_file: unused_field

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marshmallow/models/user.dart';
import 'package:marshmallow/screens/setting/setting.dart';
import 'package:marshmallow/services/firebase.dart';
import 'package:marshmallow/utils/colors.dart';
import 'package:marshmallow/utils/text.dart';
import 'package:marshmallow/widgets/button.dart';
import 'package:image_picker/image_picker.dart';
import 'package:marshmallow/services/model.dart';
import 'package:tflite/tflite.dart';

var _getArguments = Get.arguments;
String _code = _getArguments[0];
GameUser _currentPlayer = _getArguments[1];

class GameZone extends StatefulWidget {
  GameZone({Key? key}) : super(key: key);

  @override
  _GameZoneState createState() => _GameZoneState();
}

class _GameZoneState extends State<GameZone> {
  final player = AudioCache();
  late Future<String> uid;
  final _auth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;
  bool _isHost = false;
  late bool _userLoaded;
  XFile? pickedImage;
  List? _result = [];
  String _name = "";

  @override
  void initState() {
    super.initState();
    checkFirebaseUser();
    loadMyModel();
    _printInfo();
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
      appBar: AppBar(
        backgroundColor: backgroundBlue,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [point2style(data: 'GAMEZONE')]),
      ),
      drawer: PlayerDrawer(code: _code),
      body: SafeArea(
        child: Container(
          color: backgroundBlue,
          height: 800,
          //MAIN STREAM
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
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 35),
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
                            //TODO HOST CHECKING
                            SkipButton(gameData['currentRound']),
                          ],
                        ),
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            point2style(data: 'ROUND '),
                            point2style(
                                data: gameData['currentRound'].toString())
                          ]),
                      //RECORDS STREAM
                      SizedBox(
                        height: size.height * 0.62,
                        child: RecordStream(code: _code, name: _name),
                      ),
                      bigButtonTheme('📷 사진 업로드', () {
                        getImageFromGallery(
                            gameData['keywords'][gameData['currentRound'] - 1]);
                      }),
                    ],
                  );
                } on Exception catch (e) {
                  return Center(
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
    player.play('sounds/$filename');
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

  Future<void> _setFirebaseRound(_roundNumber) async {
    print('setFirebaseROund CALLED');
    await firestore
        .collection('GameRooms')
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        _roundNumber = doc["currentRound"];

        print('roundNumber INITIATE:$_roundNumber');
      });
    });
  }
}

class PlayerDrawer extends StatelessWidget {
  List<GameUser> allPlayersInfoList = [];
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
                    child: ListView.builder(
                        itemCount: userList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Column(
                            children: [
                              // Text(_code),
                              Row(
                                children: [
                                  Text(userList[index].id.toString()),
                                  Text(userList[index].avatarIndex.toString()),
                                ],
                              )
                            ],
                          );
                        }),
                  );
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
              return Container(
                margin: EdgeInsets.all(4),
                height: 60,
                child: ListTile(
                  title: Text(data['record']),
                  subtitle: (Text('${data['type']}-${data['time']}')),
                ),
              );
            }).toList(),
          );
        } on Exception catch (e) {
          return Text(' ');
        }
      },
    );
  }
}
