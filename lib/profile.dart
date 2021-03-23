import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'navbar.dart';


class MyProfile extends StatefulWidget {

  @override
  _MyProfileState createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {


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
      appBar: AppBar(
        title: Text('Profile'),
        centerTitle: true,
        leading:         IconButton(
          icon: IconButton(
            icon: Icon(Icons.arrow_back, size: 40, color: Colors.white,),
            onPressed: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => MyNavBar()));
            },
            padding: EdgeInsets.all(1.0),
          ),
        ),
      ),
      body: Center(
        child: Column(
          children: [
            Text('PROFILE STATE'),
            email == null ? CircularProgressIndicator() : Text('$email'),
            uid == null ? CircularProgressIndicator() : Text('$uid'),
          ],
        ),
      ),
    );
  }
}
