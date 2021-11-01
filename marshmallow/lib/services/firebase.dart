import 'package:cloud_firestore/cloud_firestore.dart';

FirebaseFirestore firestore = FirebaseFirestore.instance;

bool checkID(String id) {
  var users = firestore.doc("GameRoom");
  print(users);
  
  List ids = [];
  if (ids.contains(id)) {
    return false;
  } else
    return true;
}
