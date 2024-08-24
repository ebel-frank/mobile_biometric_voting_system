import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image/image.dart' as imgLib;
import 'package:intl/intl.dart';

imgLib.Image convertToImage(CameraImage image) {
  try {
    print('image.format.group=>${image.format.group}');
    if (image.format.group == ImageFormatGroup.yuv420) {
      return _convertYUV420(image);
    } else if (image.format.group == ImageFormatGroup.bgra8888) {
      return _convertBGRA8888(image);
    }
    throw Exception('Image format not supported');
  } catch (e) {
    print("ERROR:" + e.toString());
  }
  throw Exception('Image format not supported');
}

imgLib.Image _convertBGRA8888(CameraImage image) {
  return imgLib.Image.fromBytes(
    width: image.width,
    height: image.height,
    bytes: image.planes[0].bytes.buffer,
  );
}

imgLib.Image _convertYUV420(CameraImage image) {
  int width = image.width;
  int height = image.height;
  var img = imgLib.Image(width: width, height: height);
  const int hexFF = 0xFF000000;
  final int uvyButtonStride = image.planes[1].bytesPerRow;
  final int? uvPixelStride = image.planes[1].bytesPerPixel;
  for (int x = 0; x < width; x++) {
    for (int y = 0; y < height; y++) {
      final int uvIndex =
          uvPixelStride! * (x / 2).floor() + uvyButtonStride * (y / 2).floor();
      final int index = y * width + x;
      final yp = image.planes[0].bytes[index];
      final up = image.planes[1].bytes[uvIndex];
      final vp = image.planes[2].bytes[uvIndex];
      int r = (yp + vp * 1436 / 1024 - 179).round().clamp(0, 255);
      int g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91)
          .round()
          .clamp(0, 255);
      int b = (yp + up * 1814 / 1024 - 227).round().clamp(0, 255);
      img.data?.setPixelRgba(x, y, r, (g << 8), (b << 16), hexFF); // TODO
    }
  }

  return img;
}

Future showMessage(BuildContext context, String? title, String content,
    {Widget Function(BuildContext)? customAction,
      Widget Function(BuildContext)? popAction,
      String? popText,
      TextStyle? titleTextStyle}) {
  return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        contentPadding: const EdgeInsets.only(
          left: 24.0,
          top: 10.0,
          right: 24.0,
          bottom: 25.0,
        ),
        insetPadding:
        const EdgeInsets.symmetric(horizontal: 30.0, vertical: 24.0),
        actionsPadding: const EdgeInsets.all(8),
        titleTextStyle: titleTextStyle,
        title: title == null ? null : Text(title),
        content: Text(content),
        actions: [
          if (popAction != null)
            popAction(context)
          else
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(popText ??
                  "OK"),
            ),
          if (customAction != null)
            customAction(context)
          else
            const SizedBox.shrink()
        ],
      ));
}

String formatDate(int timestamp) {
  DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp);
  return DateFormat('d MMMM, yyyy').format(date);
}

Future<Uint8List> compress(String imagePath) async {
  final result = await FlutterImageCompress.compressWithFile(
    imagePath,
    quality: 55,
  );
  if (result == null) {
    throw Exception('Error compressing image');
  }
  return result;
}

Future<String> uploadImageToFirebaseStorage(Uint8List imageFile,
    String pickedFilePath, String userId, String path) async {
  try {
    Reference storageReference =
    FirebaseStorage.instance.ref().child('$userId/$path');

    final metadata = SettableMetadata(
      contentType: 'image/jpeg',
      customMetadata: {'picked-file-path': pickedFilePath},
    );
    // Upload the file to the specified path
    UploadTask uploadTask = storageReference.putData(imageFile, metadata);

    // Wait for the upload to complete and retrieve the download URL
    TaskSnapshot snapshot = await uploadTask;

    // return the download URL (you can use this URL to access the uploaded image)
    return await snapshot.ref.getDownloadURL();
  } catch (error) {
    throw Exception('Error uploading image: $error');
  }
}
