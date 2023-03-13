import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:marshmallow/models/game.dart';
import 'package:marshmallow/models/user.dart';
import 'package:audioplayers/audioplayers.dart';

FirebaseFirestore firestore = FirebaseFirestore.instance;
FirebaseAuth auth = FirebaseAuth.instance;

//FIRESTORE
//CHECK ID AVAILABILITY: WILL RETURN FALSE IF ID IS UNAVAILABLE
Future<bool> firestoreTestId(String id) async {
  List ids = [];
  await firestore.collection('Users').get().then((QuerySnapshot querySnapshot) {
    querySnapshot.docs.forEach((doc) {
      ids.add(doc["id"]);
    });
  });

  if (ids.contains(id)) {
    return false;
  } else {
    return true;
  }
}

//ADD NEW USERS TO USERS COLLECTION IN FIRESTORE
Future<void> firestoreAddUser(GameUser newUser, String uid) async {
  CollectionReference users = firestore.collection('Users');
  await users
      .doc(uid)
      .set({
        'avatarIndex': newUser.avatarIndex,
        'globalToken': newUser.globalToken,
        'localToken': newUser.localToken,
        'id': newUser.id,
        'uid': newUser.uid
      })
      .then((value) => print("User Added"))
      .catchError((error) => print("Failed to add user: $error"));
}

//CREATE NEW GAME
Future<void> firestoreNewGame(Game newGame, String code) async {
  CollectionReference gamerooms = firestore.collection('GameRooms');
  await gamerooms
      .doc(code)
      .set({
        'code': newGame.code,
        'keywords': newGame.keywords,
        'host': newGame.host,
        'playerCount': newGame.playerCount,
        'playerLimit': newGame.playerLimit,
        'timeLimit': newGame.timeLimit,
        'players': newGame.players,
        'currentRound': newGame.currentRound,
        'isOver': newGame.isOver
      })
      .then((value) => print("Game Added"))
      .catchError((error) => print("Failed to add game: $error"));

  await gamerooms
      .doc(code)
      .collection('Records')
      .add({
        'record': '새로운 게임방이 생성되었습니다.',
        'type': 'message',
        'time': DateTime.now().toIso8601String(),
      })
      .then((value) => print("Game Added"))
      .catchError((error) => print("Failed to initiate records: $error"));
}

Future<void> handleResult(String currentKey, String tfliteLabel, String code,
    String playerName, String playerUid) async {
  CollectionReference gamerooms = firestore.collection('GameRooms');
  // final player = AudioCache();
  final player = AudioPlayer();
  //sucess
  if (currentKey == tfliteLabel) {
    player.play(UrlSource('sounds/success.wav'));
    await gamerooms
        .doc(code)
        .collection('Records')
        .add({
          'record': '$playerName님이 인식에 성공하여\n마시멜로를 획득하였습니다 🎉',
          // currentKey:$currentKey - tfliteLabel:$tfliteLabel',
          'type': 'success',
          'time': DateTime.now().toIso8601String()
        })
        .then((value) => print("Game Added"))
        .catchError((error) => print("Failed to initiate records: $error"));
    plusLocalMarsh(playerUid);
    firestoreIncreaseRound(code);
  }
  //fail
  else {
    player.play(UrlSource('sounds/failure.wav'));
    await gamerooms
        .doc(code)
        .collection('Records')
        .add({
          'record': '$playerName님이 인식에 실패했습니다.',
          // currentKey:$currentKey - tfliteLabel:$tfliteLabel',
          'type': 'failure',
          'time': DateTime.now().toIso8601String()
        })
        .then((value) => print("Game Added"))
        .catchError((error) => print("Failed to initiate records: $error"));
  }
}

Future<void> firestoreIncreaseRound(String code) async {
  int currentRound = 0;
  DocumentReference gameroom = firestore.collection('GameRooms').doc(code);
  await gameroom.get().then((DocumentSnapshot documentSnapshot) {
    print(
        'FirestreIncreaseRound_CurrentRound:${documentSnapshot['currentRound']}');
    currentRound = documentSnapshot['currentRound'];
  });
  if (currentRound < 10) {
    await gameroom.update(
      ({'currentRound': FieldValue.increment(1)}),
    );
  } else {
    print('End of Round');
  }
}

Future<void> firestoreSetRoundOver(String code) async {
  DocumentReference gameroom = firestore.collection('GameRooms').doc(code);
  await gameroom.update(
    ({'isOver': true}),
  );
}

//ADD NEW USER TO EXISTING GAME
//TODO: Limit players at all?
Future<void> firestoreRegisterGame(String code, String uid) async {
  DocumentReference gameroom = firestore.collection('GameRooms').doc(code);
  await gameroom.update(
    ({
      'players': FieldValue.arrayUnion([uid]),
      'playerCount': FieldValue.increment(1)
    }),
  );
}

Future<void> _getFirebaseUserData(String uid, GameUser currentPlayer) async {
  await firestore
      .collection('Users')
      .doc(uid)
      .get()
      .then((DocumentSnapshot documentSnapshot) {
    currentPlayer.id = documentSnapshot.get("id");
    currentPlayer.uid = documentSnapshot.get("uid");
    currentPlayer.avatarIndex = documentSnapshot.get("avatarIndex");
    currentPlayer.globalToken = documentSnapshot.get("globalToken");
    currentPlayer.localToken = documentSnapshot.get("localToken");
  });
}

Future<void> getFirebaseAllUsersData(
    List<dynamic> uids, List<GameUser> currentPlayers) async {
  for (String uid in uids) {
    GameUser currentPlayer = GameUser();
    await firestore
        .collection('Users')
        .doc(uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      currentPlayer.id = documentSnapshot.get("id");
      currentPlayer.uid = documentSnapshot.get("uid");
      currentPlayer.avatarIndex = documentSnapshot.get("avatarIndex");
      currentPlayer.globalToken = documentSnapshot.get("globalToken");
      currentPlayer.localToken = documentSnapshot.get("localToken");
      currentPlayers.add(currentPlayer);
    });
  }
}

Future<List<GameUser>> getFutureFirebaseAllUsersData(List<dynamic> uids) async {
  List<GameUser> currentPlayers = [];
  for (String uid in uids) {
    GameUser currentPlayer = GameUser();
    await firestore
        .collection('Users')
        .doc(uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      currentPlayer.id = documentSnapshot.get("id");
      currentPlayer.uid = documentSnapshot.get("uid");
      currentPlayer.avatarIndex = documentSnapshot.get("avatarIndex");
      currentPlayer.globalToken = documentSnapshot.get("globalToken");
      currentPlayer.localToken = documentSnapshot.get("localToken");
      currentPlayers.add(currentPlayer);
    });
  }
  return currentPlayers;
}

//AUTHENTICATION
//ANONYMOUS SIGN IN
Future<UserCredential> signInAnonymously() async {
  UserCredential userCredential =
      await FirebaseAuth.instance.signInAnonymously();
  return userCredential;
}

//CHECK CURRENT FIREBASE USER
Future<void> checkFirebaseUser() async {
  if (auth.currentUser != null) {
    User? loggedInUser = auth.currentUser;
    print('checkFirebaseUser: ${loggedInUser!.uid}');
  } else {
    print('err getting firebase user');
  }
}

//RETURN FIREBASE UID
Future<String> getFirebaseUID() async {
  if (auth.currentUser != null) {
    User? loggedInUser = auth.currentUser;
    return loggedInUser!.uid;
  } else {
    return 'Failed:getFirebaseUID';
  }
}

Future<void> plusLocalMarsh(String uid) async {
  int localToken = 0;
  CollectionReference users = firestore.collection('Users');
  await users.doc(uid).get().then((DocumentSnapshot documentSnapshot) {
    localToken = documentSnapshot.get("localToken");
  });
  await users
      .doc(uid)
      .update({
        'localToken': localToken + 1,
      })
      .then((value) => print("plusLocalMarsh: Local Token Added"))
      .catchError((error) =>
          print("plusLocalMarsh: Failed to Add Local Token: $error"));
}

Future<void> updateGlobalMarsh(String uid) async {
  int localToken = 0;
  int globalToken = 0;
  CollectionReference users = firestore.collection('Users');
  await users.doc(uid).get().then((DocumentSnapshot documentSnapshot) {
    localToken = documentSnapshot.get("localToken");
    globalToken = documentSnapshot.get("globalToken");
  });
  await users
      .doc(uid)
      .update({
        'globalToken': localToken + globalToken,
        'localToken': 0,
      })
      .then((value) => print("updateGlobalMarsh: Global Token Updated"))
      .catchError((error) =>
          print("updateGlobalMarsh: Failed to Update Global Token: $error"));
}
