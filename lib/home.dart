import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:movie_helper/navbar.dart';




class MyHomePage extends StatefulWidget {


  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  FirebaseAuth auth = FirebaseAuth.instance;
  String email;
  String uid;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user == null) {
        print("FUCKED SHIT");
      } else {
        if (mounted) {
          setState(() {
            email = auth.currentUser.email.toString();
            uid = auth.currentUser.uid.toString();
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    //EMAIL and UID is the current users identifiers
    //Get identifiers from shared prefs on any screen
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Text("HELLO STATE"),
            Text("BELOW IS CURRENT USERS EMAIL AND UID"),
            email == null ? CircularProgressIndicator() : Text('$email'),
            uid == null ? CircularProgressIndicator() : Text('$uid'),
          ],
        ),
      ),
    );
  }
}