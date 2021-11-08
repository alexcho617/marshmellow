import 'package:flutter/material.dart';

enum UserType { host, player }

class User {
  User({
    required this.avatarIndex,
    required this.globalToken,
    required this.localToken,
  });
  int avatarIndex = 0;
  int globalToken = 0;
  int localToken = 0;
  String id = '';
  UserType type = UserType.player;
}
