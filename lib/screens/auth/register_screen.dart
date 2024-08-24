import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mbvs/common/utils.dart';
import 'package:mbvs/states/data_provider.dart';
import 'package:mbvs/widget/custom_textfield.dart';
import 'package:provider/provider.dart';

import '../../common/color.dart';
import '../../common/consts.dart';
import '../../locator.dart';
import '../../services/ml_service.dart';
import '../../widget/custom_dropdown.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final ninController = TextEditingController();
  final passController = TextEditingController();
  final dobController = TextEditingController();
  final regController = TextEditingController();

  String location = "";
  int gender = -1;
  bool _hidePassword = true;

  DateTime dobDate = DateTime.now().subtract(const Duration(days: 365 * 18));
  final regDate = DateTime.now();

  final MLService _mlService = locator<MLService>();
  late FaceDetector faceDetector;
  String _face = "";

  @override
  void initState() {
    super.initState();
    final options =
        FaceDetectorOptions(performanceMode: FaceDetectorMode.accurate);
    faceDetector = FaceDetector(options: options);
  }

  @override
  void dispose() {
    nameController.dispose();
    ninController.dispose();
    passController.dispose();
    dobController.dispose();
    regController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final state = context.watch<DataProvider>().state;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
        centerTitle: true,
        scrolledUnderElevation: 0,
        elevation: 0,
      ),
      body: SingleChildScrollView(
          child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Full name',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 5),
            CustomTextField(
                controller: nameController,
                enabled: state == DataState.idle,
                hintText: "Enter your full name"),
            const SizedBox(height: 16),
            Text(
              'State of origin',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 5),
            CustomDropDown(
              menuEntries: const ['Select state', ...states],
              onSelected: (value) {
                location = value == 'Select state' ? "" : value;
              },
            ),
            const SizedBox(height: 16),
            Text(
              'Date of Birth (DOB)',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 5),
            CustomTextField(
                controller: dobController,
                hintText: "12 / 23 / 2024",
                readOnly: true,
                suffixIcon: IconButton(
                  icon: const Icon(
                    CupertinoIcons.calendar_today,
                    color: CupertinoColors.inactiveGray,
                  ),
                  onPressed: () {
                    final selectedDate = showDatePicker(
                      context: context,
                      initialDate: dobDate,
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now()
                          .subtract(const Duration(days: 365 * 18)),
                    );
                    selectedDate.then((value) {
                      if (value != null) {
                        setState(() {
                          dobDate = value;
                          dobController.text =
                              "${dobDate.day} / ${dobDate.month} / ${dobDate.year}";
                        });
                      }
                    });
                  },
                )),
            /*const SizedBox(height: 16),
            Text(
              'Date of Registration',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 5),
            CustomTextField(
                controller: regController,
                hintText: "12 / 23 / 2024",
              readOnly: true,
              suffixIcon: IconButton(
                icon: const Icon(
                  CupertinoIcons.calendar_today,
                  color: CupertinoColors.inactiveGray,
                ),
                onPressed: () {
                  final selectedDate = showDatePicker(
                    context: context,
                    initialDate: regDate,
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  selectedDate.then((value) {
                    if (value != null) {
                      setState(() {
                        dobDate = value;
                        regController.text =
                            "${dobDate.day} / ${dobDate.month} / ${dobDate.year}";
                      });
                    }
                  });
                },
              ),
            ),*/
            const SizedBox(height: 16),
            Text(
              'Face Verification',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(
              height: 5,
            ),
            InkWell(
              onTap: () async {
                final face = await Navigator.pushNamed(context, '/faceDetector');
                if (face != null && face is String) {
                  setState(() {
                    _face = face;
                  });
                }
              },
              child: Container(
                width: size.width * 0.5,
                height: size.width * 0.5,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(10),
                  image: _face.isEmpty
                      ? null
                      : DecorationImage(
                          image: FileImage(File(_face)),
                          fit: BoxFit.cover,
                        ),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  size: 50,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Gender',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Row(
              children: [
                SizedBox(
                  width: 24,
                  child: Radio(
                    value: 0,
                    groupValue: gender,
                    onChanged: (value) {
                      setState(() {
                        gender = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                const Text(
                  "Male",
                ),
                const SizedBox(
                  width: 16,
                ),
                SizedBox(
                  width: 24,
                  child: Radio(
                    value: 1,
                    groupValue: gender,
                    onChanged: (value) {
                      setState(() {
                        gender = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                const Text(
                  "Female",
                ),
              ],
            ),
            Text(
              'National Identification Number (NIN)',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 5),
            CustomTextField(
                controller: ninController,
                hintText: "Enter your 11 digit number",
                enabled: state == DataState.idle,
                keyboardType: TextInputType.number),
            const SizedBox(height: 16),
            Text(
              'Password',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 5),
            CustomTextField(
              controller: passController,
              hintText: "***********",
              // use dots
              obscureText: _hidePassword,
              enabled: state == DataState.idle,
              suffixIcon: IconButton(
                icon: Icon(
                  _hidePassword ? CupertinoIcons.eye : CupertinoIcons.eye_slash,
                  color: CupertinoColors.inactiveGray,
                ),
                onPressed: () {
                  // toggle password visibility
                  setState(() {
                    _hidePassword = !_hidePassword;
                  });
                },
              ),
            ),
            SizedBox(height: size.height * 0.05),
            InkWell(
              onTap: () async {
                if (nameController.text.isEmpty) {
                  showMessage(
                      context, "Required field", "Enter your full name");
                } else if (location.isEmpty) {
                  showMessage(
                      context, "Required field", "Select your state of origin");
                } else if (dobController.text.isEmpty) {
                  showMessage(
                      context, "Required field", "Select your date of birth");
                } else if (gender == -1) {
                  showMessage(context, "Required field", "Select your gender");
                } else if (ninController.text.isEmpty ||
                    ninController.text.length != 11) {
                  showMessage(context, "Required field",
                      "Enter your valid National Identification Number (NIN)");
                } else if (passController.text.isEmpty) {
                  showMessage(context, "Required field", "Enter your password");
                } else if (_face.isEmpty) {
                  showMessage(context, "Face verification required",
                      "Please perform face verification to continue");
                } else {
                  final provider = context.read<DataProvider>();
                  final embeddings = _mlService.predictedData;
                  String? errorMsg = await provider.register(
                      fullName: nameController.text.trim(),
                      state: location,
                      imagePath: _face,
                      embeddings: embeddings,
                      dob: dobDate.millisecondsSinceEpoch,
                      gender: gender == 0 ? 'Male' : 'Female',
                      nin: ninController.text.trim(),
                      password: passController.text.trim());
                  if (context.mounted) {
                    if (errorMsg != null) {
                      showMessage(context, "Error", errorMsg);
                    } else {
                      Navigator.pushNamedAndRemoveUntil(
                          context, '/home', (route) => false);
                    }
                  }
                }
              },
              child: Ink(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: CustomColor.green,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: state == DataState.register
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox.square(
                              dimension: 23,
                              child: Padding(
                                padding: EdgeInsets.all(4.0),
                                child: CircularProgressIndicator(
                                  strokeCap: StrokeCap.round,
                                  strokeWidth: 1.7,
                                  color: Colors.white,
                                ),
                              )),
                        ],
                      )
                    : const Text(
                        'Register',
                        style: TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                            letterSpacing: 2.5,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
              ),
            )
          ],
        ),
      )),
    );
  }
}
