import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:just_notify/model/client.dart';
import 'package:just_notify/screens/mainPage.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dir = await getApplicationDocumentsDirectory();
    final isar = await Isar.open(
      [ClientSchema], 
      directory: dir.path
    );
  runApp(MyApp(isar: isar));
}

class MyApp extends StatelessWidget {
  final Isar isar;
  const MyApp({super.key, required this.isar});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.deepPurple,
        primarySwatch: Colors.deepPurple
      ),
      home: MainPage(isar: isar),
    );
  }
}
