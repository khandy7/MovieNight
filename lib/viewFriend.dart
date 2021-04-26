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
  int numWatchlist;
  int disliked = 0;
  List<dynamic> watchlist;
  bool done = false;
  Map map_liked;
  Map map_disliked;
  int count;
  var dio = Dio();
  String oneMovie = "https://api.themoviedb.org/3/movie/";
  String apiKey = "?api_key=211ff81d2853a542be703d3104384047";
  Map<int, String> genre_list = {
    28:"Action", 12:"Adventure", 16:"Animation",
    35:"Comedy", 80:"Crime", 99:"Documentary", 18:"Drama", 10751:"Family", 14:"Fantasy",
    36:"History", 27:"Horror", 10402:"Music", 9648:"Mystery", 10749:"Romance", 878:"Science Fiction",
    10770:"TV Movie", 53:"Thriller", 10752:"War", 37:"Western"
  };


  @override
  void initState() {
    super.initState();
    //get uid from email then set states
    db.collection("users").where('email', isEqualTo: widget.friend_email).get().then((value) {
      setState(() {
        uid = value.docs.first.get('uid');
      });
      db.collection('users').doc(uid).get().then((value) {
        if (mounted) {
          setState(() {
            name = value['name'];
            bio = value['bio'];
            lst = value['friends'];
            count = lst.length;
            favGenre = value['favGenre'];
            favMovie = value['favMovie'];
            email = value['email'];
            prof_pic = value['prof_pic'];
            liked = value['map_liked'].length;
            disliked = value['map_disliked'].length;
            map_liked = value['map_liked'];
            map_disliked = value['map_disliked'];
            watchlist = value['watchlist'];
            numWatchlist = watchlist.length;
            done = true;
          });
        }
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
            numWatchlist != 0 ? Text("Friends watchlist: ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),) : Text("No movies on this watchlist.", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            Expanded(
                child: ListView.builder(
                  itemCount: numWatchlist,
                  itemBuilder: (context, index) {
                    String name;
                    List<String> g;
                    int id = watchlist[index];
                    if (map_liked.containsKey(id.toString())) {
                      name = map_liked[id.toString()][0];
                      int size = map_liked[id.toString()].length-1;
                      if (size > 2) {
                        size = 2;
                      }
                      g = new List.filled(size+1, "");
                      for (int i = 1; i <= size; i++) {
                        if (i == size) {
                          g[i-1] = genre_list[map_liked[id.toString()][i]];
                        } else {
                          g[i-1] = genre_list[map_liked[id.toString()][i]] + "/";
                        }
                      }
                    } else if (map_disliked.containsKey(id.toString())) {
                      name = map_disliked[id.toString()][0];
                      int size = map_disliked[id.toString()].length;
                      if (size > 2) {
                        size = 2;
                      }
                      g = new List.filled(size, "");
                      for (int i = 1; i <= size; i++) {
                        if (i == size) {
                          g[i-1] = genre_list[map_disliked[id.toString()][i]];
                        } else {
                          g[i-1] = genre_list[map_disliked[id.toString()][i]] + "/";
                        }
                      }
                    }
                    return Card(
                      elevation: 6.0,
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(),
                        ),
                        child: ListTile(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(builder: (context) => viewMovie(movie: new Movie(id: id))));
                          },
                          contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                          title: Text(name,style:TextStyle(fontSize: 20, color: Colors.black),),
                          subtitle: Row(
                            children: g.map((item) => new Text(item, style: TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis,)).toList(),
                          ),
                        ),
                      ),
                    );
                  }
                )
            ),
          ],
        ),
      ),
    );
  }
}
