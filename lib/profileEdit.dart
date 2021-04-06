import 'package:flutter/material.dart';
import 'package:movie_helper/profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class MyProfileEdit extends StatefulWidget {
  @override
  _MyProfileEditState createState() => _MyProfileEditState();
}

class _MyProfileEditState extends State<MyProfileEdit> {

  final _movieKey = GlobalKey<FormState>();
  final _bioKey = GlobalKey<FormState>();
  final _nameKey = GlobalKey<FormState>();
  final _genreKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final movieController = TextEditingController();
  final bioController = TextEditingController();
  final genreController = TextEditingController();

  var email;
  var uid;

  final db = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;

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
    nameController.addListener(() {
      final text = nameController.text;
      nameController.value = nameController.value.copyWith(
        text: text,
        selection:
        TextSelection(baseOffset: text.length, extentOffset: text.length),
        composing: TextRange.empty,
      );
    });
    genreController.addListener(() {
      final text = genreController.text;
      genreController.value = genreController.value.copyWith(
        text: text,
        selection:
        TextSelection(baseOffset: text.length, extentOffset: text.length),
        composing: TextRange.empty,
      );
    });
    movieController.addListener(() {
      final text = movieController.text;
      movieController.value = movieController.value.copyWith(
        text: text,
        selection:
        TextSelection(baseOffset: text.length, extentOffset: text.length),
        composing: TextRange.empty,
      );
    });
    bioController.addListener(() {
      final text = bioController.text;
      bioController.value = bioController.value.copyWith(
        text: text,
        selection:
        TextSelection(baseOffset: text.length, extentOffset: text.length),
        composing: TextRange.empty,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Editing Profile"),
        centerTitle: true,
        leading: IconButton(
          icon: IconButton(
            icon: Icon(Icons.arrow_back, size: 40, color: Colors.white,),
            onPressed: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => MyProfile()));
            },
            padding: EdgeInsets.all(1.0),
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //Put several forms here for things like name, fav movie, short bio
            Text("Enter your full name"),
            nameForm(_nameKey, nameController),
            Text("Enter your favorite movie"),
            movieForm(_movieKey, movieController),
            Text("Enter your favorite genre"),
            genreForm(_genreKey, genreController),
            Text("Enter a short bio about yourself"),
            bioForm(_bioKey, bioController),
            ElevatedButton(
                onPressed: () {
                  if (nameController.text != "") {
                    db.collection('users').doc(auth.currentUser.uid).set({
                      "name" : nameController.text,
                  },SetOptions(merge: true)).then((_) {
                    print("Successfully updated name");
                    });
                  }
                  if (bioController.text != "") {
                    db.collection('users').doc(auth.currentUser.uid).set({
                      "bio" : bioController.text,
                    },SetOptions(merge: true)).then((_) {
                    print("Successfully updated bio");
                    });
                  }
                  if(genreController.text != "") {
                    db.collection('users').doc(auth.currentUser.uid).set({
                      "favGenre" : genreController.text,
                    },SetOptions(merge: true)).then((_) {
                  print("Successfully updated fav genre");
                  });
                  }
                  if (movieController.text != "") {
                    db.collection('users').doc(auth.currentUser.uid).set({
                      "favMovie" : movieController.text,
                    },SetOptions(merge: true)).then((_) {
                    print("Successfully updated fav movie");
                    });
                  }
                  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => MyProfile()));
                },
                child: Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}


Widget nameForm(Key _nameKey, TextEditingController nameController) => Padding(
    padding: EdgeInsets.all(16.0),
    child: Form(
      key: _nameKey,
      child: TextFormField(
        controller: nameController,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
            borderSide: BorderSide(color: Colors.grey.shade50),
          ),
          hintText: "Full Name",
        ),
      ),
    ),
);

Widget movieForm(Key _movieKey, TextEditingController movieController) => Padding(
  padding: EdgeInsets.all(16.0),
  child: Form(
    key: _movieKey,
    child: TextFormField(
      controller: movieController,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
          borderSide: BorderSide(color: Colors.grey.shade50),
        ),
        hintText: "Favorite Movie",
      ),
    ),
  ),
);

Widget bioForm(Key _bioKey, TextEditingController bioController) => Padding(
  padding: EdgeInsets.all(16.0),
  child: Form(
    key: _bioKey,
    child: TextFormField(
      controller: bioController,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
          borderSide: BorderSide(color: Colors.grey.shade50),
        ),
        hintText: "Short Bio",
      ),
    ),
  ),
);

Widget genreForm(Key _genreKey, TextEditingController genreController) => Padding(
  padding: EdgeInsets.all(16.0),
  child: Form(
    key: _genreKey,
    child: TextFormField(
      controller: genreController,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
          borderSide: BorderSide(color: Colors.grey.shade50),
        ),
        hintText: "Favorite Genre",
      ),
    ),
  ),
);
