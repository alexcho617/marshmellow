import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marshmallow/models/user.dart';
import 'package:marshmallow/screens/gameSetting/gameSetting.dart';
import 'package:marshmallow/screens/setting/setting.dart';
import 'package:marshmallow/services/firebase.dart';
import 'package:marshmallow/utils/colors.dart';
import 'package:marshmallow/utils/text.dart';
import 'package:marshmallow/widgets/button.dart';
import 'package:marshmallow/widgets/userMarshInfo.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<String> uid;
  GameUser currentPlayer = GameUser();
  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    checkFirebaseUser();
    getFirebaseUserData(_auth.currentUser!.uid, currentPlayer);
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: backgroundBlue,
      appBar: AppBar(
        backgroundColor: backgroundBlue,
        elevation: 0,
        title: Image.asset('assets/logo.png', width: 95),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 34),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 48,),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${user.id}',
                  style: head1style(),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 1, bottom: 2),
                  child: Text('님, 안녕하세요',
                    style: body2style(),
                  ),
                ),
                Spacer(),
                UserMArshInfo()
              ],
              
            ),
            
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Image.asset('assets/home.png'),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 155,
                  height: 200,
                  child: OutlinedButton(
                    
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '팀장',
                          style: head1style()
                        ),
                        SizedBox(height:5),
                        Text(
                          '방 만들기',
                          style: body1style()
                        ),
                      ],
                    ),
                    style: OutlinedButton.styleFrom (
                      backgroundColor: yellow,
                      side: BorderSide(color: darkGrey),
                      shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(35),
                      ),
                    ),
                    onPressed: (){
                      Get.to(() => GameSettingPage());
                    },
                  )
                ),
                Container(
                  width: 155,
                  height: 200,
                  child: OutlinedButton(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '팀원',
                          style: head1style()
                        ),
                        SizedBox(height:5),
                        Text(
                          '참가하기',
                          style: body1style()
                        ),
                      ],
                    ),
                    style: OutlinedButton.styleFrom (
                      backgroundColor: yellow,
                      side: BorderSide(color: darkGrey),
                      shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(35),
                      ),
                    ),
                    onPressed: (){},
                  )
                )
              ],
            )
            
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
            },
            child: Image.asset('assets/trophy.png', width: 40,),
            backgroundColor: blue,
          )
        )
      ),
    );
  }

  void printUserData() {
    print(currentPlayer.id);
    print(currentPlayer.uid);
    print(currentPlayer.avatarIndex);
    print(currentPlayer.localToken);
    print(currentPlayer.globalToken);
    print(currentPlayer.type);
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    // Get.to(WelcomePage());
    Get.offAll(WelcomePage());
  }

  Future<void> getFirebaseUserData(String uid, GameUser currentPlayer) async {
    await firestore
        .collection('Users')
        .doc(uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      currentPlayer.id = documentSnapshot.get("id");
      currentPlayer.avatarIndex = documentSnapshot.get("avatarIndex");
      currentPlayer.globalToken = documentSnapshot.get("globalToken");
      currentPlayer.localToken = documentSnapshot.get("localToken");
      currentPlayer.uid = uid;
    });
  }
}
