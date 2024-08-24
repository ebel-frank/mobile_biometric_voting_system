import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import '../locator.dart';
import 'camera_service.dart';

class FaceDetectorService {
  final CameraService _cameraService = locator<CameraService>();

  late FaceDetector _faceDetector;

  FaceDetector get faceDetector => _faceDetector;

  List<Face> _faces = [];

  List<Face> get faces => _faces;

  void initialize() {
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableLandmarks: true,
        enableTracking: true,
        enableClassification: true,
        enableContours: true,
      ),
    );
  }

  Future<void> detectFacesFromImage(CameraImage image) async {
    InputImageMetadata firebaseImageMetadata = InputImageMetadata(
      rotation:
          _cameraService.cameraRotation ?? InputImageRotation.rotation0deg,

      // inputImageFormat: InputImageFormat.yuv_420_888,

      format: InputImageFormatValue.fromRawValue(image.format.raw)
          // InputImageFormatMethods.fromRawValue(image.format.raw) for new version
          ??
          InputImageFormat.yuv_420_888,
      size: Size(image.width.toDouble(), image.height.toDouble()),
      bytesPerRow: image.planes.first.bytesPerRow,
    );

    // for mlkit 13
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    InputImage firebaseVisionImage = InputImage.fromBytes(
      // bytes: image.planes[0].bytes,
      bytes: bytes,
      metadata: firebaseImageMetadata,
    );
    // for mlkit 13

    _faces = await _faceDetector.processImage(firebaseVisionImage);
  }

  dispose() {
    _faceDetector.close();
  }

}
