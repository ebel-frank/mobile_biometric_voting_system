import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:mbvs/common/color.dart';
import 'package:mbvs/states/data_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import 'common/routes.dart';
import 'firebase_options.dart';
import 'locator.dart';

const hiveBoxes = [
  {'name': 'cache', 'limit': false},
];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupServices();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await Hive.initFlutter('mbvs/Database');
  } else if (Platform.isIOS) {
    await Hive.initFlutter('Database');
  } else {
    await Hive.initFlutter();
  }
  for (final box in hiveBoxes) {
    await openHiveBox(
      box['name'].toString(),
      limit: box['limit'] as bool? ?? false,
    );
  }

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => DataProvider()),
    ],
    child: MaterialApp(
      title: 'MBVS',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: CustomColor.green),
        useMaterial3: true,
      ),
      routes: namedRoutes,
    ),
  ));
}

Future<void> openHiveBox(String boxName, {bool limit = false}) async {
  final box = await Hive.openBox(boxName).onError((error, stackTrace) async {
    debugPrint('Failed to open $boxName Box: $error');
    final Directory dir = await getApplicationDocumentsDirectory();
    final String dirPath = dir.path;
    File dbFile = File('$dirPath/$boxName.hive');
    File lockFile = File('$dirPath/$boxName.lock');
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      dbFile = File('$dirPath/BlackHole/$boxName.hive');
      lockFile = File('$dirPath/BlackHole/$boxName.lock');
    }
    await dbFile.delete();
    await lockFile.delete();
    await Hive.openBox(boxName);
    throw 'Failed to open $boxName Box\nError: $error';
  });
  // clear box if it grows large
  if (limit && box.length > 500) {
    box.clear();
  }
}
