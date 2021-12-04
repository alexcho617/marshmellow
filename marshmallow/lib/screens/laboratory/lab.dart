import 'package:flutter/material.dart';
import 'package:marshmallow/utils/colors.dart';
import 'package:marshmallow/utils/text.dart';
import 'package:marshmallow/services/models.dart';
import 'package:tflite/tflite.dart';
import 'package:camera/camera.dart';

class LabPage extends StatefulWidget {
  @override
  _LabPageState createState() => _LabPageState();
}

class _LabPageState extends State<LabPage> {
  late CameraController _camera;
  bool _cameraInitialized = false;
  late CameraImage _savedImage;

  void _initializeCamera() async {
    List<CameraDescription> cameras = await availableCameras();
    _camera = new CameraController(cameras[0], ResolutionPreset.veryHigh);
    _camera.initialize().then((_) async {
      await _camera
          .startImageStream((CameraImage image) => _processCameraImage(image));
      setState(() {
        _cameraInitialized = true;
      });
    });
  }

  void _processCameraImage(CameraImage image) async {
    setState(() {
      _savedImage = image;
    });
  }

  @override
  void initState() {
    loadModel(1);
    _initializeCamera();
    super.initState();
  }

  @override
  void dispose() {
    _camera.stopImageStream();
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
          child: !_camera.value.isInitialized
              ? Container()
              : AspectRatio(
                  aspectRatio: _camera.value.aspectRatio,
                  child: CameraPreview(_camera),
                )),
    );
  }

  // applyModelOnCamera() async {
  //   var res = await Tflite.detectObjectOnFrame(
  //     bytesList: cameraImage.planes.map((plane) {
  //       return plane.bytes;
  //     }).toList(), // required
  //     model: "YOLO",
  //     imageHeight: cameraImage.height,
  //     imageWidth: cameraImage.width,
  //     numResultsPerClass: 2, // defaults to 5
  //   );
  //   setState(() {
  //     _result = res;
  //     print(_result);
  //   });
  // }
}
