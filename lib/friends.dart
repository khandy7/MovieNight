import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:movie_helper/addFriend.dart';
import 'package:flutter/gestures.dart';
import 'package:movie_helper/viewFriend.dart';

//BEGINNING OF FRIENDS PAGE WIDGET
class MyFriendsPage extends StatefulWidget {

  @override
  _MyFriendsState createState() => _MyFriendsState();
}

class _MyFriendsState extends State<MyFriendsPage> {

  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore db = FirebaseFirestore.instance;
  String email;
  String uid;
  int friend_count = null;
  var friends = [];
  var done = false;

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
          db.collection('users').doc(uid).get().then((value) {
            setState(() {
              friends = value['friends'];
              friend_count = friends.length;
              done = true;
            });
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
            Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Friends List', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),),
            ),
            Padding(
              padding: EdgeInsets.all(6.0),
              child: done == false ? CircularProgressIndicator() : Text('# of Friends: $friend_count', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),),
            ),
            Padding(
                padding: EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => addFriend()));
                  },
                  child: Text("Add Friend", style: TextStyle(color: Colors.white),),
                ),
            ),
            Expanded(
                child: SizedBox(
                  height: 200.0,
                  child: done == false ? CircularProgressIndicator() : CustomScrollView(
                    slivers: <Widget>[
                      SliverGrid(
                        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 200.0,
                          mainAxisSpacing: 15.0,
                          crossAxisSpacing: 10.0,
                          childAspectRatio: 4.0,
                        ),
                        delegate: SliverChildBuilderDelegate(
                              (BuildContext context, int index) {
                            return Container(
                              alignment: Alignment.center,
                              color: Colors.white,
                              child: GestureDetector(
                                child: Text(friends[index]),
                                onTap: () {
                                  //put route to view friends profile
                                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => viewFriend(friend_email: friends[index],)));
                                },
                              ),
                            );
                          },
                          childCount: friend_count,
                        ),
                      ),
                    ],
                  ),
                ),
            ),
          ],
        ),
      ),
    );
  }
}
//END OF FRIENDS PAGE WIDGET
