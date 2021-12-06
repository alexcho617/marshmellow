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
  late CameraController cameraController;
  late CameraImage cameraImage;
  List? res = [];

  void _initializeCamera() async {
    try {
      List<CameraDescription> cameras = await availableCameras();
      cameraController = CameraController(cameras[0], ResolutionPreset.medium);
      cameraController.initialize().then((value) {
        setState(() {
          cameraController.startImageStream((image) => {
                cameraImage = image,
                // applyModelOnCamera(),
              });
        });
      });
    } catch (e) {
      print("error of initialize Camera");
    }
  }

  @override
  void initState() {
    loadModel(1);
    _initializeCamera();
    super.initState();
  }

  @override
  void dispose() {
    cameraController.stopImageStream();
    Tflite.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    List<Widget> list = [];
    list.add(
      Positioned(
        top: 0.0,
        left: 0.0,
        width: size.width,
        height: size.height - 100,
        child: Container(
          height: size.height - 100,
          child: (!cameraController.value.isInitialized)
              ? new Container()
              : AspectRatio(
                  aspectRatio: cameraController.value.aspectRatio,
                  child: CameraPreview(cameraController),
                ),
        ),
      ),
    );

    return SafeArea(
      child: Scaffold(
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
        body: Container(
          margin: EdgeInsets.only(top: 50),
          color: Colors.black,
          child: Stack(
            children: list,
          ),
        ),
      ),
    );
  }

  applyModelOnCamera() async {
    res = await Tflite.detectObjectOnFrame(
      bytesList: cameraImage.planes.map((plane) {
        return plane.bytes;
      }).toList(),
      imageHeight: cameraImage.height,
      imageWidth: cameraImage.width,
      imageMean: 127.5,
      imageStd: 127.5,
      numResultsPerClass: 1,
      threshold: 0.4,
    );

    setState(() {
      cameraImage;
    });
  }
}
