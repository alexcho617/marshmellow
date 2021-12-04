import 'package:flutter/material.dart';
import 'package:marshmallow/utils/colors.dart';
import 'package:marshmallow/utils/text.dart';
import 'package:image_picker/image_picker.dart';
import 'package:marshmallow/services/firebase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:marshmallow/services/models.dart';
import 'package:tflite/tflite.dart';

class LabPage extends StatefulWidget {
  @override
  _LabPageState createState() => _LabPageState();
}

class _LabPageState extends State<LabPage> {
  final firestore = FirebaseFirestore.instance;
  XFile? imageURI;
  final ImagePicker _picker = ImagePicker();
  List? _result = [];
  String _name = "";

  @override
  void initState() {
    super.initState();
    checkFirebaseUser();
    loadModel(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundBlue,
      appBar: AppBar(
        backgroundColor: backgroundBlue,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [point2style(data: 'GAMEZONE')]),
      ),
      body: SafeArea(
          child: Column(
        children: [
          TextButton(
            child: Text('select'),
            onPressed: () {
              getImageFromCameraGallery(false);
            },
          ),
          Text(_name),
        ],
      )),
    );
  }

  Future getImageFromCameraGallery(bool isCamara) async {
    final XFile? image = await _picker.pickImage(
        source: (isCamara == true) ? ImageSource.camera : ImageSource.gallery);
    if (image != null) {
      setState(() {
        imageURI = image;
      });
      await applyModelOnImage(imageURI);
    } else {
      return 0;
    }
  }

  applyModelOnImage(XFile? file) async {
    var res = await Tflite.detectObjectOnImage(
        path: file!.path, // required
        model: "YOLO",
        imageMean: 0.0,
        imageStd: 255.0,
        threshold: 0.3, // defaults to 0.1
        numResultsPerClass: 2, // defaults to 5
        anchors: [
          0.57273,
          0.677385,
          1.87446,
          2.06253,
          3.33843,
          5.47434,
          7.88282,
          3.52778,
          9.77052,
          9.16828
        ], // defaults
        blockSize: 32, // defaults to 32
        numBoxesPerBlock: 5, // defaults to 5
        asynch: true // defaults to true
        );
    setState(() {
      _result = res;
      print(_result.toString());
    });
  }
}
