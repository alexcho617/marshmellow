import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:marshmallow/models/user.dart';
import 'package:marshmallow/utils/colors.dart';
import 'package:get/get.dart';

var _getArguments = Get.arguments;
GameUser _currentPlayer = _getArguments[0];
var index = 0;

class RankingPage extends StatefulWidget {
  @override
  _RankingPageState createState() => _RankingPageState();
}

class _RankingPageState extends State<RankingPage> {
  final firestore = FirebaseFirestore.instance;
  @override
  void initState() {
    index = 0;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: backgroundBlue,
        appBar: AppBar(
          backgroundColor: backgroundBlue,
          elevation: 0,
          title: Image.asset('assets/logo.png', width: 95),
        ),
        body: SafeArea(
          child: FutureBuilder<QuerySnapshot>(
              future: firestore
                  .collection('Users')
                  .orderBy('globalToken', descending: true)
                  .get(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Something went wrong');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: Text(" "));
                }
                if (snapshot.hasData) {
                  try {
                    final docs = snapshot.data!.docs;
                    List<RankBuilder> rankList = [];
                    for (var doc in docs) {
                      index++;
                      int globalToken = doc['globalToken'];
                      String id = doc['id'].toString();

                      if (index < 4) {
                        final rankObject = RankBuilder(
                          globalToken: globalToken,
                          id: id,
                          index: index,
                        );
                        rankList.add(rankObject);
                      }
                      if (_currentPlayer.id == doc['id']) {
                        int myIdx = index;
                        print(myIdx);
                        final rankObject = RankBuilder(
                          globalToken: _currentPlayer.globalToken,
                          id: _currentPlayer.id,
                          index: myIdx,
                        );
                        rankList.add(rankObject);
                      }
                    }
                    return Expanded(
                        child: ListView(
                      children: rankList,
                    ));
                  } on Exception catch (e) {
                    return Center(
                      child: Text(' '),
                    );
                  }
                }
                return Text('loading');
              }),
        ));
  }
}

class RankBuilder extends StatefulWidget {
  RankBuilder({this.id, this.globalToken, this.index});
  final id;
  final globalToken;
  final index;
  @override
  _RankBuilderState createState() => _RankBuilderState();
}

class _RankBuilderState extends State<RankBuilder> {
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Text(widget.index.toString()),
      Text(widget.id),
      Text(widget.globalToken.toString()),
    ]);
  }
}
