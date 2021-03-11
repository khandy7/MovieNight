//Kyle Handy
//Project: Movie Night - Helps you find a movie to watch

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:movie_helper/root.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie Night',
      theme: ThemeData(
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyRoot(),
    );
  }
}



