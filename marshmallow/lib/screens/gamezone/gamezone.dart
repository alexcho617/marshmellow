// ignore_for_file: unused_field

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marshmallow/models/user.dart';
import 'package:marshmallow/screens/setting/setting.dart';
import 'package:marshmallow/services/firebase.dart';

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

  @override
  void initState() {
    super.initState();
    checkFirebaseUser();
    _printInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GameZone'),
        actions: [_isHost ? SkipButton() : Text('')],
      ),
      body: SafeArea(
        child: Container(
          color: Colors.amber,
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.menu),
                          ),
                          Text('Round ${_roundNumber + 1}'),
                          SkipButton(),
                          TextButton(
                            child: Text('PrintUserInfo'),
                            onPressed: printUserData,
                          ),
                        ],
                      ),
                      Text(gameData['keywords'][_roundNumber]),

                      //main records stream area
                      SizedBox(
                        height: 500,
                        child: RecordStream(code: _code),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text('Upload Photo'),
                      )
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
    return TextButton(
      onPressed: () {
        if (_roundNumber < 11) {
          setState(() {
            //just make a new field in server
            _roundNumber++;
          });
        }
        print(_roundNumber);
      },
      child: Text(
        'Skip',
      ),
    );
  }
}

class RecordStream extends StatelessWidget {
  RecordStream({required this.code});
  String code;
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
