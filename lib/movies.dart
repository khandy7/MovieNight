import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';


//BEGINNING OF MOVIE PAGE WIDGET
class MyMoviePage extends StatefulWidget {

  @override
  _MyMovieState createState() => _MyMovieState();
}

class _MyMovieState extends State<MyMoviePage> {

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


    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Text('MOVIE STATE'),
            Text("BELOW IS CURRENT USERS EMAIL AND UID"),
            email == null ? CircularProgressIndicator() : Text('$email'),
            uid == null ? CircularProgressIndicator() : Text('$uid'),
          ],
        ),
      ),
    );
  }
}
//END OF MOVIE PAGE WIDGET