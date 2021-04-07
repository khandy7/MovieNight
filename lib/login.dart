import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:movie_helper/navbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

var signin = true;

String getError(String e) {
  String x = '';
  switch(e) {
    case 'weak-password':
      x = "The password provided is too weak.";
      break;
    case 'email-already-in-use':
      x = "That email address is already in use.";
      break;
    case 'wrong-password':
      x = 'Password is incorrect, please try again.';
      break;
    case 'too-many-requests':
      x = "Too many sign in attempts, please wait and try again.";
      break;
    case 'operation-not-allowed':
      x = "You did something wrong, idk try again.";
      break;
    case 'user-not-found':
      x = "User could not be found, register to make an account.";
      break;
    default:
      x = "Something went wrong, try again.";
      break;
  }
  return x;
}

//BEGINNING OF LOGIN PAGE WIDGET
class MyLoginPage extends StatefulWidget {


  @override
  _MyLoginState createState() => _MyLoginState();
}

class _MyLoginState extends State<MyLoginPage> {

  final db = FirebaseFirestore.instance;

  var check = true;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final auth = FirebaseAuth.instance;

  final _emailKey = GlobalKey<FormState>();
  final _passKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    emailController.addListener(() {
      final text = emailController.text;
      emailController.value = emailController.value.copyWith(
        text: text,
        selection:
        TextSelection(baseOffset: text.length, extentOffset: text.length),
        composing: TextRange.empty,
      );
    });
    passwordController.addListener(() {
      final text = passwordController.text;
      passwordController.value = passwordController.value.copyWith(
        text: text,
        selection:
        TextSelection(baseOffset: text.length, extentOffset: text.length),
        composing: TextRange.empty,
      );
    });
  }


  @override
  Widget build(BuildContext context) {
    TextStyle defaultStyle = TextStyle(color: Colors.grey, fontSize: 20.0);
    TextStyle linkStyle = TextStyle(color: Colors.blue);

    return Scaffold(
      appBar: AppBar(title: Text("Login"), centerTitle: true),
      body: Center(
        child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Login or Register", style: TextStyle(fontSize: 35)),
                    Text("Please login or register below if you do not have an account."),
                    //Displays form for email address
                    emailForm(_emailKey, emailController),
                    //Displays form for password
                    passForm(_passKey, passwordController),
                    //Sign in button
                    signInButton(context, emailController, passwordController, auth),

                    //below is register button, something went wrong when put into a function
                    ElevatedButton(
                      onPressed: () async {
                        if (_emailKey.currentState.validate() && _passKey.currentState.validate()) {
                          String email = emailController.text;
                          String pass = passwordController.text;
                          try {
                            await auth.createUserWithEmailAndPassword(email: email, password: pass);
                            check = true;
                            signin = false;
                          } on FirebaseException catch(e) {
                            print(e.code);
                            signin = true;
                            check = false;
                            String x = getError(e.code);
                            ScaffoldMessenger.of(context).removeCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(x), duration: Duration(days: 1), backgroundColor: Colors.red));
                          }
                          FirebaseAuth.instance
                              .authStateChanges()
                              .listen((User user) {
                            if (user == null) {
                            } else if (check != false && signin == false) {
                              db.collection("users").doc(auth.currentUser.uid).set({
                                "email" : auth.currentUser.email,
                                "uid" : auth.currentUser.uid,
                                "name" : null,
                                "favMovie" : null,
                                "favGenre" : null,
                                "bio" : null,
                                "friends" : [],
                                "friend_count": 0,
                                "prof_pic" : null,
                              },SetOptions(merge: true)).then((_) {
                                print("Successfully created user doc!");
                              });
                              ScaffoldMessenger.of(context).removeCurrentSnackBar();
                              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => MyNavBar(page: 0,)));
                            }
                          });
                        }
                      },
                      child: Text(
                        "Register",
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ]
        ),
      ),
    );
  }
}
//END OF LOGIN PAGE WIDGET


//Email form
Widget emailForm(Key _emailKey, TextEditingController emailController) => Padding(
  padding: EdgeInsets.all(16.0),
  child: Form(
    key: _emailKey,
    child: TextFormField(
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        hintText: "Enter your email address",
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


//Password form
Widget passForm(Key _passKey, TextEditingController passwordController) => Padding(
  padding: EdgeInsets.all(16.0),
  child: Form(
    key: _passKey,
    child: TextFormField(
      obscureText: true,
      decoration: InputDecoration(
        hintText: "Enter a password",
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
      controller: passwordController,
      validator: (value) {
        if (value.isEmpty || value.length < 7) {
          return 'Please enter a valid password, must be at least 7 characters long.';
        }
        return null;
      },
    ),
  ),
);



//Button for signing in
Widget signInButton(BuildContext context, TextEditingController emailController, TextEditingController passwordController, FirebaseAuth auth) => ElevatedButton(
      onPressed: () async {
        try {
          signin = true;
          await auth.signInWithEmailAndPassword(email: emailController.text, password: passwordController.text);
        } on FirebaseAuthException catch(e) {
          String x = getError(e.code);
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(x), duration: Duration(days: 1), backgroundColor: Colors.red));
          print(e.code);
        }
        FirebaseAuth.instance
            .authStateChanges()
            .listen((User user) {
          if (user == null) {
          } else {
            ScaffoldMessenger.of(context).removeCurrentSnackBar();
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => MyNavBar(page: 0,)));
          }
        });
      },
      child: Text(
        "Sign in",
        style: TextStyle(color: Colors.white),
      ),
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
      ),
);