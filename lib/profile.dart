import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:movie_helper/profileEdit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'navbar.dart';


class MyProfile extends StatefulWidget {

  const MyProfile({Key key, this.retPage}) : super(key: key);

  final int retPage;

  @override
  _MyProfileState createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {


  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore db = FirebaseFirestore.instance;
  String email;
  String uid;
  String bio;
  String name;
  String favMovie;
  String favGenre;
  int friend_count;
  bool done = false;
  int liked;
  int disliked;
  String prof_pic = null;
  String friends;

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
              name = value['name'];
              bio = value['bio'];
              favGenre = value['favGenre'];
              favMovie = value['favMovie'];
              prof_pic = value['prof_pic'];
              liked = value['map_liked'].length;
              disliked = value['map_disliked'].length;
              friend_count = value['friends'].length;
              friends = friend_count.toString();
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
      appBar: AppBar(
        title: Text('Profile'),
        centerTitle: true,
        leading: IconButton(
          icon: IconButton(
            icon: Icon(Icons.arrow_back, size: 40, color: Colors.white,),
            onPressed: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => MyNavBar(page: widget.retPage,)));
            },
            padding: EdgeInsets.all(1.0),
          ),
        ),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => MyProfileEdit(retPage: widget.retPage,)));
              },
              icon: Icon(Icons.edit_outlined, size: 40, color: Colors.white)
          )
        ],
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
                    backgroundImage: prof_pic == null ? NetworkImage("https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS3tP7TGcBswRZaVUObsbuxPr6lotRCP1FlIQ&usqp=CAU") :  NetworkImage(prof_pic),
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
                    child: friend_count == null ? CircularProgressIndicator() : Text("Friends: $friends"),
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
            )
          ],
        ),
      ),
    );
  }
}
