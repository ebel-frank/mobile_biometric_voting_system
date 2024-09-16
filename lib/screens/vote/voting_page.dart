import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../common/color.dart';

class VotingPage extends StatefulWidget {
  const VotingPage({super.key});

  @override
  State<VotingPage> createState() => _VotingPageState();
}

class _VotingPageState extends State<VotingPage> {
  final candidates = {
    "Presidential Elections": [
      {
        'imageUrl':
            'https://pbs.twimg.com/profile_images/1050783097934020608/2_bhBolN_400x400.jpg',
        'party': 'LP',
        'name': 'Peter Obi',
        'gender': 'Male',
      },
      {
        'imageUrl':
            'https://encrypted-tbn2.gstatic.com/images?q=tbn:ANd9GcRPdIHbhaEqsU_YGSKRX6TDCjYrBRR-rs-yJl_0TInmksIdCnw3',
        'party': 'APC',
        'name': 'Bola Ahmed Tinubu',
        'gender': 'Male'
      },
      {
        'imageUrl':
            'https://cdn.vanguardngr.com/wp-content/uploads/2022/11/Atiku-Abubakar-3.jpg',
        'party': 'PDP',
        'name': 'Atiku Abubakar',
        'gender': 'Male',
      },
    ],
    "Gubernatorial Elections": [
      {
        'imageUrl':
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQj4rqREf757TmaDovG5CGLp4Efl3ZYQmZxEA&s',
        'party': 'APC',
        'name': 'Babajide Sanwo-olu',
        'gender': 'Male'
      },
      {
        'imageUrl':
            'https://global.ariseplay.com/amg/www.thisdaylive.com/uploads/Gbadebo-Rhodes-Vivour.jpeg',
        'party': 'LP',
        'name': 'Gbadebo Rhodes Vivour',
        'gender': 'Male'
      },
      {
        'imageUrl':
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcScDUPqgGgiFLYTJuSR8LU05BkBD4x2DfkEtQ&s',
        'party': 'PDP',
        'name': 'Nyesom Wike',
        'gender': 'Male'
      },
    ],
    "Senatorial Elections": [
      {
        'imageUrl':
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQTfZsrmgMlqzguKLLKNKXPgTdUBotQG7mxew&s',
        'party': 'PDP',
        'name': 'Phlip Aduda',
        'gender': 'Male'
      },
      {
        'imageUrl':
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTSAF3V4aMzD_-RTzTsZ38QIg9q4ZTP6kAtmQ&s',
        'party': 'APC',
        'name': 'Zakari Angulu Dobi',
        'gender': 'Male'
      },
      {
        'imageUrl':
            'https://pbs.twimg.com/profile_images/1664605788201943041/JI5l6d8C_400x400.jpg',
        'party': 'LP',
        'name': 'Ireti Kingibe',
        'gender': 'Female'
      },
    ]
  };
  late String title;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final category = ModalRoute.of(context)!.settings.arguments as Map?;
    title = category!['category'];
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width * 0.6;
    if (width > 300) width = 300;
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: candidates[title]!.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: width,
                                width: width,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(10),
                                  image: DecorationImage(
                                    image: CachedNetworkImageProvider(
                                        candidates[title]![index]['imageUrl']
                                            .toString()),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Text(
                                "Name: ${candidates[title]?[index]['name']}",
                                style: const TextStyle(fontSize: 16),
                              ),
                              Text(
                                "Party: ${candidates[title]?[index]['party']}",
                                style: const TextStyle(fontSize: 16),
                              ),
                              Text(
                                "Gender: ${candidates[title]?[index]['gender']}",
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 10),
                              InkWell(
                                onTap: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                            title: const Text('Vote'),
                                            content: const Text(
                                                'Are you sure you want to vote for this candidate?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: const Text('No'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                  Navigator.pop(
                                                      context,
                                                      candidates[title]
                                                          ?[index]);
                                                },
                                                child: const Text('Yes'),
                                              ),
                                            ],
                                          ));
                                },
                                borderRadius: BorderRadius.circular(100),
                                child: Ink(
                                  width: width,
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: CustomColor.green,
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  child: Text(
                                    'VOTE ${candidates[title]?[index]['party']}',
                                    style: const TextStyle(
                                        fontSize: 15,
                                        color: Colors.white,
                                        letterSpacing: 2.5,
                                        fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ]),
                      );
                    })),
          ],
        ),
      ),
    );
  }
}
