import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';




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
    final PageController pageController = PageController(initialPage: 0);
    //EMAIL and UID is the current users identifiers
    //Get identifiers from shared prefs on any screen
    return Scaffold(
      body: PageView(
        scrollDirection: Axis.vertical,
        controller: pageController,
        children: <Widget> [
          DailyMovie(),
          MovieList(),
        ],
      ),
    );
  }
}


class DailyMovie extends StatefulWidget {

  @override
  _DailyMovieState createState() => _DailyMovieState();
}


class _DailyMovieState extends State<DailyMovie> {

  @override
  Widget build(BuildContext context) {

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('DAILY MOVIE STUFF GOES HERE'),
        ],
      ),
    );
  }
}

class MovieList extends StatefulWidget {

  @override
  _MovieListState createState() => _MovieListState();
}


class _MovieListState extends State<MovieList> {

  @override
  Widget build(BuildContext context) {

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('LIST OF LIKED MOVIES GOES HERE'),
        ],
      ),
    );
  }
}