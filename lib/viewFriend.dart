import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:movie_helper/models/movieModel.dart';
import 'package:dio/dio.dart';
import 'package:movie_helper/viewMovie.dart';


class viewFriend extends StatefulWidget {
  const viewFriend({Key key, this.friend_email}) : super(key: key);

  final String friend_email;

  @override
  _viewFriendState createState() => _viewFriendState();
}

class _viewFriendState extends State<viewFriend> {

  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore db = FirebaseFirestore.instance;
  String email;
  String uid;
  String bio;
  String name;
  String favMovie;
  String favGenre;
  String prof_pic;
  List lst;
  int liked = 0;
  int disliked = 0;
  List<dynamic> watchlist;
  bool done = false;
  int count;
  var dio = Dio();
  String oneMovie = "https://api.themoviedb.org/3/movie/";
  String apiKey = "?api_key=211ff81d2853a542be703d3104384047";


  @override
  void initState() {
    super.initState();
    //get uid from email then set states
    db.collection("users").where('email', isEqualTo: widget.friend_email).get().then((value) {
      setState(() {
        uid = value.docs.first.get('uid');
      });
      db.collection('users').doc(uid).get().then((value) {
        setState(() {
          name = value['name'];
          bio = value['bio'];
          lst = value['friends'];
          count = lst.length;
          favGenre = value['favGenre'];
          favMovie = value['favMovie'];
          email = value['email'];
          prof_pic = value['prof_pic'];
          liked = value['liked'].length;
          disliked = value['disliked'].length;
          watchlist = value['watchlist'];
          done = true;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Friend\'s Profile'),
        centerTitle: true,
      ),
      body: Center(
        child: done == false ? CircularProgressIndicator() : Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.black,
                    radius: 120.0,
                    backgroundImage: prof_pic == null ? NetworkImage("https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS3tP7TGcBswRZaVUObsbuxPr6lotRCP1FlIQ&usqp=CAU") : NetworkImage(prof_pic),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 8.0),
              child: name == null ? Text('User Name', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),) : Text('$name', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 8.0),
              child: email == null ? CircularProgressIndicator() : Text('$email'),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.all(6),
                  child: Text("Friends: $count"),
                ),
                Padding(
                  padding: EdgeInsets.all(6),
                  child: Text("Liked Movies: $liked"),
                ),
                Padding(
                  padding: EdgeInsets.all(6),
                  child: Text("Disliked Movies: $disliked"),
                ),
              ],

            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: favMovie == null ? Text("Favorite Movie: N/A") : Text("Favorite Movie: $favMovie"),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: favGenre == null ? Text("Favorite Genre: N/A") : Text("Favorite Genre: $favGenre"),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: bio == null ? Text("Bio: N/A") : Text("Bio: $bio"),
            ),
          ],
        ),
      ),
    );
  }
}
