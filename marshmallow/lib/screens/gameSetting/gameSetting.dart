import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marshmallow/models/game.dart';
import 'package:marshmallow/models/user.dart';
import 'package:marshmallow/screens/gamezone/gamezone.dart';
import 'package:marshmallow/services/firebase.dart';
import 'package:marshmallow/utils/colors.dart';
import 'package:marshmallow/utils/text.dart';
import 'package:marshmallow/utils/utils.dart';
import 'package:marshmallow/widgets/button.dart';
import "dart:math";

class GameSettingPage extends StatefulWidget {
  @override
  State<GameSettingPage> createState() => _GameSettingPageState();
}

class _GameSettingPageState extends State<GameSettingPage> {
  GameUser currentPlayer = GameUser();
  bool userLoaded = false;
  List<String> wordSet = [];
  final random = Random();
  final _auth = FirebaseAuth.instance;

  final List<String> _dropdownValues = ["3", "4", "5", "6", "7"];
  var _currentlySelected;

  @override
  void initState() {
    super.initState();
    getRandomKeywords();
    _getFirebaseUserData(_auth.currentUser!.uid, currentPlayer);
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: backgroundBlue,
        appBar: AppBar(
          backgroundColor: backgroundBlue,
          elevation: 0,
          title: Image.asset('assets/logo.png', width: 95),
        ),
        body: Container(
          alignment: Alignment.topCenter,
          child: Column(
            children: [
              SizedBox(height: size.height * 0.08),
              Container(
                  width: 346,
                  decoration: new BoxDecoration(
                      color: yellow,
                      border: Border.all(color: darkGrey),
                      borderRadius: new BorderRadius.only(
                        topLeft: const Radius.circular(30.0),
                        topRight: const Radius.circular(30.0),
                      )),
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      Image.asset(
                        'assets/m.png',
                        width: 41,
                      ),
                      SizedBox(height: 5),
                      Text(
                        'RANDOM KEYWORDS',
                        style: body3style(),
                      ),
                      SizedBox(height: 10),
                      Container(
                          width: 326,
                          height: 229,
                          padding: EdgeInsets.symmetric(
                              horizontal: 23, vertical: 19),
                          decoration: new BoxDecoration(
                            color: white.withOpacity(0.6),
                            border: Border.all(color: darkGrey),
                          ),
                          child: GridView.builder(
                              itemCount: wordSet.length, //item 개수
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      mainAxisSpacing: 10, //수평 Padding
                                      crossAxisSpacing: 20,
                                      childAspectRatio: 130 / 30 //수직 Padding
                                      ),
                              itemBuilder: (BuildContext context, int index) {
                                final List<String> wordList = wordSet.toList();
                                return Container(
                                    width: 130,
                                    height: 30,
                                    alignment: Alignment.center,
                                    decoration: new BoxDecoration(
                                        border: Border.all(color: darkGrey),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20.0))),
                                    child: Container(
                                      child: Text(wordList[index],
                                          style: body2style()),
                                    ));
                              })),
                      TextButton(
                          onPressed: () {
                            setState(() {
                              getRandomKeywords();
                            });
                          },
                          child: Text(
                            '🔄 다시 뽑기',
                            style: body3style(),
                          ))
                    ],
                  )),
              SizedBox(height: 15),
              Container(
                width: 346,
                height: 59,
                decoration: new BoxDecoration(
                  color: yellow,
                  border: Border.all(color: darkGrey),
                ),
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(
                    '인원 선택',
                    style: body3style(),
                  ),
                  SizedBox(
                    width: 35,
                  ),
                  Container(
                    width: 91,
                    height: 35,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: white.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                          color: darkGrey, style: BorderStyle.solid, width: 1),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton(
                        value: _currentlySelected,
                        hint: Text(
                          '0',
                          style: body3style(),
                        ),
                        items: _dropdownValues
                            .map((value) => DropdownMenuItem(
                                  child: Padding(
                                    padding: EdgeInsets.only(right: 10),
                                    child: Text(value),
                                  ),
                                  value: value,
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _currentlySelected = value;
                            print(_currentlySelected);
                          });
                        },
                        isExpanded: false,
                        style: body3style(),
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  Text(
                    '명',
                    style: body3style(),
                  )
                ]),
              ),
              SizedBox(height: 50),
              mediumButtonTheme('방 만들기', makeNewGame)
            ],
          ),
        ));
  }

  void makeNewGame() async {
    try {
      String code = random.nextInt(9999).toString();

      //need to make a new game room stream
      Game newGame = Game();
      newGame.code = code;
      newGame.host = currentPlayer.uid;
      newGame.playerCount = 1;
      newGame.playerLimit = _currentlySelected;
      newGame.players = [currentPlayer.uid];
      newGame.keywords = wordSet;
      newGame.timeLimit = 60;
      newGame.curretRound = 1;
      await firestoreNewGame(newGame, code);
      //what are preparations needed?
      //go to game zone
      currentPlayer.type = UserType.host;
      Get.to(() => GameZone(), arguments: [code, currentPlayer]);
    } on Exception catch (e) {
      // TODO
      print(e);
    }
  }

  void getRandomKeywords() {
    wordSet.clear();
    int i, j = 0;
    for (i = 0; i < 10; i++) {
      j = random.nextInt(wordRepository.length);
      String word = wordRepository[j];
      wordSet.add(word);
    }
    print(wordSet);
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

  // //set version
  // void getRandomKeywords() {
  //   wordSet.clear();
  //   Set<String> repository = {};
  //   //Have to deep copy
  //   repository = wordRepository;
  //   final random = Random();
  //   int i, j = 0;

  //   for (i = 0; i < 10; i++) {
  //     j = random.nextInt(repository.length);
  //     print('j:$j');
  //     String word = repository.elementAt(j);
  //     wordSet.add(word);
  //     repository.remove(word);
  //     print('wordRepo$wordRepository');
  //     print('repo$repository');
  //   }
  //   print(wordSet);
  // }
}
