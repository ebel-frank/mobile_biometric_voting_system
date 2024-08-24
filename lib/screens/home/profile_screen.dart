import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mbvs/models/user.model.dart';
import 'package:mbvs/states/data_provider.dart';
import 'package:provider/provider.dart';

import '../../common/utils.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final user = context.read<DataProvider>().getUser();
    double photoSize = size.width * 0.6;
    if (photoSize > 300) photoSize = 300;
    return Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
        ),
        body: SafeArea(
            child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: photoSize,
                  height: photoSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: CachedNetworkImageProvider(user.imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              RichText(
                  text: TextSpan(
                      text: "Name: ",
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                      ),
                      children: [
                    TextSpan(
                      text: user.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ])),
              const SizedBox(height: 10),
              RichText(
                  text: TextSpan(
                      text: "Gender: ",
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                      ),
                      children: [
                    TextSpan(
                      text: user.gender,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ])),
              const SizedBox(height: 10),
              RichText(
                  text: TextSpan(
                      text: "D.O.B: ",
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                      ),
                      children: [
                    TextSpan(
                      text: formatDate(user.dob),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ])),
              const SizedBox(height: 10),
              RichText(
                  text: TextSpan(
                      text: "Date of Registration: ",
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                      ),
                      children: [
                    TextSpan(
                      text: formatDate(user.regDate),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ])),
              const SizedBox(height: 10),
              RichText(
                  text: TextSpan(
                      text: "State of Origin: ",
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                      ),
                      children: [
                    TextSpan(
                      text: user.state,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ])),
            ],
          ),
        )));
  }
}
