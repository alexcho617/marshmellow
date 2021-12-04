import 'package:tflite/tflite.dart';

loadImageModel() async {
  var resultant = await Tflite.loadModel(
      labels: "assets/labels.txt",
      model:
          "assets/lite-model_imagenet_mobilenet_v3_small_100_224_classification_5_metadata_1.tflite");
  print("Result after loading model: $resultant");
}

loadObjectModel() async {
  var resultant = await Tflite.loadModel(
      // labels: "assets/labels.txt",
      model: "lite-model_yolo-v5-tflite_tflite_model_1");
  print("Result after loading model: $resultant");
}
