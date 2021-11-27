// ignore_for_file: unused_field

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
var _roundNumber = 0;

class GameZone extends StatefulWidget {
  GameZone({Key? key}) : super(key: key);

  @override
  _GameZoneState createState() => _GameZoneState();
}

class _GameZoneState extends State<GameZone> {
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
    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: backgroundBlue,
      appBar: AppBar(
        backgroundColor: backgroundBlue,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            point2style(data: 'ROUND'),
            point2style(data: (_roundNumber + 1).toString())
          ]
        ),
        //actions: [_isHost ? SkipButton() : Text('')],
      ),
      body: SafeArea(
        child: Container(
          color: backgroundBlue,
          height: 800,
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
                              width:66,
                              child: IconButton(
                                onPressed: () {},
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
                                gameData['keywords'][_roundNumber], 
                                style: head1style()
                              ),
                            ),
                            SkipButton(),
                            // TextButton(
                            //   child: Text('PrintUserInfo'),
                            //   onPressed: printUserData,
                            // ),
                          ],
                        ),
                      ),

                      //main records stream area
                      SizedBox(
                        height: size.height*0.7,
                        child: RecordStream(code: _code, name: _name),
                      ),
                      bigButtonTheme(
                        '📷 사진 업로드', 
                        (){getImageFromGallery();}
                      ),

                    ],
                  );
                } on Exception catch (e) {
                  // TODO
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

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    // Get.to(WelcomePage());
    Get.offAll(WelcomePage());
  }
  Widget SkipButton() {
    return Container(
      width: 66,
      height: 24,
      child: OutlinedButton(
        child: Text('Skip', style:body4style()),
        style: OutlinedButton.styleFrom(
          backgroundColor: blue,
          side: BorderSide(color: darkGrey),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: () {
          if (_roundNumber < 11) {
            setState(() {
              //just make a new field in server
              _roundNumber++;
            });
          }
          print(_roundNumber);
        },
      ),
    );
  }

  Future getImageFromGallery() async {
    var tempStore = await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      pickedImage = XFile(tempStore!.path);
    });
    applyModelOnImage(pickedImage);
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
              return Container(
                height: 50,
                child: ListTile(
                  title: Text(data['record']),
                  subtitle: Text(name),
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
