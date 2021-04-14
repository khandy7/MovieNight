import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:movie_helper/models/movieModel.dart';
import 'package:dio/dio.dart';


class viewMovie extends StatelessWidget {

  final Movie movie;

  viewMovie({this.movie});

  String picBase = "https://image.tmdb.org/t/p/w500";


  @override
  Widget build(BuildContext context) {
    int size = movie.genre.length;
    List<String> g = new List.filled(size, "");
    for (int i = 0; i < size; i++) {
      if (i == size - 1) {
        g[i] = movie.genre_list[movie.genre[i]];
      } else {
        g[i] = movie.genre_list[movie.genre[i]] + "/";
      }
    }
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("View Movie"),
      ),
      body: Center(
        child: Column(
          children: [
            Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Image(image: NetworkImage(picBase + movie.pic), width: 350, height: 450,),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      //THIS WIDGET WILL CONTAIN THE DAILY MOVIES TITLE GENRES AND DESCRIPTION
                      Text(movie.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 8.0),
                  child:  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      //THIS WIDGET WILL CONTAIN THE DAILY MOVIES TITLE GENRES AND DESCRIPTION
                      Row(
                        children: g.map((item) => new Text(item)).toList(),
                        mainAxisAlignment: MainAxisAlignment.center,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      //THIS WIDGET WILL CONTAIN THE DAILY MOVIES TITLE GENRES AND DESCRIPTION
                      Flexible(child: Text(movie.desc, softWrap: true,)),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
