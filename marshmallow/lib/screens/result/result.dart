import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:marshmallow/models/user.dart';
import 'package:marshmallow/screens/home/home.dart';
import 'package:marshmallow/services/firebase.dart';
import 'package:marshmallow/utils/colors.dart';
import 'package:get/get.dart';
import 'package:marshmallow/utils/text.dart';
import 'package:marshmallow/widgets/button.dart';

// var _getArguments = Get.arguments;
// var _currentPlayerUIDS = _getArguments;

class ResultPage extends StatefulWidget {
  ResultPage({required this.currentPlayerUIDS, required this.currentPlayer});
  var currentPlayerUIDS;
  GameUser currentPlayer;
  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  final firestore = FirebaseFirestore.instance;
  var currentPlayerUIDS;
  late GameUser currentPlayer;

  @override
  void initState() {
    // TODO: implement initState
    currentPlayerUIDS = widget.currentPlayerUIDS;
    currentPlayer = widget.currentPlayer;
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    print('line 26 ${currentPlayerUIDS.length}');
    return Scaffold(
        backgroundColor: backgroundBlue,
        appBar: AppBar(
          backgroundColor: backgroundBlue,
          elevation: 0,
          title: Image.asset('assets/logo.png', width: 95),
        ),
        body: FutureBuilder<List<GameUser>>(
            future: getFutureFirebaseAllUsersData(currentPlayerUIDS),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData == false) {
                return Drawer(
                    child: Center(child: CircularProgressIndicator()));
              } else if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Drawer(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                );
              } else {
                List<GameUser> userList = snapshot.data;
                userList.sort((a, b) => b.localToken.compareTo(a.localToken));
                return Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Image.asset('assets/result.png'),
                    ),
                    point2style(data: 'gameover!!', color: blue),
                    SizedBox(height: 10),
                    ListView.separated(
                        separatorBuilder: (BuildContext context, int index) =>
                            const Divider(),
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        padding: EdgeInsets.all(8),
                        itemCount: userList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
                            padding: EdgeInsets.only(left: 30),
                            height: 40,
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Text((index + 1).toString(),
                                      style: body5style()),
                                ),
                                Expanded(
                                  flex: 5,
                                  child: Text(userList[index].id.toString(),
                                      style: body5style()),
                                ),
                                Expanded(
                                  flex: 1,
                                  child:
                                      Image.asset('assets/m.png', height: 20),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    userList[index].localToken.toString(),
                                    style: body5style(),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                    Spacer(),
                    Padding(
                      padding: const EdgeInsets.all(30),
                      child: Center(
                        child: mediumButtonTheme('홈으로', () async {
                          await updateGlobalMarsh(currentPlayer.uid);
                          Get.offAll(HomePage());
                        }),
                      ),
                    ),
                  ],
                );
              }
            }));
  }
}
