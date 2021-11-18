import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:marshmallow/models/user.dart';

FirebaseFirestore firestore = FirebaseFirestore.instance;
FirebaseAuth auth = FirebaseAuth.instance;

//FIRESTORE
//FUNCTION FOR CHECKING ID AVAILABILITY: WILL RETURN FALSE IF ID IS UNAVAILABLE
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

// Future<void> getFirebaseUserData(String uid, GameUser currentUser) async {
//   await firestore
//       .collection('Users')
//       .doc(uid)
//       .get()
//       .then((DocumentSnapshot documentSnapshot) {
//     currentUser.id = documentSnapshot.get("id");
//     currentUser.avatarIndex = documentSnapshot.get("avatarIndex");
//     currentUser.globalToken = documentSnapshot.get("globalToken");
//     currentUser.localToken = documentSnapshot.get("localToken");
//     currentUser.uid = uid;

//     print('GetFIrebaseUserData: ${currentUser.id}');
//   });
// }

//FUNCTION FOR ADDING NEW USERS TO USERS COLLECTION IN FIRESTORE
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

//AUTHENTICATION
Future<UserCredential> signInAnonymously() async {
  UserCredential userCredential =
      await FirebaseAuth.instance.signInAnonymously();
  return userCredential;
}

Future<void> checkFirebaseUser() async {
  if (auth.currentUser != null) {
    User? loggedInUser = auth.currentUser;
    print('checkFirebaseUser: ${loggedInUser!.uid}');
  } else {
    print('err getting firebase user');
  }
}

Future<String> getFirebaseUID() async {
  if (auth.currentUser != null) {
    User? loggedInUser = auth.currentUser;
    return loggedInUser!.uid;
  } else {
    return 'Failed:getFirebaseUID';
  }
}
