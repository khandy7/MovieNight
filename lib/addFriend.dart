import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:movie_helper/navbar.dart';


class addFriend extends StatefulWidget {
  @override
  _addFriendState createState() => _addFriendState();
}

class _addFriendState extends State<addFriend> {

  final auth = FirebaseAuth.instance;
  final db = FirebaseFirestore.instance;
  final emailController = TextEditingController();
  final _emailKey = GlobalKey<FormState>();
  String uid;
  String email;

  @override
  void initState() {
    super.initState();
    if (mounted) {
      setState(() {
        email = auth.currentUser.email.toString();
        uid = auth.currentUser.uid.toString();
      });
    }
    emailController.addListener(() {
      final text = emailController.text;
      emailController.value = emailController.value.copyWith(
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
        title: Text("Add Friends"),
        centerTitle: true,
        leading: IconButton(
          icon: IconButton(
            icon: Icon(Icons.arrow_back, size: 40, color: Colors.white,),
            onPressed: () {
              ScaffoldMessenger.of(context).removeCurrentSnackBar();
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => MyNavBar(page: 2,)));
            },
            padding: EdgeInsets.all(1.0),
          ),
        ),
      ),
      body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("Search for your friends email address"),
            ),
            emailForm(_emailKey, emailController),
            ElevatedButton(
                onPressed: () {
                  //search through users here for email
                  //value.docs.first.get('email')
                  var femail = [];
                  db.collection("users").where('email', isEqualTo: emailController.text).get().then((value) {
                    if (value.size != 0) {
                      setState(() {
                        femail.add(value.docs.first.get('email'));
                      });
                    }
                    if (femail.isEmpty) {
                      //show error
                      var x = emailController.text;
                      ScaffoldMessenger.of(context).removeCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Could not find $x"), duration: Duration(days: 1), backgroundColor: Colors.red));
                    } else if (femail.first == email) {
                      ScaffoldMessenger.of(context).removeCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Can not add yourself as a friend"), duration: Duration(days: 1), backgroundColor: Colors.red));
                    } else {
                      //else add to friends list
                      db.collection('users').doc(uid).update({
                        'friends' : FieldValue.arrayUnion(femail),
                       });
                      ScaffoldMessenger.of(context).removeCurrentSnackBar();
                      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => MyNavBar(page: 2)));
                    }
                  });
                  //pop at the end to go back to friends screen
                },
                child: Text("Search for Friend", style: TextStyle(color: Colors.white),),
            ),
          ],
      ),
    ),);
  }
}



//Email form
Widget emailForm(Key _emailKey, TextEditingController emailController) => Padding(
  padding: EdgeInsets.all(16.0),
  child: Form(
    key: _emailKey,
    child: TextFormField(
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        hintText: "Enter your friends email address",
        filled: true,
        fillColor: Colors.grey,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
          borderSide: BorderSide(color: Colors.grey.shade50),
        ),),
      controller: emailController,
      validator: (value) {
        if (value.isEmpty || !value.contains('@') ) {
          return 'Please enter a valid email address.';
        }
        return null;
      },

    ),
  ),
);
