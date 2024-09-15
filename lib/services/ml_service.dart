import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as imglib;

import '../common/utils.dart';
import '../models/user.model.dart';

class MLService {
  Interpreter? _interpreter;
  double threshold = 0.5;

  Map<int, List<double>> _predictedData = {};

  Map<int, List<double>> get predictedData => _predictedData;

  Future initialize() async {
    late Delegate delegate;
    try {
      if (Platform.isAndroid) {
        delegate = GpuDelegateV2(
          options: GpuDelegateOptionsV2(
            isPrecisionLossAllowed: false,
            /*inferencePreference: TfLiteGpuInferenceUsage.fastSingleAnswer,
            inferencePriority1: TfLiteGpuInferencePriority.minLatency,
            inferencePriority2: TfLiteGpuInferencePriority.auto,
            inferencePriority3: TfLiteGpuInferencePriority.auto,*/
          ),
        );
      } else if (Platform.isIOS) {
        delegate = GpuDelegate(
          options: GpuDelegateOptions(
            allowPrecisionLoss:
                true, /*waitType: TFLGpuDelegateWaitType.active*/
          ),
        );
      }
      var interpreterOptions = InterpreterOptions()..addDelegate(delegate);

      _interpreter = await Interpreter.fromAsset('assets/mobilefacenet.tflite',
          options: interpreterOptions);
    } catch (e) {
      debugPrint('Failed to load model.');
      debugPrint(e.toString());
    }
  }

  void setCurrentPrediction(CameraImage cameraImage, Face? face, int index) {
    if (_interpreter == null) throw Exception('Interpreter is null');
    if (face == null) throw Exception('Face is null');
    List input = _preProcess(cameraImage, face);

    input = input.reshape([1, 112, 112, 3]);
    List output = List.generate(1, (index) => List.filled(192, 0));

    _interpreter?.run(input, output);
    output = output.reshape([192]);

    _predictedData[index] = List.from(output);
  }

  Future<bool> predict(String userId) async {
    // const String apiUrl = 'http://192.168.1.1/api/verify_face';

    final Map<String, List<double>> encodedPredictedData =
        predictedData.map((key, value) => MapEntry(key.toString(), value));
    // final String predictedDataJson = jsonEncode(encodedPredictedData);

    final body = jsonEncode({
      'uid': userId,
      'predictedData': encodedPredictedData,
    });

    final Uri url =
        Uri.parse('https://item-finder-api.vercel.app/api/verify_face');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: body,
      );
      if (response.statusCode == 200) {
        // Decode the JSON response
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        return responseData['prediction'];
      } else {
        // Handle non-successful response
        return false;
      }
    } catch (e) {
      // debugPrint('An error occurred: $e');
      return false;
    }
  }

  List _preProcess(CameraImage image, Face faceDetected) {
    imglib.Image croppedImage = _cropFace(image, faceDetected);
    imglib.Image img = imglib.copyResizeCropSquare(croppedImage, size: 112);

    Float32List imageAsList = imageToByteListFloat32(img);
    return imageAsList;
  }

  imglib.Image _cropFace(CameraImage image, Face faceDetected) {
    imglib.Image convertedImage = _convertCameraImage(image);
    double x = faceDetected.boundingBox.left - 10.0;
    double y = faceDetected.boundingBox.top - 10.0;
    double w = faceDetected.boundingBox.width + 10.0;
    double h = faceDetected.boundingBox.height + 10.0;
    return imglib.copyCrop(convertedImage,
        x: x.round(), y: y.round(), width: w.round(), height: h.round());
  }

  imglib.Image _convertCameraImage(CameraImage image) {
    var img = convertToImage(image);
    var img1 = imglib.copyRotate(img, angle: -90);
    return img1;
  }

  Float32List imageToByteListFloat32(imglib.Image image) {
    var convertedBytes = Float32List(1 * 112 * 112 * 3);
    var buffer = Float32List.view(convertedBytes.buffer);
    int pixelIndex = 0;

    for (var i = 0; i < 112; i++) {
      for (var j = 0; j < 112; j++) {
        var pixel = image.getPixel(j, i);
        buffer[pixelIndex++] = (pixel.r.toInt() - 128) / 128;
        buffer[pixelIndex++] = (pixel.g.toInt() - 128) / 128;
        buffer[pixelIndex++] = (pixel.b.toInt() - 128) / 128;
      }
    }
    return convertedBytes.buffer.asFloat32List();
  }

  void setPredictedData(value) {
    _predictedData = value;
  }

  dispose() {}
}
