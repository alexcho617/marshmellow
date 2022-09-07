import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:marshmallow/utils/colors.dart';
import 'package:marshmallow/utils/text.dart';
import 'package:marshmallow/services/models.dart';
import 'package:tflite/tflite.dart';
import 'package:camera/camera.dart';
import 'package:get/get.dart';

class LabPage extends StatefulWidget {
  @override
  _LabPageState createState() => _LabPageState();
}

class _LabPageState extends State<LabPage> {
  late CameraController _cameraController;
  List? _result = [];

  Future<void> _initializeCamera() async {
    try {
      List<CameraDescription> cameras = await availableCameras();
      _cameraController = CameraController(cameras[0], ResolutionPreset.medium);
    } on Exception catch (e) {
      print("no Available Camera");
    }
  }

  Future<void> _initializeControllerFuture() async {
    _cameraController.initialize();
  }

  @override
  void initState() {
    loadModel(1);
    _initializeCamera();
    _initializeControllerFuture();
    super.initState();
  }

  @override
  void dispose() {
    _cameraController.dispose();
    Tflite.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        body: SafeArea(
          child: FutureBuilder<void>(
            future: _initializeControllerFuture(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return CameraPreview(_cameraController);
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            try {
              final image = await _cameraController.takePicture();
              applyModelOnCamera(image);
              await Get.to(TakePicture(
                imagePath: image.path,
              ));
              setState(() {
                _initializeControllerFuture();
              });
            } catch (e) {
              print(e);
            }
          },
          child: const Icon(Icons.camera_alt),
        ),
      ),
    );
  }

  applyModelOnCamera(XFile? file) async {
    var res = await Tflite.detectObjectOnImage(
      path: file!.path, // required
      model: "YOLO",
      imageMean: 0.0,
      imageStd: 255.0,
      threshold: 0.3, // defaults to 0.1
      numResultsPerClass: 2, // defaults to 5
    );
    setState(() {
      _result = res;
      print(_result);
    });
  }
}

class TakePicture extends StatelessWidget {
  TakePicture({required this.imagePath});
  final imagePath;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Column(
        children: [
          Image.file(File(imagePath)),
          Text('label'),
        ],
      )),
    );
  }
}
