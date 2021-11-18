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
      appBar: AppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          point1style(data: 'hello'),
          smallButtonTheme('small', () {}),
          mediumButtonTheme('medium', () {}),
          bigButtonTheme('big', () {}),
          TextButton(onPressed: signOut, child: Text('Sign Out')),
          TextButton(onPressed: printUserData, child: Text('Print User Data'))
        ],
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
