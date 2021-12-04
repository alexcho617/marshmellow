import 'package:flutter/material.dart';
import 'package:marshmallow/utils/colors.dart';
import 'package:marshmallow/utils/text.dart';
import 'package:marshmallow/services/models.dart';
import 'package:tflite/tflite.dart';
import 'package:camera/camera.dart';
import 'package:marshmallow/main.dart';

class LabPage extends StatefulWidget {
  @override
  _LabPageState createState() => _LabPageState();
}

class _LabPageState extends State<LabPage> {
  late CameraController cameraController;
  late CameraImage cameraImage;

  List? _result = [];
  initCamera() {
    cameraController = CameraController(cameras[0], ResolutionPreset.max);
    cameraController.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {
        cameraController.startImageStream((image) => {
              cameraImage = image,
              applyModelOnCamera(),
            });
      });
    });
  }

  @override
  void initState() {
    loadModel(1);
    initCamera();
    super.initState();
  }

  @override
  void dispose() {
    cameraController.stopImageStream();

    super.dispose();
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
          child: !cameraController.value.isInitialized
              ? Container()
              : CameraPreview(cameraController)),
    );
  }

  applyModelOnCamera() async {
    var res = await Tflite.detectObjectOnFrame(
      bytesList: cameraImage.planes.map((plane) {
        return plane.bytes;
      }).toList(), // required
      model: "YOLO",
      imageHeight: cameraImage.height,
      imageWidth: cameraImage.width,
      numResultsPerClass: 2, // defaults to 5
    );
    setState(() {
      _result = res;
      print(_result);
    });
  }
}
