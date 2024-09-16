import 'package:flutter/material.dart';
import 'package:mbvs/states/data_provider.dart';
import 'package:provider/provider.dart';

import '../../common/color.dart';
import '../../locator.dart';
import '../../services/ml_service.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key, required this.candidates});

  final List candidates;

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final MLService _mlService = locator<MLService>();
  late DataProvider provider;

  bool success = false;
  bool loading = true;

  void _verifyFace() async {
    // final savedFaceEmbeddings = provider.getFaceEmbeddings();
    final userId = provider.getUser().userId;
    // provider.saveFaceEmbedding(_mlService.predictedData);
    final isSameFace = await _mlService.predict(userId);
    if (mounted) {
      setState(() {
        success = isSameFace;
        loading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    provider = context.read<DataProvider>();
    Future.delayed(const Duration(seconds: 5), () {
      _verifyFace();
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: Scaffold(
          body: SafeArea(
            child: loading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : Column(children: [
                    Expanded(
                        child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                              success
                                  ? Icons.check_circle_outline
                                  : Icons.cancel_outlined,
                              size: size.width * 0.5,
                              color: success ? CustomColor.green : Colors.red),
                          Text(
                              "Verification ${success ? "Successful" : "Failed"}",
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    )),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: InkWell(
                        onTap: () async {
                          if (success) {
                            setState(() {
                              loading = true;
                            });
                            final errorMsg = await context
                                .read<DataProvider>()
                                .submitVote(widget.candidates);
                            setState(() {
                              loading = false;
                            });
                            if (errorMsg != null && context.mounted) {
                              showDialog(context: context, builder: (context)=>AlertDialog(
                                title: const Text("Error!"),
                                content: Text(errorMsg),
                                actions: [
                                  TextButton(onPressed: () {
                                    Navigator.pop(context);
                                  }, child: const Text("OK"))
                                ],
                              ));
                            } else if (context.mounted) {
                              Navigator.pushNamedAndRemoveUntil(
                                  context, '/home', (route) => false);
                            }
                          } else {
                            Navigator.pop(context);
                          }
                        },
                        child: Ink(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: CustomColor.green,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(
                            success ? 'Submit' : 'Try again',
                            style: const TextStyle(
                                fontSize: 15,
                                color: Colors.white,
                                letterSpacing: 2.5,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    )
                  ]),
          ),
        ));
  }
}
