import 'package:flutter/material.dart';
import 'package:movie_helper/login.dart';
import 'package:movie_helper/navbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:movie_helper/loading_screen.dart';


class MyRoot extends StatefulWidget {
  @override
  _MyRootState createState() => _MyRootState();
}

class _MyRootState extends State<MyRoot> {
  String check = 'waiting';


@override
void initState() {
    super.initState();
    FirebaseAuth.instance
        .authStateChanges()
        .listen((User user) {
      if (user == null) {
        if(mounted){
          setState(() {
            check = 'error';
          });
        }
      } else {
        if (mounted) {
          setState(() {
            check = 'success';
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    Widget val;

    switch (check) {
      case 'waiting':
        val = MyLoadingScreen();
        break;
      case 'success':
        val = MyNavBar();
        break;
      case 'error':
        val = MyLoginPage();
        break;
    }
    return val;
  }
}

