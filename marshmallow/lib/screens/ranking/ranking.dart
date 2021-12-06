import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:marshmallow/models/user.dart';
import 'package:marshmallow/screens/home/home.dart';
import 'package:marshmallow/utils/colors.dart';
import 'package:get/get.dart';
import 'package:marshmallow/utils/text.dart';
import 'package:marshmallow/widgets/button.dart';

var _getArguments = Get.arguments;
GameUser _currentPlayer = _getArguments[0];

class RankingPage extends StatefulWidget {
  @override
  _RankingPageState createState() => _RankingPageState();
}

class _RankingPageState extends State<RankingPage> {
  final firestore = FirebaseFirestore.instance;
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
                    int myIdx = 0;
                    int myglobalToken = 0;
                    String myId = '';
                    var index = 0;
                    for (var doc in docs) {
                      index++;
                      int globalToken = doc['globalToken'];
                      String id = doc['id'].toString();
                      if (_currentPlayer.id == doc['id']) {
                        myIdx = index;
                        myglobalToken = doc['globalToken'];
                        myId = doc['id'].toString();
                      }
                      final rankObject = RankBuilder(
                        globalToken: globalToken,
                        id: id,
                        index: index,
                      );
                      rankList.add(rankObject);
                    }
                    return Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: size.width * 0.08),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 45),
                            child: Image.asset('assets/ranking.png'),
                          ),
                          Text(
                            '나의 랭킹',
                            style: body5style(),
                          ),
                          SizedBox(height: 11),
                          Container(
                            child: Row(children: [
                              Expanded(
                                flex: 1,
                                child:
                                    Text(myIdx.toString(), style: body5style()),
                              ),
                              Expanded(
                                flex: 5,
                                child: Text(myId, style: body5style()),
                              ),
                              Expanded(
                                flex: 2,
                                child: Image.asset('assets/m.png', height: 30),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(myglobalToken.toString(),
                                    style: body5style()),
                              ),
                            ]),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 20, bottom: 20),
                            child: Center(
                                child:
                                    Image.asset('assets/dots.png', width: 5)),
                          ),
                          Text(
                            '전체 랭킹',
                            style: body5style(),
                          ),
                          SizedBox(height: 20),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                  color: white.withOpacity(0.5),
                                  shape: BoxShape.rectangle,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15))),
                              padding: EdgeInsets.all(15),
                              child: ListView(
                                children: rankList,
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          Center(
                            child: mediumButtonTheme('홈으로', () {
                              Get.offAll(HomePage());
                            }),
                          ),
                        ],
                      ),
                    );
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
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: Row(children: [
        Expanded(
          flex: 1,
          child: Text(widget.index.toString(), style: body5style()),
        ),
        Expanded(
          flex: 5,
          child: Text(widget.id, style: body5style()),
        ),
        Expanded(
          flex: 1,
          child: Image.asset('assets/m.png', height: 20),
        ),
        Expanded(
          flex: 1,
          child: Text(
            widget.globalToken.toString(),
            style: body5style(),
            textAlign: TextAlign.center,
          ),
        ),
      ]),
    );
  }
}
