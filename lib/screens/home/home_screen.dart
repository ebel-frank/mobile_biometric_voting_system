import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mbvs/states/data_provider.dart';
import 'package:provider/provider.dart';

import '../../common/color.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  String _registeredVoters = "Loading...";
  List elections = [];

  @override
  void initState() {
    super.initState();
    FirebaseDatabase.instance.ref().child('registeredVoters').onValue.listen((event) {
      setState(() {
        _registeredVoters = event.snapshot.value.toString();
      });
    });
    FirebaseDatabase.instance.ref().child('election').onValue.listen((event) {
      setState(() {
        elections = (event.snapshot.value as Map).values.toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double boxSize = MediaQuery.of(context).size.width / 2;
    if (boxSize > 180) boxSize = 180;
    final user = context.read<DataProvider>().getUser();
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/profile');
            },
            child: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(user.imageUrl),
              backgroundColor: Colors.grey,
            ),
          ),
        ),
        title: const Text('MBVS'),
        actions: [
          // Popup menu for Logout
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Text('Log Out'),
              )
            ],
            onSelected: (value) {
              if (value == 'logout') {
                // clear user data
                // dialog to alert the user
                showDialog(context: context, builder: (context) => AlertDialog(
                  title: const Text('Log Out'),
                  content: const Text('Are you sure you want to log out?'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await context.read<DataProvider>().logOut();
                        Navigator.pushNamedAndRemoveUntil(
                            context, '/', (route) => false);
                      },
                      child: const Text('Log Out'),
                    )
                  ],
                ));
              }
            },
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                  text: TextSpan(
                      text: 'Total registered voters: ',
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                      children: [
                    TextSpan(
                      text: _registeredVoters,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    )
                  ])),
              const SizedBox(height: 32),
              Expanded(
                child: ListView.builder(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    itemCount: elections.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                elections[index]['title'].toString(),
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                height: 50,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: (elections[index]['candidates'] as List)
                                      .length,
                                  itemBuilder: (context, index2) {
                                    final candidate = (elections[index]['candidates']
                                        as List)[index2];
                                    return SizedBox(
                                      width: boxSize,
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                                image: DecorationImage(
                                                    image:
                                                        CachedNetworkImageProvider(
                                                            candidate[
                                                                'partyLogo']),
                                                    fit: BoxFit.cover)),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(candidate['name'].toString(),
                                              style: const TextStyle(
                                                  fontSize: 16)),
                                          const SizedBox(width: 8),
                                          Text(candidate['votes'].toString(),
                                              style: const TextStyle(
                                                  fontSize: 16)),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              )
                            ]),
                      );
                    }),
              ),
              InkWell(
                onTap: () {
                  if(!user.hasVoted) {
                    Navigator.pushNamed(context, '/voting');
                  }
                },
                borderRadius: BorderRadius.circular(100),
                child: Ink(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: user.hasVoted ? Colors.grey : CustomColor.green,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: const Text(
                    'Proceed to voting',
                    style: TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                        letterSpacing: 2.5,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
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
