import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'screens/downloaded_reports_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MaterialApp(
    home: DownloadedReportsScreen(),
    debugShowCheckedModeBanner: false,
  ));
}
