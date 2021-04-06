
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:movie_helper/friends.dart';
import 'package:movie_helper/login.dart';
import 'package:movie_helper/home.dart';
import 'package:movie_helper/movies.dart';
import 'package:movie_helper/profile.dart';

class MyNavBar extends StatefulWidget {
  const MyNavBar({Key key, this.page}) : super(key: key);

  final int page;

  @override
  _MyNavBarState createState() => _MyNavBarState();
}

class _MyNavBarState extends State<MyNavBar> {


  int _selectedIndex = 0;

  static const TextStyle optionStyle = TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static List<Widget> _widgetOptions = <Widget>[
    MyHomePage(),
    MyMoviePage(),
    MyFriendsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }


  @override
  void initState()  {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((user) {
    });
    _onItemTapped(widget.page);
  }

  @override
  Widget build(BuildContext context) {



    final auth = FirebaseAuth.instance;

      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: (_selectedIndex == 0) ? Text("Home") : (_selectedIndex == 1) ? Text('Movies') :(_selectedIndex == 2) ? Text('Friends') : Text("Movie Night"),
          leading: IconButton(
            icon: Icon(Icons.logout, size: 40, color: Colors.white),
            onPressed: () {
              auth.signOut();
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => MyLoginPage()));
            },
            padding: EdgeInsets.all(1.0),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.account_circle, size: 40, color: Colors.white),
              onPressed: () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => MyProfile(retPage: _selectedIndex,)));
              },
              padding: EdgeInsets.all(1.0),
            ),
          ],
        ),
        body: Center(
          child: _widgetOptions.elementAt(_selectedIndex),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.movie_filter),
              label: 'Movies',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.group),
              label: 'Friends',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.amber[800],
          onTap: _onItemTapped,
        ),
      );
    }
}