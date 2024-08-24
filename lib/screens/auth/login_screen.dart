import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:simple_animations/animation_builder/loop_animation_builder.dart';
import 'package:simple_animations/animation_builder/mirror_animation_builder.dart';
import 'package:simple_animations/movie_tween/movie_tween.dart';

import '../../common/color.dart';
import '../../common/utils.dart';
import '../../states/data_provider.dart';
import '../../widget/custom_textfield.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final ninController = TextEditingController();
  final passController = TextEditingController();
  bool _hidePassword = true;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final state = context.watch<DataProvider>().state;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'National Identification Number (NIN)',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 5),
            CustomTextField(
              controller: ninController,
              hintText: "Enter your 11 digit number",
              enabled: state == DataState.idle,
              keyboardType: TextInputType.number,
              /*onChanged: (value) {
                if (value.length >= 11) {
                  debugPrint("Exceeded 9 characters");
                  showAdaptiveDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) {
                        return WillPopScope(
                          onWillPop: () async => false,
                          child: Center(
                            child: SizedBox(
                                width: size.width * 0.6,
                                child: Lottie.asset('assets/loading.json')),
                          ),
                        );
                      });
                  Future.delayed(const Duration(seconds: 5), () {
                    Navigator.pop(context);
                    ninController.clear();
                    // Show the reason for failure
                  });
                  // check if NIN is register
                  // if registered, navigate to home
                  // else, navigate to register
                } else {
                  // _loading = true;
                }
              },*/
            ),
            const SizedBox(
              height: 16,
            ),
            Text(
              'Password',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 5),
            CustomTextField(
              controller: passController,
              hintText: "***********", // use dots
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
            SizedBox(height: size.height * 0.1),
            InkWell(
              onTap: () async {
                if (ninController.text.isEmpty ||
                    ninController.text.length != 11) {
                  showMessage(context, "Required field",
                      "Enter your valid National Identification Number (NIN)");
                } else if (passController.text.isEmpty) {
                  showMessage(context, "Required field", "Enter your password");
                } else {
                  final provider = context.read<DataProvider>();
                  String? errorMsg = await provider.logIn(
                    nin: ninController.text.trim(),
                    password: passController.text.trim()
                  );
                  if (context.mounted) {
                    if (errorMsg != null) {
                      showMessage(context, "Error", errorMsg);
                    } else {
                      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
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
                child: state == DataState.login
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
                  'Login',
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
      ),
    );
  }
}
