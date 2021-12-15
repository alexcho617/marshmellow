import 'package:tflite/tflite.dart';

loadModel(int modelIdx) async {
  var resultant;
  if (modelIdx == 0) {
    resultant = await Tflite.loadModel(
        labels: "assets/labels.txt",
        model:
            "assets/lite-model_imagenet_mobilenet_v3_small_100_224_classification_5_metadata_1.tflite");
  } else if (modelIdx == 1) {
    resultant = await Tflite.loadModel(model: "assets/tiny_yolo.tflite");
  }
  print("Result after loading model: $resultant");
}
