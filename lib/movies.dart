import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:movie_helper/models/movieModel.dart';
import 'package:dio/dio.dart';


//BEGINNING OF MOVIE PAGE WIDGET
class MyMoviePage extends StatefulWidget {

  @override
  _MyMovieState createState() => _MyMovieState();
}

class _MyMovieState extends State<MyMoviePage> {

  FirebaseFirestore db = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  String email;
  String uid;
  List<dynamic> liked;
  List<dynamic> disliked;
  Future<Movie> movie;

  Dio dio = Dio();

  Map<String, int> genre_list = {
    "Action":28, "Adventure":12, "Animation":16,
      "Comedy":35, "Crime":80, "Documentary":99, "Drama":18, "Family":10751, "Fantasy":14,
      "History":36, "Horror":27, "Music":10402, "Mystery":9648, "Romance":10749, "Science Fiction":878,
      "TV Movie":10770, "Thriller":53, "War":10752, "Western":37
  };

  String popular = 'https://api.themoviedb.org/3/movie/popular?api_key=211ff81d2853a542be703d3104384047&language=en-US&page=';
  int popularPage =  1;
  int popularIndex = 0;
  String nowPlaying = 'https://api.themoviedb.org/3/movie/now_playing?api_key=211ff81d2853a542be703d3104384047&language=en-US&page=';
  int nowPlayingPage = 1;
  int nowPlayingIndex = 0;
  String topRated = 'https://api.themoviedb.org/3/movie/top_rated?api_key=211ff81d2853a542be703d3104384047&language=en-US&page=';
  int topRatedPage = 1;
  int topRatedIndex = 0;
  String upcoming = 'https://api.themoviedb.org/3/movie/upcoming?api_key=211ff81d2853a542be703d3104384047&language=en-US&page=';
  int upcomingPage = 1;
  int upcomingIndex = 0;
  String allMovies = "https://api.themoviedb.org/3/discover/movie?api_key=211ff81d2853a542be703d3104384047&language=en-US&page=";
  int allMoviesPage = 1;
  int allMoviesIndex = 0;
  String genreMovies = "https://api.themoviedb.org/3/discover/movie?api_key=211ff81d2853a542be703d3104384047&language=en-US&with_genres=";
  String genreMovieWithPage = '&page=';
  int genreMoviesIndex = 0;
  int genreMoviesPage = 1;



  String picBase = "https://image.tmdb.org/t/p/w500";

  String genredropdownvalue = "Any";
  String listdropdownvalue = "Popular";

  bool checkIfSeen(int id) {
    if (id == null) {
      return false;
    }
    if (liked.contains(id) || disliked.contains(id)) {
      return true;
    } else {
      return false;
    }
  }

  //WORKING HERE LAST, NOT SURE IF IT WORKS FULLY
  Future<Movie> getMovie(String genre, String list) async {
    if (list == "Popular") {
      if (popularIndex > 19) {
        setState(() {
          popularIndex = 0;
          popularPage += 1;
        });
      }
      var response = await dio.get(popular + popularPage.toString());
      //in here check if they have seen the movie
      //if they have, check if index is 19, if so increment page and reset index
      int id = response.data['results'][popularIndex]['id'];
      while (checkIfSeen(id)) {
        setState(() {
          popularIndex++;
        });
        if (popularIndex > 19) {
          setState(() {
            popularIndex = 0;
            popularPage += 1;
          });
          response = await dio.get(popular + popularPage.toString());
        }
        id = response.data['results'][popularIndex]['id'];
      }
      if (popularIndex > 19) {
        setState(() {
          popularIndex = 0;
          popularPage += 1;
        });
        response = await dio.get(popular + popularPage.toString());
      }
      return Movie.fromJson(response.data['results'][popularIndex]);

    } else if (list == "Top Rated") {
      if (topRatedIndex > 19) {
        setState(() {
          topRatedIndex = 0;
          topRatedPage += 1;
        });
      }
      var response = await dio.get(topRated + topRatedPage.toString());
      //in here check if they have seen the movie
      //if they have, check if index is 19, if so increment page and reset index
      int id = response.data['results'][topRatedIndex]['id'];
      while (checkIfSeen(id)) {
        setState(() {
          topRatedIndex++;
        });
        if (topRatedIndex > 19) {
          setState(() {
            topRatedIndex = 0;
            topRatedPage += 1;
          });
          response = await dio.get(topRated + topRatedPage.toString());
        }
        id = response.data['results'][topRatedIndex]['id'];
      }
      if (topRatedIndex > 19) {
        setState(() {
          topRatedIndex = 0;
          topRatedPage += 1;
        });
        response = await dio.get(topRated + topRatedPage.toString());
      }
      return Movie.fromJson(response.data['results'][topRatedIndex]);

    } else if (list == "Upcoming") {
      if (upcomingIndex > 19) {
        setState(() {
          upcomingIndex = 0;
          upcomingPage += 1;
        });
      }
      var response = await dio.get(upcoming + upcomingPage.toString());
      //in here check if they have seen the movie
      //if they have, check if index is 19, if so increment page and reset index
      int id = response.data['results'][upcomingIndex]['id'];
      while (checkIfSeen(id)) {
        setState(() {
          upcomingIndex++;
        });
        if (upcomingIndex > 19) {
          setState(() {
            upcomingIndex = 0;
            upcomingPage += 1;
          });
          response = await dio.get(upcoming + upcomingPage.toString());
        }
        id = response.data['results'][upcomingIndex]['id'];
      }
      if (upcomingIndex > 19) {
        setState(() {
          upcomingIndex = 0;
          upcomingPage += 1;
        });
        response = await dio.get(upcoming + upcomingPage.toString());
      }
      return Movie.fromJson(response.data['results'][upcomingIndex]);

    } else if (list == "Now Playing") {
      if (nowPlayingIndex > 19) {
        setState(() {
          nowPlayingIndex = 0;
          nowPlayingPage += 1;
        });
      }
      var response = await dio.get(nowPlaying + nowPlayingPage.toString());
      //in here check if they have seen the movie
      //if they have, check if index is 19, if so increment page and reset index
      int id = response.data['results'][nowPlayingIndex]['id'];
      while (checkIfSeen(id)) {
        setState(() {
          nowPlayingIndex++;
        });
        if (nowPlayingIndex > 19) {
          setState(() {
            nowPlayingIndex = 0;
            nowPlayingPage += 1;
          });
          response = await dio.get(nowPlaying + nowPlayingPage.toString());
        }
        id = response.data['results'][nowPlayingIndex]['id'];
      }
      if (nowPlayingIndex > 19) {
        setState(() {
          nowPlayingIndex = 0;
          nowPlayingPage += 1;
        });
        response = await dio.get(nowPlaying + nowPlayingPage.toString());
      }
      return Movie.fromJson(response.data['results'][nowPlayingIndex]);

    } else if (list == "Any"){
      int g;
      int id;
      var response;

      if (genre == "Any") {
        if (allMoviesIndex > 19) {
          setState(() {
            allMoviesIndex = 0;
            allMoviesPage += 1;
          });
        }
        response = await dio.get(allMovies + allMoviesPage.toString());
        id = response.data['results'][allMoviesIndex]['id'];
      } else {
        print(genre);
        if (genreMoviesIndex > 19) {
          setState(() {
            genreMoviesIndex = 0;
            genreMoviesPage += 1;
          });
        }
        //if specified genre only
        g = genre_list[genre];
        response = await dio.get(genreMovies + g.toString() + genreMovieWithPage + genreMoviesPage.toString());
        id = response.data['results'][genreMoviesIndex]['id'];
      }

      while(checkIfSeen(id)) {
        if (genre == "Any") {
          setState(() {
            allMoviesIndex++;
          });
          if (allMoviesIndex > 19) {
            setState(() {
              allMoviesIndex = 0;
              allMoviesPage += 1;
            });
            response = await dio.get(allMovies + allMoviesPage.toString());
          }
          id = response.data['results'][allMoviesIndex]['id'];

        } else {
          print("Seen it IN GENRE");
          print(response.data['results'][genreMoviesIndex]['title']);
          setState(() {
            genreMoviesIndex++;
          });
          if (genreMoviesIndex > 19) {
            setState(() {
              genreMoviesIndex = 0;
              genreMoviesPage += 1;
            });
            response = await dio.get(genreMovies + g.toString() + genreMovieWithPage + genreMoviesPage.toString());
          }
          print(genreMovies + g.toString() + genreMovieWithPage + genreMoviesPage.toString());

          id = response.data['results'][genreMoviesIndex]['id'];

        }
      }
      if (genre == "Any") {
        return Movie.fromJson(response.data['results'][allMoviesIndex]);
      } else {
        print(response.data['results'][genreMoviesIndex]['title']);
        return Movie.fromJson(response.data['results'][genreMoviesIndex]);
      }



    } else {
      print("SOMETHING WENT WILDLY WRONG");
    }
  }

  void changeMovie(String genre, String list) {
    if (this.mounted) {
      if (list == "Popular") {
        setState(() {
          popularIndex++;
        });
      } else if (list == "Top Rated") {
        setState(() {
          topRatedIndex++;
        });
      } else if (list == "Upcoming") {
        setState(() {
          upcomingIndex++;
        });
      } else if (list == "Now Playing") {
        setState(() {
          nowPlayingIndex++;
        });
      } else if (list == "Any") {
        if (genre == "Any") {
          allMoviesIndex++;
        } else {
          genreMoviesIndex++;
        }
      }
    }

    movie = getMovie(genre, list);
  }

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
              liked = value['liked'];
              disliked = value['disliked'];
              movie = getMovie(genredropdownvalue, listdropdownvalue);
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0),
                  child: DropdownButton<String>(
                    value: genredropdownvalue,
                    icon: const Icon(Icons.arrow_downward),
                    iconSize: 24,
                    elevation: 16,
                    style: const TextStyle(color: Colors.black),
                    underline: Container(height: 2, color: Colors.black54,),
                    onChanged: (String newValue) {
                      setState(() {
                        genredropdownvalue = newValue;
                      });
                      movie = getMovie(genredropdownvalue, listdropdownvalue);
                    },
                    items: <String>["Any","Action", "Adventure", "Animation",
                      "Comedy", "Crime", "Documentary", "Drama", "Family", "Fantasy",
                      "History", "Horror", "Music", "Mystery", "Romance", "Science Fiction",
                      "TV Movie", "Thriller", "War", "Western"].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0),
                  child:                       DropdownButton<String>(
                    value: listdropdownvalue,
                    icon: const Icon(Icons.arrow_downward),
                    iconSize: 24,
                    elevation: 16,
                    style: const TextStyle(color: Colors.black),
                    underline: Container(height: 2, color: Colors.black54,),
                    onChanged: (String newValue) {
                      setState(() {
                        listdropdownvalue = newValue;
                      });
                      movie = getMovie(genredropdownvalue, listdropdownvalue);
                    },
                    items: <String>["Popular", "Top Rated", "Upcoming", "Now Playing", "Any"].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            FutureBuilder(
              future: movie,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  int size = snapshot.data.genre.length;
                  List<String> g = new List.filled(size, "");
                  for (int i = 0; i < size; i++) {
                    if (i == size - 1) {
                      g[i] = snapshot.data.genre_list[snapshot.data.genre[i]];
                    } else {
                      g[i] = snapshot.data.genre_list[snapshot.data.genre[i]] + "/";
                    }
                  }
                  return Column(
                    children: [
                      Image(image: NetworkImage(picBase + snapshot.data.pic), width: 250, height: 350,),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                           Flexible( child: Text(snapshot.data.name,style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),overflow: TextOverflow.ellipsis,),),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: 8.0),
                        child:  Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: g.map((item) => new Text(item)).toList(),
                              mainAxisAlignment: MainAxisAlignment.center,
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: 8.0),
                        child: Container(
                          width: 400,
                          height: 75,
                          child: ElevatedButton(
                            style: ButtonStyle(backgroundColor: MaterialStateProperty.resolveWith<Color>(
                                  (Set<MaterialState> states) {
                                return Colors.white; // Use the component's default.
                              },
                            ),
                                shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)))
                            ),
                            child: Text(snapshot.data.desc,softWrap: true, overflow: TextOverflow.fade, style: TextStyle(fontWeight: FontWeight.normal,color: Colors.black,),),
                            onPressed: () {
                              showDialog(context: context, builder: (BuildContext context) {
                                return new AlertDialog(
                                  actions: [
                                    ElevatedButton(onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                      child: Text("Close"),
                                    ),
                                  ],
                                  title: Text("Description"),
                                  content: new Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(snapshot.data.desc,softWrap: true),
                                    ],
                                  ),

                                );
                              });
                            },
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          //put buttons here
                          Padding(
                            padding: EdgeInsets.only(right:16.0, left: 16.0,top: 4),
                            child: ConstrainedBox(
                              constraints: BoxConstraints.tightFor(width: 90, height: 40),
                              child: ElevatedButton(
                                onPressed: () {
                                 List<int> l = [];
                                  l.add(snapshot.data.id);
                                  db.collection('users').doc(uid).update({
                                    'liked' : FieldValue.arrayUnion(l),
                                  });
                                  changeMovie(genredropdownvalue, listdropdownvalue);
                                },
                                child: Text("LIKE?", style: TextStyle(color: Colors.white),),
                                style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.blue)),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(right:16.0, left: 16.0,top:4),
                            child: ConstrainedBox(
                              constraints: BoxConstraints.tightFor(width: 90, height: 40),
                              child: ElevatedButton(
                                onPressed: () {
                                  List<int> l = [];
                                  l.add(snapshot.data.id);
                                  db.collection('users').doc(uid).update({
                                    'disliked' : FieldValue.arrayUnion(l),
                                  });
                                  changeMovie(genredropdownvalue, listdropdownvalue);
                                },
                                child: Text("DISLIKE?", style: TextStyle(color: Colors.white),),
                                style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.red)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                } else if (snapshot.hasError) {
                  return Text(snapshot.error.toString());
                } else {
                  return CircularProgressIndicator();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
//END OF MOVIE PAGE WIDGET

