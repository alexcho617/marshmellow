import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:marshmallow/models/game.dart';
import 'package:marshmallow/models/user.dart';

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
        'currentRound': newGame.currentRound
      })
      .then((value) => print("Game Added"))
      .catchError((error) => print("Failed to add game: $error"));

  await gamerooms
      .doc(code)
      .collection('Records')
      .add({
        'record': 'Host Created New Game',
        'type': 'message',
        'time': DateTime.now().toIso8601String(),
      })
      .then((value) => print("Game Added"))
      .catchError((error) => print("Failed to initiate records: $error"));
}

Future<void> handleResult(String currentKey, String tfliteLabel, String code,
    String playerName, String playerUid) async {
  CollectionReference gamerooms = firestore.collection('GameRooms');

  //sucess
  if (currentKey == tfliteLabel) {
    await gamerooms
        .doc(code)
        .collection('Records')
        .add({
          'record':
              '$playerName(이)가 정답을 맞췄습니다! currentKey:$currentKey - tfliteLabel:$tfliteLabel',
          'type': 'success',
          'time': DateTime.now().toIso8601String()
        })
        .then((value) => print("Game Added"))
        .catchError((error) => print("Failed to initiate records: $error"));
    plusLocalMarsh(playerUid);
  }
  //fail
  else {
    await gamerooms
        .doc(code)
        .collection('Records')
        .add({
          'record':
              '$playerName(이)가 틀렸습니다! currentKey:$currentKey - tfliteLabel:$tfliteLabel',
          'type': 'failure',
          'time': DateTime.now().toIso8601String()
        })
        .then((value) => print("Game Added"))
        .catchError((error) => print("Failed to initiate records: $error"));
  }
}

Future<void> firestoreIncreaseRound(String code) async {
  DocumentReference gameroom = firestore.collection('GameRooms').doc(code);
  await gameroom.update(
    ({'currentRound': FieldValue.increment(1)}),
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
      .then((value) => print("User Added"))
      .catchError((error) => print("Failed to add user: $error"));
}
