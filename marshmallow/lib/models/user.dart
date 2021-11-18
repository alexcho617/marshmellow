import 'package:flutter/material.dart';

enum UserType { host, player }

class GameUser {
  GameUser({this.avatarIndex, this.globalToken, this.localToken, this.uid});
  dynamic avatarIndex = 0;
  dynamic globalToken = 0;
  dynamic localToken = 0;
  dynamic uid = '';
  dynamic id = '';
  UserType type = UserType.player;
}
