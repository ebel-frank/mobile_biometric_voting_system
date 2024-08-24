import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../common/color.dart';
import '../../widget/fade_animation.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: size.height * 0.06),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              FadeAnimation(
                delay: 1,
                child: SvgPicture.asset(
                  'assets/face.svg',
                  width: size.width * 0.5,
                  colorFilter: const ColorFilter.mode(CustomColor.green, BlendMode.srcIn)
                ),
              ),
              FadeAnimation(
                delay: 1.5,
                child: Text(
                  'MBVS',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: CustomColor.green,
                      letterSpacing: 3,
                    fontWeight: FontWeight.bold,
                    fontSize: size.height * 0.07,
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.01),
              FadeAnimation(
                delay: 2,
                child: Text(
                  'Mobile Biometric Voting System',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Expanded(child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FadeAnimation(
                      delay: 2.5,
                      child: InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, '/register');
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: CustomColor.green,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: const Text(
                            'Register',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                              letterSpacing: 2.5,
                              fontWeight: FontWeight.bold
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    FadeAnimation(
                      delay: 3,
                      child: InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, '/login');
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: const Text(
                            'Login',
                            style: TextStyle(
                                fontSize: 15,
                                letterSpacing: 2.5,
                                fontWeight: FontWeight.bold
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )),

            ],
          ),
        ),
      ),
    );
  }
}
