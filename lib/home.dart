
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';



class MyHomePage extends StatefulWidget {


  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  FirebaseFirestore db = FirebaseFirestore.instance;

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

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        //Put ROWS of different widgets here, like make widget that returns a row for top title,
        //then widget that returns the movie title and genre, then description, then buttons

        //This row is just for MOVIE OF THE DAY
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("MOVIE OF THE DAY", style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),),
          ],
        ),
        MovieOfDay(),

      ],
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

class MovieOfDay extends StatefulWidget {
  @override
  _MovieOfDayState createState() => _MovieOfDayState();
}

class _MovieOfDayState extends State<MovieOfDay> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          Image.network('https://scitechdaily.com/images/Lunar-Reconnaissance-Orbiter-Moon-scaled.jpg'),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //THIS WIDGET WILL CONTAIN THE DAILY MOVIES TITLE GENRES AND DESCRIPTION
                Text("Movie Title", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
              ],
            ),
        ),
         Padding(
           padding: EdgeInsets.only(bottom: 8.0),
           child:  Row(
             mainAxisAlignment: MainAxisAlignment.center,
             children: [
               //THIS WIDGET WILL CONTAIN THE DAILY MOVIES TITLE GENRES AND DESCRIPTION
               Text("Genres/Action"),
             ],
           ),
         ),
          Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //THIS WIDGET WILL CONTAIN THE DAILY MOVIES TITLE GENRES AND DESCRIPTION
                Flexible(child: Text("Here is a short paragraph about this movie, it sure is a great movie where its just two brothers, and a bunch of crazy shit happens.", softWrap: true,)),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //put buttons here
              Padding(
                padding: EdgeInsets.all(16.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints.tightFor(width: 90, height: 40),
                  child: ElevatedButton(
                    onPressed: null,
                    child: Text("LIKE?", style: TextStyle(color: Colors.white),),
                    style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.blue)),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints.tightFor(width: 90, height: 40),
                  child: ElevatedButton(
                    onPressed: null,
                    child: Text("DISLIKE?", style: TextStyle(color: Colors.white),),
                    style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.red)),
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Swipe up to check out your liked movies!"),
            ],
          ),
        ],
      ),
    );
  }
}

