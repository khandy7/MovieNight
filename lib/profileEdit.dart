import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:movie_helper/profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';


class MyProfileEdit extends StatefulWidget {
  const MyProfileEdit({Key key, this.retPage}) : super(key: key);

  final int retPage;

  @override
  _MyProfileEditState createState() => _MyProfileEditState();
}

class _MyProfileEditState extends State<MyProfileEdit> {

  Future getImage(bool gallery) async {
    ImagePicker picker = ImagePicker();
    PickedFile pickedFile;
    // Let user select photo from gallery
    if(gallery) {
      pickedFile = await picker.getImage(
        source: ImageSource.gallery,);
    }
    // Otherwise open camera to get new photo
    else{
      pickedFile = await picker.getImage(
        source: ImageSource.camera,);
    }

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        //_image = File(pickedFile.path); // Use if you only need a single picture
      } else {
        _image = null;
        print('No image selected.');
      }
    });
  }

  Future<void> saveImages(File image, DocumentReference ref) async {
      String imageURL = await uploadFile(image).then((value) {
        ref.update({"prof_pic": value});
        return value;
      });
      //ref.update({"prof_pic": imageURL});
  }

  Future<String> uploadFile(File _image) async {
    firebase_storage.Reference storageReference = firebase_storage.FirebaseStorage.instance.ref('profile_pics/${basename(_image.path)}');
    firebase_storage.UploadTask uploadTask = storageReference.putFile(_image);
    await uploadTask.whenComplete(() =>
        print("File uploaded")
    );
    String returnURL;
    await storageReference.getDownloadURL().then((fileURL) {
      returnURL =  fileURL;
    });
    return returnURL;
  }



  final _movieKey = GlobalKey<FormState>();
  final _bioKey = GlobalKey<FormState>();
  final _nameKey = GlobalKey<FormState>();
  final _genreKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final movieController = TextEditingController();
  final bioController = TextEditingController();
  final genreController = TextEditingController();
  String prof_pic = null;

  File _image;

  var email;
  var uid;

  firebase_storage.UploadTask uploadTask;
  firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance.ref('profile_pics');

  DocumentReference sightingRef;

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
            sightingRef = FirebaseFirestore.instance.collection("users").doc(uid);
          });
          db.collection('users').doc(uid).get().then((value) {
            setState(() {
              prof_pic = value['prof_pic'];
            });
          });
        }
      }
    });

    //reference to specific users documeent in db

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
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => MyProfile(retPage: widget.retPage,)));
            },
            padding: EdgeInsets.all(1.0),
          ),
        ),
      ),
      body: Center(
        child: Column(
          children: [
            Text("Profile Picture"),
              Padding(
              padding: EdgeInsets.only(right:8.0, left:8.0, bottom:4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      //after this _image holds the users picked image
                      getImage(true);
                  },
                    child: Text("Choose photo"),
                  ),
                ],
              ),
            ),
            _image != null ? Text("Profile picture has been selected!") : Text("No profile picture selected."),
            //Put several forms here for things like name, fav movie, short bio
            //Text("Enter your full name"),
            nameForm(_nameKey, nameController),
            //Text("Enter your favorite movie"),
            movieForm(_movieKey, movieController),
            //Text("Enter your favorite genre"),
            genreForm(_genreKey, genreController),
            //Text("Enter a short bio about yourself"),
            bioForm(_bioKey, bioController),
            ElevatedButton(
                onPressed: () async {
                  if (_image != null) {
                    if (prof_pic != null) {
                      //delete current photo from db then save next photo
                      firebase_storage.Reference n = ref.storage.refFromURL(prof_pic);
                      ref.child(n.fullPath.substring(13)).delete();
                    }
                    await saveImages(_image, sightingRef);//.then((value) => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => MyProfile(retPage: widget.retPage,)))
                    //);
                  }
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
                 // if (_image == null) {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => MyProfile(retPage: widget.retPage,)));
                  //}
                },
                child: Text("Save"),
            ),
            Text("It may take a few seconds after pressing save to return"),
          ],
        ),
      ),
    );
  }
}

Widget nameForm(Key _nameKey, TextEditingController nameController) => Padding(
    padding: EdgeInsets.all(3.0),
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
  padding: EdgeInsets.all(3.0),
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
  padding: EdgeInsets.all(3.0),
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
  padding: EdgeInsets.all(3.0),
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

