import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mbvs/screens/auth/verification_screen.dart';
import 'package:simple_animations/animation_builder/mirror_animation_builder.dart';

import '../../common/color.dart';

class VoteVerificationScreen extends StatefulWidget {
  const VoteVerificationScreen({super.key, required this.candidates});

  final List candidates;

  @override
  State<VoteVerificationScreen> createState() => _VoteVerificationScreenState();
}

class _VoteVerificationScreenState extends State<VoteVerificationScreen> {

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    double width = size.width * 0.6;
    if (width > 300) width = 300;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vote Verification'),
        scrolledUnderElevation: 0,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ...widget.candidates.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['category'].toString(),
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            height: width,
                            width: width,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(10),
                              image: DecorationImage(
                                image: CachedNetworkImageProvider(
                                    (item['candidate'] as Map)['partyLogo']
                                        .toString()),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Text(
                            "Name: ${(item['candidate'] as Map)['name']}",
                            style: const TextStyle(fontSize: 16),
                          ),
                          Text(
                            "Party: ${(item['candidate'] as Map)['party']}",
                            style: const TextStyle(fontSize: 16),
                          ),
                          Text(
                            "Gender: ${(item['candidate'] as Map)['gender']}",
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 10),
                          const Divider()
                        ]),
                  )),
              SizedBox(height: size.height * 0.05),
              Text(
                'Tap to verify your identity',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () async {
                  final face = await Navigator.pushNamed(context, '/faceDetector');
                  if (face!=null && face is String && context.mounted) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const VerificationScreen()));
                  }
                },
                child: SizedBox(
                  height: size.width * 0.5,
                  child: MirrorAnimationBuilder<double>(
                    // mandatory parameters
                    tween: Tween<double>(
                        begin: size.width * 0.4, end: size.width * 0.5),
                    duration: const Duration(seconds: 1),
                    curve: Curves.easeInOut,
                    builder: (context, value, child) {
                      return SizedBox(
                          width: value, height: value, child: child);
                    },
                    child: SvgPicture.asset('assets/face_recognition.svg',
                        /*width: size.width * 0.5,*/
                        colorFilter: const ColorFilter.mode(
                            CustomColor.green, BlendMode.srcIn)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
