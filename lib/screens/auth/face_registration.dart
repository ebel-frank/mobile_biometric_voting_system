import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import '../../common/utils.dart';
import '../../locator.dart';
import '../../services/camera_service.dart';
import '../../services/face_detector_service.dart';
import '../../services/ml_service.dart';
import '../../widget/camera_header.dart';

class FaceRegistrationScreen extends StatefulWidget {
  const FaceRegistrationScreen({super.key});

  @override
  FaceRegistrationScreenState createState() => FaceRegistrationScreenState();
}

class FaceRegistrationScreenState extends State<FaceRegistrationScreen> {
  String? imagePath;
  Face? faceDetected;
  Size? imageSize;

  bool _detectingFaces = false;
  bool pictureTaken = false;

  bool _initializing = false;

  // service injection
  final FaceDetectorService _faceDetectorService =
      locator<FaceDetectorService>();
  final CameraService _cameraService = locator<CameraService>();
  final MLService _mlService = locator<MLService>();

  static List<Color> listColors = [
    Colors.grey.shade200,
    Colors.green.shade50,
    Colors.green.shade100,
    Colors.green.shade200,
    Colors.green.shade400,
    Colors.green.shade500,
  ];
  static List<String> listState = [
    "Put your face on frame",
    "Slowly Blink your eyes",
    "Slowly Turn head right",
    "Slowly Turn head left",
    "Finally, Smile...",
    "OK",
  ];
  String firstFace = "";
  Map<int, Face> faces = {};

  int stepIndex = 0;
  double faceHeightOffset = 500;
  double headZAnagleOffset = 1.0;
  double blinkOffset = 0.15;
  double headZAnagleBase = 0.0;
  int bottomMouthBase = 0;
  int bottomMouthBaseOffset = 50;
  double smileProbabilityThreshold = 0.8;

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void dispose() {
    _cameraService.dispose();
    _mlService.dispose();
    _faceDetectorService.dispose();
    super.dispose();
  }

  _start() async {
    try {
      setState(() => _initializing = true);
      await _cameraService.initialize();
      await _mlService.initialize();
      _faceDetectorService.initialize();
      setState(() => _initializing = false);

      _frameFaces();
    } catch (e) {
      debugPrint("Strange error: $e");
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  _changeStateDetection(int state) {
    setState(() {
      stepIndex = state;
    });
  }

  _saveDetectedFace(int index, CameraImage image, Face face) async {
    if (index == 0) {
      XFile? file = await _cameraService.takePicture();
      firstFace = file!.path;
    }
    faces[index] = face;
  }

  _frameFaces() {
    imageSize = _cameraService.getImageSize();

    _cameraService.cameraController?.startImageStream((image) async {
      if (_cameraService.cameraController != null) {
        if (_detectingFaces) return;

        _detectingFaces = true;

        try {
          await _faceDetectorService.detectFacesFromImage(image);

          log('found face = ${_faceDetectorService.faces.length}');
          if (_faceDetectorService.faces.isNotEmpty) {
            log('detect landmark');
            setState(() {
              faceDetected = _faceDetectorService.faces[0];
            });

            // step 1 ask user for face detection
            final Rect boundingBox = faceDetected!.boundingBox;

            final noseBase = faceDetected!.landmarks[FaceLandmarkType.noseBase];

            final leftEyeOpen = faceDetected!.leftEyeOpenProbability;
            final rightEyeOpen = faceDetected!.rightEyeOpenProbability;

            final headEulerAngleZ = faceDetected!.headEulerAngleZ;
            final smilingProbability = faceDetected!.smilingProbability;

            log('face distance : ${boundingBox.height}');
            log('face center : ${boundingBox.center.distance}');

            log('nose postion : x=${noseBase!.position.x}, y=${noseBase.position.y}');

            log('left eye open : $leftEyeOpen');
            log('right eye open : $rightEyeOpen');

            log('smiling probability : $smilingProbability');

            log('head angle z : $headEulerAngleZ');

            log('detection step : $stepIndex');

            // check when face in frame
            if (boundingBox.height > faceHeightOffset) {
              // if already check found and in frame
              if (stepIndex < 1) {
                _changeStateDetection(1);
              }
            } else {
              _changeStateDetection(0);
            }

            // if face is already in frame
            if (stepIndex > 0) {
              switch (stepIndex) {
                case 1:
                  {
                    log('step blink detection');
                    if ((leftEyeOpen! < blinkOffset) &&
                        (rightEyeOpen! < blinkOffset)) {
                      log('step blink detection : yes');
                      headZAnagleBase = headEulerAngleZ!;
                      _changeStateDetection(2);
                      _saveDetectedFace(0, image, faceDetected!);
                    }
                  }
                  break;
                case 2:
                  {
                    log('head base $headZAnagleBase');
                    log('step turn head left detection : ${(headEulerAngleZ)} ');
                    if (headEulerAngleZ! <
                        (headZAnagleBase - headZAnagleOffset)) {
                      log('step turn head left detection : yes');
                      _changeStateDetection(3);
                      _saveDetectedFace(1, image, faceDetected!);
                    }
                  }
                  break;

                case 3:
                  {
                    log('step face turn right detection : ${(headEulerAngleZ)}');
                    if (headEulerAngleZ! >
                        (headZAnagleBase + headZAnagleOffset)) {
                      log('step turn head righ : yes');
                      _changeStateDetection(4);
                      _saveDetectedFace(2, image, faceDetected!);
                    }
                  }
                  break;

                case 4:
                  {
                    log('step smile detection');
                    if (smilingProbability! > smileProbabilityThreshold) {
                      log('step smile detection : yes');
                      await _saveDetectedFace(3, image, faceDetected!);
                      setState(() {
                        _initializing = true;
                      });
                      for (int i = 0; i < 4; i++) {
                        _mlService.setCurrentPrediction(image, faces[i], i);
                      }
                      await _cameraService.cameraController?.stopImageStream();
                      if (mounted) {
                        Navigator.of(context).pop(firstFace);
                      }
                    }
                  }
                  break;
              }
            }
          } else {
            debugPrint('face is null');
            setState(() {
              faceDetected = null;
              stepIndex = 0;
            });
          }

          _detectingFaces = false;
        } catch (e) {
          debugPrint('Error _faceDetectorService face => $e');
          _detectingFaces = false;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const double mirror = math.pi;
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    late Widget body;
    if (_initializing) {
      body = const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (!_initializing && pictureTaken) {
      body = SizedBox(
        width: width,
        height: height,
        child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.rotationY(mirror),
            child: FittedBox(
              fit: BoxFit.cover,
              child: Image.file(File(imagePath!)),
            )),
      );
    }

    if (!_initializing && !pictureTaken) {
      var scale =
          (width / height) * _cameraService.cameraController!.value.aspectRatio;
      if (scale < 1) scale = 1 / scale;
      body = Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: Transform.scale(
                scale: scale,
                child: CameraPreview(_cameraService.cameraController!)),
          ),
          Positioned.fill(
            child: CustomPaint(
              painter: BoxPainter(
                Rect.fromCenter(
                  center: Offset(width / 2, height / 2),
                  width: width * 0.8, // Width of the bounding box
                  height: width * 1.2, // Height of the bounding box
                ),
                listColors[stepIndex],
              ),
            ),
          ),
          Positioned(
            bottom: width * 0.2,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                listState[stepIndex],
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                    ),
              ),
            ),
          )
        ],
      );
    }

    return Scaffold(
        body: Stack(
          children: [
            body,
            CameraHeader(
              "Facial Verification",
              onBackPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: /*!_bottomSheetVisible
            ? AuthActionButton(
                onPressed: onShot,
                isLogin: false,
                reload: _reload,
              )
            :*/
            Container());
  }
}

class BoxPainter extends CustomPainter {
  final Rect boxRect;
  final Color color;

  BoxPainter(this.boxRect, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final ovalPath = Path()..addOval(boxRect);

    final overlayPaint = Paint()..color = Colors.black45;

    final outerPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final differencePath =
        Path.combine(PathOperation.difference, outerPath, ovalPath);

    canvas.drawPath(differencePath, overlayPaint);
    canvas.drawPath(
        ovalPath,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
