import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:marshmallow/models/user.dart';

FirebaseFirestore firestore = FirebaseFirestore.instance;

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

//FUNCTION FOR ADDING NEW USERS TO USERS COLLECTION IN FIRESTORE
Future<void> firestoreAddUser(User newUser) async {
  CollectionReference users = firestore.collection('Users');
  await users
      .add({
        'avatarIndex': newUser.avatarIndex,
        'globalToken': newUser.globalToken,
        'localToken': newUser.localToken,
        'id': newUser.id
      })
      .then((value) => print("User Added"))
      .catchError((error) => print("Failed to add user: $error"));
}
