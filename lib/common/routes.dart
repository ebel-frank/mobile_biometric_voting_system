import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:mbvs/screens/auth/intro_screen.dart';
import 'package:mbvs/screens/auth/login_screen.dart';
import 'package:mbvs/screens/auth/register_screen.dart';
import 'package:mbvs/screens/home/home_screen.dart';
import 'package:mbvs/screens/vote/voting_page.dart';
import 'package:mbvs/screens/vote/voting_screen.dart';
import 'package:mbvs/screens/vote/vote_verification.dart';

import '../screens/auth/face_registration.dart';
import '../screens/home/profile_screen.dart';

Widget initialRoute() {
  return Hive.box('cache').get('user', defaultValue: null) != null
      ? const HomeScreen()
      : const IntroScreen();
}

final Map<String, Widget Function(BuildContext)> namedRoutes = {
  '/': (context) => initialRoute(),
  '/register': (context) => const RegisterScreen(),
  '/login': (context) => const LoginScreen(),
  '/faceDetector': (context) => const FaceRegistrationScreen(),
  '/home': (context) => const HomeScreen(),
  '/voting': (context) => const VotingScreen(),
  '/voting_page': (context) => const VotingPage(),
  '/verify_vote': (context) {
    final args = ModalRoute.of(context)?.settings.arguments as List;
    return VoteVerificationScreen(candidates: args);
  },
  '/profile': (context) => const ProfileScreen(),
};
