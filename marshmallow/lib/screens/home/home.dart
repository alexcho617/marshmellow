import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marshmallow/models/user.dart';
import 'package:marshmallow/screens/gameSetting/gameSetting.dart';
import 'package:marshmallow/screens/gamezone/gamezone.dart';
import 'package:marshmallow/screens/result/result.dart';
import 'package:marshmallow/screens/setting/setting.dart';
import 'package:marshmallow/services/firebase.dart';
import 'package:marshmallow/utils/colors.dart';
import 'package:marshmallow/utils/text.dart';
import 'package:marshmallow/widgets/button.dart';
import 'package:marshmallow/widgets/userMarshInfo.dart';
import 'package:marshmallow/screens/ranking/ranking.dart';
import 'package:marshmallow/screens/laboratory/lab.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  GameUser currentPlayer = GameUser();

  late Future<String> uid;
  final _auth = FirebaseAuth.instance;
  bool userLoaded = false;
  @override
  void initState() {
    super.initState();
    checkFirebaseUser();
    _getFirebaseUserData(_auth.currentUser!.uid, currentPlayer);
  }

  @override
  Widget build(BuildContext context) {
    //print('BUILD PLAYER ID ${currentPlayer.id}');
    var size = MediaQuery.of(context).size;
    //print(currentPlayer.globalToken);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: backgroundBlue,
      appBar: AppBar(
        backgroundColor: backgroundBlue,
        elevation: 0,
        title: Image.asset('assets/logo.png', width: 95),
        iconTheme: IconThemeData(color: darkGrey),
      ),
      drawer: Drawer(

        child: ListView(
          padding: EdgeInsets.zero, 
          children: [
            DrawerHeader(
              padding: EdgeInsets.only(left: 30, bottom: 15),
              decoration: BoxDecoration(
                color: blue,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset('assets/m.png', width: 30),
                  SizedBox(height: 10),
                  point2style(data:'MARSHMALLOW', color:yellow)
                  
                ],
              )
            ),
            Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(left: 30),
              child: TextButton(onPressed: signOut, child: Text('SignOut',style: body1style(),textAlign: TextAlign.start,))
            ),
            Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(left: 30),
              child: TextButton(onPressed: () {Get.to(() => LabPage());}, child: Text('Marsh Lab',style: body1style(),textAlign: TextAlign.start,))
            ),
          ]
        )
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 34),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: size.height * 0.05,
            ),
            userLoaded
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${currentPlayer.id}',
                        style: head1style(),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 1, bottom: 2),
                        child: Text(
                          '님, 안녕하세요',
                          style: body2style(),
                        ),
                      ),
                      Spacer(),
                      UserMArshInfo(currentPlayer.globalToken ?? 0)
                    ],
                  )
                : Text('User Loading'),
            
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Image.asset('assets/home.png'),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                    //Alex: OverFLow, adjust width
                    width: size.width * 0.4,
                    //width: 150,
                    height: size.width * 0.53,
                    child: OutlinedButton(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('팀장', style: head1style()),
                          SizedBox(height: 5),
                          Text('방 만들기', style: body1style()),
                        ],
                      ),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: yellow,
                        side: BorderSide(color: darkGrey),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(35),
                        ),
                      ),
                      onPressed: () {
                        Get.to(() => GameSettingPage());
                      },
                    )),
                Container(
                    //Alex: OverFLow, adjust width
                    width: size.width * 0.4,
                    //width: 150,
                    height: size.width * 0.53,
                    child: OutlinedButton(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('팀원', style: head1style()),
                          SizedBox(height: 5),
                          Text('참가하기', style: body1style()),
                        ],
                      ),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: yellow,
                        side: BorderSide(color: darkGrey),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(35),
                        ),
                      ),
                      onPressed: () async {
                        final String currentTeam =
                            await _asyncInputDialog(context) ?? '';
                      },
                    ))
              ],
            ),
            
          ],
        ),
      ),
      floatingActionButton: Container(
          height: 74.0,
          width: 74.0,
          child: FittedBox(
              child: FloatingActionButton(
            onPressed: () {
              // Add your onPressed code here!
              printUserData();
              Get.to(() => RankingPage(), arguments: [currentPlayer]);
            },
            child: Image.asset(
              'assets/trophy.png',
              width: 40,
            ),
            backgroundColor: blue,
          ))),
    );
  }

  void printUserData() {
    print('currentPlayer_uid: ${currentPlayer.uid}');
    print('currentPlayer_id: ${currentPlayer.id}');
    print('currentPlayer_type: ${currentPlayer.type}');
    print('currentPlayer_avatarIndex: ${currentPlayer.avatarIndex}');
    print('currentPlayer_localToken: ${currentPlayer.localToken}');
    print('currentPlayer_globalToken: ${currentPlayer.globalToken}');
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    // Get.to(WelcomePage());
    Get.offAll(WelcomePage());
  }

  Future<void> _getFirebaseUserData(String uid, GameUser currentPlayer) async {
    await firestore
        .collection('Users')
        .doc(uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      setState(() {
        currentPlayer.id = documentSnapshot.get("id");
        currentPlayer.avatarIndex = documentSnapshot.get("avatarIndex");
        currentPlayer.globalToken = documentSnapshot.get("globalToken");
        currentPlayer.localToken = documentSnapshot.get("localToken");
        currentPlayer.uid = uid;
        userLoaded = true;
      });
    });
  }

  Future _asyncInputDialog(BuildContext context) async {
    String entranceCode = '';

    return showDialog(
      context: context,
      barrierDismissible:
          false, // dialog is dismissible with a tap on the barrier
      builder: (context) {
        return AlertDialog(
          titlePadding: EdgeInsets.zero,
          contentPadding: EdgeInsets.zero,
          backgroundColor: pink,
          shape: RoundedRectangleBorder(
              side: BorderSide(color: darkGrey),
              borderRadius: BorderRadius.all(Radius.circular(30.0))),
          content: Container(
            width: 346,
            height: 218,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _getCloseButton(context),
                Text('입장코드', style: head1style()),
                SizedBox(height: 15),
                Container(
                  width: 266,
                  height: 69,
                  alignment: Alignment.center,
                  color: white.withOpacity(0.6),
                  child: TextField(
                    textAlign: TextAlign.center,
                    autofocus: false,
                    keyboardType: TextInputType.number,
                    decoration: new InputDecoration(
                      contentPadding: EdgeInsets.zero,
                      border: InputBorder.none,
                      hintText: '팀장에게 받은 코드를 입력하세요',
                      hintStyle: body1style(),
                    ),
                    style: body6style(),
                    onChanged: (value) {
                      entranceCode = value;
                    },
                  ),
                ),
                SizedBox(height: 14),
                smallButtonTheme('들어가기', () async {
                  try {
                    await firestoreRegisterGame(entranceCode, currentPlayer.uid);
                    setState(() {
                      currentPlayer.type = UserType.player;
                    });
                    Get.to(() => GameZone(),
                        arguments: [entranceCode, currentPlayer]);
                  } on Exception catch (e) {
                    showDialog(
                        context: context,
                        barrierDismissible:
                            false, // dialog is dismissible with a tap on the barrier
                        builder: (context) {
                          return AlertDialog(
                              backgroundColor: yellow,
                              shape: RoundedRectangleBorder(
                                  side: BorderSide(color: darkGrey),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(30.0))),
                              content: Container(
                                  height: 100,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      _getCloseButton(context),
                                      Text('🔐', style: head1style()),
                                      SizedBox(height: 15),
                                      Text('입장코드를 다시 입력하세요.',
                                          style: body3style()),
                                    ],
                                  )));
                        });
                    print('Cannot join game');
                  }
                })
              ],
            ),
          ),
        );
      },
    );
  }

  _getCloseButton(context) {
    return Padding(
      padding: const EdgeInsets.only(right: 15),
      child: GestureDetector(
        child: Container(
          alignment: FractionalOffset.topRight,
          child: GestureDetector(
            child: Icon(Icons.clear, color: darkGrey),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }

  // _joinGame(String code, String uid) async {

  // }
}
