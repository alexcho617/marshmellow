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
import 'package:marshmallow/services/models.dart';
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
  static List<GameUser> globalAllPlayersInfoList = [];

  @override
  void initState() {
    super.initState();
    checkFirebaseUser();
    loadMyModel();
    _printInfo();
  }

  @override
  Widget build(BuildContext context) {
    List<GameUser> allPlayersInfoList = [];
    List<String> allPlayersUID = [];
    var scaffoldKey = GlobalKey<ScaffoldState>();
    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: backgroundBlue,
      key: scaffoldKey,
      // drawer: Drawer(
      //   child: ListView(
      //     padding: EdgeInsets.zero,
      //     children: [
      //       DrawerHeader(
      //         decoration: BoxDecoration(
      //           color: blue,
      //         ),
      //         child: Column(
      //           children: [
      //             Image.asset(
      //               'assets/m.png',
      //               width: 40
      //             ),
      //             Text('참여코드', style: body2style()),
      //             Text('$_code', style: head1style()),
      //             Text(globalAllPlayersInfoList.length.toString())
      //           ],
      //         ),
      //       ),
      //       ListView.builder(
      //         padding: const EdgeInsets.all(8),
      //         itemCount: globalAllPlayersInfoList.length,
      //         itemBuilder: (BuildContext context, int index) {
      //           print('itembuilder${globalAllPlayersInfoList.length}');
      //           return Container(
      //             height: 50,

      //             child: Center(child: Text('${globalAllPlayersInfoList[index].id}')),
      //           );
      //         }
      //       )
            
      //     ],
      //   ),
      // ),
    
      
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
                                  allPlayersUID = [];
                                  allPlayersInfoList = [];
                                  await getFirebaseAllUsersData(
                                      gameData['players'], allPlayersInfoList); 
                                  setState(() {
                                    globalAllPlayersInfoList = allPlayersInfoList;
                                  });
                                  
                                  // for (var player in allPlayersInfoList) {
                                  //   print('${player.id} ${player.avatarIndex}');
                                  // }
                                  scaffoldKey.currentState?.openDrawer();
                                  
                                  
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
                      
                      //RECORDS STREAM
                      Padding(
                        padding:EdgeInsets.symmetric(horizontal: size.width*0.1),
                        child: SizedBox(
                          
                           
                          height: size.height * 0.67,
                          child: RecordStream(code: _code, name: _name),
                        ),
                      ),
                      Spacer(),
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
              if(data['type'] == 'success'){  //성공했을 때
                
                return Container(
                  height:99,
                  margin: EdgeInsets.only(top:40),
                  alignment: Alignment.center,
                  decoration:  BoxDecoration(
                    color: darkGrey.withOpacity(0.1),
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.all( Radius.circular(15))
                  ),
                  child: ListTile(
                    title: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Image.asset('assets/m.png', width: 22, height: 17,),
                    ),
                    subtitle: Text(data['record'], textAlign: TextAlign.center,),
                  ),
                );
              }
              else { //실패했을 때
                return Container(
                  margin: EdgeInsets.only(bottom: 30),
                  height:20,
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    subtitle: Text(
                      data['record'],
                      textAlign: TextAlign.center,
                      style: body4style()
                    ),
               
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
