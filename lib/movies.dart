import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:movie_helper/models/movieModel.dart';
import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:movie_helper/widgets/helperFunctions.dart';


//BEGINNING OF MOVIE PAGE WIDGET
class MyMoviePage extends StatefulWidget {

  @override
  _MyMovieState createState() => _MyMovieState();
}

class _MyMovieState extends State<MyMoviePage> with SingleTickerProviderStateMixin {

  FirebaseFirestore db = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  String email;
  String uid;
  Future<Movie> movie;
  Future<List<String>> providers;
  Future<void> _launched;

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

  String base = "https://api.themoviedb.org/3/movie/";
  String watchProviders = "/watch/providers";
  String apiKey = "?api_key=211ff81d2853a542be703d3104384047&language=en-US";
  String link;
  bool done = false;

  Map map_liked;
  Map map_disliked;

  String picBase = "https://image.tmdb.org/t/p/w500";

  String genredropdownvalue = "Any";
  String listdropdownvalue = "Any";
  List<dynamic> seen;


  void resetIndices() {
    if (mounted) {
      setState(() {
        popularPage =  1;
        popularIndex = 0;
        nowPlayingPage = 1;
        nowPlayingIndex = 0;
        topRatedPage = 1;
        topRatedIndex = 0;
        upcomingPage = 1;
        upcomingIndex = 0;
        allMoviesPage = 1;
        allMoviesIndex = 0;
        genreMoviesIndex = 0;
        genreMoviesPage = 1;
      });
    }
  }

  Future<List<String>> getProviders(int id) async {
    String base = "https://api.themoviedb.org/3/movie/";
    String watchProviders = "/watch/providers";
    String apiKey = "?api_key=211ff81d2853a542be703d3104384047&language=en-US";

    List<String> namesRent = [];
    List<String> namesBuy = [];
    List<String> namesFlatrate = [];
    var response = await dio.get(base + id.toString() + watchProviders + apiKey);
    if (response.statusCode == 200) {
      if (response.data['results'].length == 0 || response.data['results']["US"] == null) {
        return namesBuy;
      }
      List<dynamic> rent = response.data['results']["US"]['rent'];
      List<dynamic> buy = response.data['results']["US"]['buy'];
      List<dynamic> flatrate = response.data['results']["US"]['flatrate'];
      if (rent != null) {
        for (int i = 0; i < rent.length; i++) {
          namesRent.add(rent[i]['provider_name']);
        }
      }
      if (buy != null) {
        for (int i = 0; i < buy.length; i++) {
          namesBuy.add(buy[i]['provider_name']);
        }
      }
      if (flatrate != null) {
        for (int i = 0; i < flatrate.length; i++) {
          namesFlatrate.add(flatrate[i]['provider_name']);
        }
      }

      if (mounted) {
        setState(() {
          link = response.data["results"]["US"]["link"].toString();
        });
      }
      List<String> names = new List.from(namesRent)..addAll(namesBuy)..addAll(namesFlatrate);
      names = names.toSet().toList();
      return names;
    }
  }

  //WORKING HERE LAST, NOT SURE IF IT WORKS FULLY
  Future<Movie> getMovie(String genre, String list) async {
    if (list == "Popular") {
      if (popularIndex > 19) {
        if (mounted) {
          setState(() {
            popularIndex = 0;
            popularPage += 1;
          });
        }
      }
      var response = await dio.get(popular + popularPage.toString());
      //in here check if they have seen the movie
      //if they have, check if index is 19, if so increment page and reset index
      int id = response.data['results'][popularIndex]['id'];
      List<dynamic> genres = response.data['results'][popularIndex]['genre_ids'];
      if (popularPage >= response.data['total_pages']) {
        throw Exception("Out of pages");
      }
      while (checkIfSeen(id, seen) || !checkIfGenre(genres, genre, genre_list)) {
        if (mounted) {
          setState(() {
            popularIndex++;
          });
        }
        if (popularIndex > 19) {
          if (mounted) {
            setState(() {
              popularIndex = 0;
              popularPage += 1;
            });
          }
          if (popularPage >= response.data['total_pages']) {
            throw Exception("Out of pages");
          }
          response = await dio.get(popular + popularPage.toString());
        }
        id = response.data['results'][popularIndex]['id'];
        genres = response.data['results'][popularIndex]['genre_ids'];
      }
      providers = getProviders(response.data['results'][popularIndex]['id']);
      if (mounted){
        setState(() {
          done = true;
        });
      }
      return Movie.fromJson(response.data['results'][popularIndex]);

    } else if (list == "Top Rated") {
      if (topRatedIndex > 19) {
        if (mounted) {
          setState(() {
            topRatedIndex = 0;
            topRatedPage += 1;
          });
        }
      }
      var response = await dio.get(topRated + topRatedPage.toString());
      if (topRatedPage >= response.data['total_pages']) {
        throw Exception("Out of pages");
      }
      //in here check if they have seen the movie
      //if they have, check if index is 19, if so increment page and reset index
      int id = response.data['results'][topRatedIndex]['id'];
      List<dynamic> genres = response.data['results'][topRatedIndex]['genre_ids'];

      while (checkIfSeen(id, seen) || !checkIfGenre(genres, genre, genre_list)) {
        if (mounted) {
          setState(() {
            topRatedIndex++;
          });
        }
        if (topRatedIndex > 19) {
          if (mounted) {
            setState(() {
              topRatedIndex = 0;
              topRatedPage += 1;
            });
          }
          if (topRatedPage >= response.data['total_pages']) {
            throw Exception("Out of pages");
          }
          response = await dio.get(topRated + topRatedPage.toString());
        }
        id = response.data['results'][topRatedIndex]['id'];
        genres = response.data['results'][topRatedIndex]['genre_ids'];
      }
      providers = getProviders(response.data['results'][topRatedIndex]['id']);
      if (mounted) {
        setState(() {
          done = true;
        });
      }
      return Movie.fromJson(response.data['results'][topRatedIndex]);

    } else if (list == "Upcoming") {
      if (upcomingIndex > 19) {
        if (mounted) {
          setState(() {
            upcomingIndex = 0;
            upcomingPage += 1;
          });
        }
      }
      var response = await dio.get(upcoming + upcomingPage.toString());
      //in here check if they have seen the movie
      //if they have, check if index is 19, if so increment page and reset index
      int id = response.data['results'][upcomingIndex]['id'];
      List<dynamic> genres = response.data['results'][upcomingIndex]['genre_ids'];
      if (upcomingPage >= response.data['total_pages']) {
        throw Exception("Out of pages");
      }
      while (checkIfSeen(id, seen) || !checkIfGenre(genres, genre, genre_list)) {
        if (mounted) {
          setState(() {
            upcomingIndex++;
          });
        }
        if (upcomingIndex > 19) {
          if (mounted) {
            setState(() {
              upcomingIndex = 0;
              upcomingPage += 1;
            });
          }
          if (upcomingPage >= response.data['total_pages']) {
            throw Exception("Out of pages");
          }
          response = await dio.get(upcoming + upcomingPage.toString());
        }
        id = response.data['results'][upcomingIndex]['id'];
        genres = response.data['results'][upcomingIndex]['genre_ids'];
      }
      providers = getProviders(response.data['results'][upcomingIndex]['id']);
      if (mounted) {
        setState(() {
          done = true;
        });
      }
      return Movie.fromJson(response.data['results'][upcomingIndex]);

    } else if (list == "Now Playing") {
      if (nowPlayingIndex > 19) {
        if (mounted) {
          setState(() {
            nowPlayingIndex = 0;
            nowPlayingPage += 1;
          });
        }
      }
      var response = await dio.get(nowPlaying + nowPlayingPage.toString());
      //in here check if they have seen the movie
      //if they have, check if index is 19, if so increment page and reset index
      int id = response.data['results'][nowPlayingIndex]['id'];
      if (nowPlayingPage >= response.data['total_pages']) {
        throw Exception("Out of pages");
      }
      List<dynamic> genres = response.data['results'][nowPlayingIndex]['genre_ids'];

      while (checkIfSeen(id, seen) || !checkIfGenre(genres, genre, genre_list)) {
        if (mounted) {
          setState(() {
            nowPlayingIndex++;
          });
        }
        if (nowPlayingIndex > 19) {
          if (mounted) {
            setState(() {
              nowPlayingIndex = 0;
              nowPlayingPage += 1;
            });
          }
          if (nowPlayingPage >= response.data['total_pages']) {
            throw Exception("Out of pages");
          }
          response = await dio.get(nowPlaying + nowPlayingPage.toString());
        }
        id = response.data['results'][nowPlayingIndex]['id'];
        genres = response.data['results'][nowPlayingIndex]['genre_ids'];
      }
      providers = getProviders(response.data['results'][nowPlayingIndex]['id']);
      if (mounted) {
        setState(() {
          done = true;
        });
      }
      return Movie.fromJson(response.data['results'][nowPlayingIndex]);

    } else if (list == "Any"){
      int g;
      int id;
      var response;
      List<dynamic> genres;

      if (genre == "Any") {
        if (allMoviesIndex > 19) {
         if (mounted) {
           setState(() {
             allMoviesIndex = 0;
             allMoviesPage += 1;
           });
         }
        }
        response = await dio.get(allMovies + allMoviesPage.toString());
        if (allMoviesPage >= response.data['total_pages']) {
          throw Exception("Out of pages");
        }
        id = response.data['results'][allMoviesIndex]['id'];
      } else {
        if (genreMoviesIndex > 19) {
          if (mounted) {
            setState(() {
              genreMoviesIndex = 0;
              genreMoviesPage += 1;
            });
          }
        }
        //if specified genre only
        g = genre_list[genre];
        response = await dio.get(genreMovies + g.toString() + genreMovieWithPage + genreMoviesPage.toString());
        if (genreMoviesPage >= response.data['total_pages']) {
          throw Exception("Out of pages");
        }
        id = response.data['results'][genreMoviesIndex]['id'];
        genres = response.data['results'][genreMoviesIndex]['genre_ids'];
      }

      while(checkIfSeen(id, seen) || !checkIfGenre(genres, genre, genre_list)) {
        if (genre == "Any") {
          if (mounted) {
            setState(() {
              allMoviesIndex++;
            });
          }
          if (allMoviesIndex > 19) {
            if (mounted) {
              setState(() {
                allMoviesIndex = 0;
                allMoviesPage += 1;
              });
            }
            if (allMoviesPage >= response.data['total_pages']) {
              throw Exception("Out of pages");
            }
            response = await dio.get(allMovies + allMoviesPage.toString());
          }
          id = response.data['results'][allMoviesIndex]['id'];

        } else {
          if (mounted) {
            setState(() {
              genreMoviesIndex++;
            });
          }
          if (genreMoviesIndex > 19) {
            if (mounted) {
              setState(() {
                genreMoviesIndex = 0;
                genreMoviesPage += 1;
              });
            }
            if (genreMoviesPage >= response.data['total_pages']) {
              throw Exception("Out of pages");
            }
            response = await dio.get(genreMovies + g.toString() + genreMovieWithPage + genreMoviesPage.toString());
          }
          id = response.data['results'][genreMoviesIndex]['id'];
          genres = response.data['results'][genreMoviesIndex]['genre_ids'];
        }
      }
      if (genre == "Any") {
        providers = getProviders(response.data['results'][allMoviesIndex]['id']);
        if (mounted) {
          setState(() {
            done = true;
          });
        }
        return Movie.fromJson(response.data['results'][allMoviesIndex]);
      } else {
        providers = getProviders(response.data['results'][genreMoviesIndex]['id']);
        if (mounted) {
          setState(() {
            done = true;
          });
        }
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
          setState(() {
            allMoviesIndex++;
          });
        } else {
          setState(() {
            genreMoviesIndex++;
          });
        }
      }
    }

    movie = getMovie(genre, list);
  }

  void onDragEnd(DraggableDetails details, Movie movie) {
    final minimumDrag = 100;
    if (details.offset.dx > minimumDrag) {
      Map l = map_liked;
      List<dynamic> k = [movie.id];
      List<dynamic> a = [movie.name];
      for (int i = 0; i < movie.genre.length; i++) {
        a.add(movie.genre[i]);
      }
      if (mounted) {
        setState(() {
          seen.add(movie.id);
        });
      }
      l[movie.id.toString()] = a;
      db.collection('users').doc(uid).update({
        "seen" : FieldValue.arrayUnion(k),
        'map_liked' : l,
      });
      changeMovie(genredropdownvalue, listdropdownvalue);
    } else if (details.offset.dx < -minimumDrag) {
      Map l = map_disliked;
      List<dynamic> k = [movie.id];
      List<dynamic> a = [movie.name];
      for (int i = 0; i < movie.genre.length; i++) {
        a.add(movie.genre[i]);
      }
      if (mounted) {
        setState(() {
          seen.add(movie.id);
        });
      }
      l[movie.id.toString()] = a;
      db.collection('users').doc(uid).update({
        "seen" : FieldValue.arrayUnion(k),
        'map_disliked' : l,
      });
      changeMovie(genredropdownvalue, listdropdownvalue);
    }
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
              map_liked = value['map_liked'];
              map_disliked = value['map_disliked'];
              seen = value['seen'];
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
                      if (mounted) {
                        setState(() {
                          genredropdownvalue = newValue;
                        });
                      }
                      resetIndices();
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
                      if (mounted) {
                        setState(() {
                          listdropdownvalue = newValue;
                        });
                      }
                        resetIndices();
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
            done == false ? CircularProgressIndicator() : Expanded(child: FutureBuilder(
              future: Future.wait([movie, providers]),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  int size = snapshot.data[0].genre.length;
                  //get genres from the genre ids
                  List<String> g = new List.filled(size, "");
                  for (int i = 0; i < size; i++) {
                    if (i == size - 1) {
                      g[i] = snapshot.data[0].genre_list[snapshot.data[0].genre[i]];
                    } else {
                      g[i] = snapshot.data[0].genre_list[snapshot.data[0].genre[i]] + "/";
                    }
                  }
                  size = snapshot.data[1].length;
                  return Column(
                    children: [
                      Draggable(
                          child: snapshot.data[0].pic != null ? Image(image: NetworkImage(picBase + snapshot.data[0].pic), width: 225, height: 325,) : Image(image: NetworkImage("https://d994l96tlvogv.cloudfront.net/uploads/film/poster/poster-image-coming-soon-placeholder-no-logo-500-x-740_23991.png"), width: 225, height: 325,),
                          feedback: Material(
                            type: MaterialType.transparency,
                            child: snapshot.data[0].pic != null ? Image(image: NetworkImage(picBase + snapshot.data[0].pic), width: 225, height: 325,) : Image(image: NetworkImage("https://d994l96tlvogv.cloudfront.net/uploads/film/poster/poster-image-coming-soon-placeholder-no-logo-500-x-740_23991.png"), width: 225, height: 325,),
                          ),
                        childWhenDragging: Container(height: 325, width: 225,),
                        onDragEnd: (details) => onDragEnd(details, snapshot.data[0]),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                           Flexible( child: Text(snapshot.data[0].name,style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),overflow: TextOverflow.ellipsis,),),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: 8.0),
                        child: FittedBox(
                            fit: BoxFit.fill,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                //THIS WIDGET WILL CONTAIN THE DAILY MOVIES TITLE GENRES AND DESCRIPTION
                                Row(
                                  children: g.map((item) => new Text(item)).toList(),
                                  mainAxisAlignment: MainAxisAlignment.center,
                                ),
                              ],
                            )),
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: 8.0),
                        child: Container(
                          width: 400,
                          height: 50,
                          child: ElevatedButton(
                            style: ButtonStyle(backgroundColor: MaterialStateProperty.resolveWith<Color>(
                                  (Set<MaterialState> states) {
                                return Colors.white; // Use the component's default.
                              },
                            ),
                                shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)))
                            ),
                            child: Text(snapshot.data[0].desc,softWrap: true, overflow: TextOverflow.fade, style: TextStyle(fontWeight: FontWeight.normal,color: Colors.black,),),
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
                                      Text(snapshot.data[0].desc,softWrap: true),
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
                                  Map l = map_disliked;
                                  List<dynamic> a = [snapshot.data[0].name];
                                  List<dynamic> k = [snapshot.data[0].id];
                                  for (int i = 0; i < snapshot.data[0].genre.length; i++) {
                                    a.add(snapshot.data[0].genre[i]);
                                  }
                                  if (mounted) {
                                    setState(() {
                                      seen.add(snapshot.data[0].id);
                                    });
                                  }
                                  l[snapshot.data[0].id.toString()] = a;
                                  db.collection('users').doc(uid).update({
                                    "seen" : FieldValue.arrayUnion(k),
                                    'map_disliked' : l,
                                  });
                                  changeMovie(genredropdownvalue, listdropdownvalue);
                                },
                                child: Text("DISLIKE?", style: TextStyle(color: Colors.white),),
                                style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.red)),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(right:16.0, left: 16.0,top:4),
                            child: ConstrainedBox(
                              constraints: BoxConstraints.tightFor(width: 90, height: 40),
                              child: ElevatedButton(
                                onPressed: () {
                                  Map l = map_liked;
                                  List<dynamic> k = [snapshot.data[0].id];
                                  List<dynamic> a = [snapshot.data[0].name];
                                  for (int i = 0; i < snapshot.data[0].genre.length; i++) {
                                    a.add(snapshot.data[0].genre[i]);
                                  }
                                  if (mounted) {
                                    setState(() {
                                      seen.add(snapshot.data[0].id);
                                    });
                                  }
                                  l[snapshot.data[0].id.toString()] = a;
                                  db.collection('users').doc(uid).update({
                                    "seen" : FieldValue.arrayUnion(k),
                                    'map_liked' : l,
                                  });
                                  changeMovie(genredropdownvalue, listdropdownvalue);
                                },
                                child: Text("LIKE?", style: TextStyle(color: Colors.white),),
                                style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.blue)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom:4.0, top:6.0),
                        child: size == 0 ? Text("Not available in the US", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),) : Text("Available at:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),),
                      ),
                      size == 0 ? Text("") : getWatchProviders(snapshot.data[1], link, size),
                    ],
                  );
                } else if (snapshot.hasError) {
                  return Text("No more movies match these conditions, try again.");
                } else {
                  return CircularProgressIndicator();
                }
              },
            )),
          ],
        ),
      ),
    );
  }
}
//END OF MOVIE PAGE WIDGET

