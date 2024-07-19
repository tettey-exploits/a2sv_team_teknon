import 'dart:developer';
import 'dart:io';

import 'package:tflite/tflite.dart';
import '../constants/crop_diseases.dart';

class DiseaseDetection {
  loadModel() async {
    await Tflite.loadModel(
      model: "assets/afiricoco.tflite",
      labels: "assets/labels.txt",
    );
  }

  Future<String?> detectCropDisease({required File cropImage}) async {
    var output = await Tflite.runModelOnImage(
      path: cropImage.path,
      numResults: 2,
      threshold: 0.5,
      imageMean: 255,
      imageStd: 255,
    );

    if (output == null) {
      log("Failed to classify image");
      return null;
    }
    log("Disease: ${output[0]["label"].toString()}");

    String diseaseReport = getDiseaseReport(output[0]["label"].toString());
    log("Disease report: $diseaseReport");
    return diseaseReport;
  }
}
