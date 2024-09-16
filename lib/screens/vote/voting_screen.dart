import 'package:flutter/material.dart';

import '../../common/color.dart';

class VotingScreen extends StatefulWidget {
  const VotingScreen({super.key});

  @override
  State<VotingScreen> createState() => _VotingScreenState();
}

class _VotingScreenState extends State<VotingScreen> {
  final categories = [
    'Presidential Elections',
    'Gubernatorial Elections',
    'Senatorial Elections',
  ];

  final selections = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voting'),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Select vote category',
                style: TextStyle(fontSize: 16),
              ),
            ),
            Expanded(
                child: ListView.builder(
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      return CheckboxListTile(
                        title: Text(categories[index]),
                        value: selections[categories[index]] != null,
                        onChanged: (bool? value) async {
                          final result = await Navigator.pushNamed(context, '/voting_page', arguments: {
                            'category': categories[index],
                          });
                          if (result != null) {
                            setState(() {
                              selections[categories[index]] = result;
                            });
                          }
                        },
                      );
                    })),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: InkWell(
                onTap: () {
                  if(selections.length != categories.length) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Please vote for all categories'),
                    ));
                    return;
                  }
                  final candidates = [];
                  for (final category in selections.keys) {
                    candidates.add({
                      'category': category,
                      'candidate': selections[category],
                    });
                  }
                  Navigator.pushNamed(context, '/verify_vote', arguments: candidates);
                },
                child: Ink(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: selections.length != categories.length ? Colors.grey : CustomColor.green,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: const Text(
                    'Proceed',
                    style: TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                        letterSpacing: 2.5,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
