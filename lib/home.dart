
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:movie_helper/models/movieModel.dart';
import 'package:dio/dio.dart';
import 'package:movie_helper/viewMovie.dart';
import 'package:movie_helper/loading_screen.dart';


class MyHomePage extends StatefulWidget {


  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  FirebaseFirestore db = FirebaseFirestore.instance;

  FirebaseAuth auth = FirebaseAuth.instance;
  String email;
  String uid;
  int trendingIndex;
  int page = 0;
  bool check = false;

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
              trendingIndex = value['trendingIndex'];
            });
            if (trendingIndex >= 20) {
              setState(() {
                page = 1;
              });
            }
            setState(() {
              check = true;
            });
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final PageController pageController = PageController(initialPage: page);
    //EMAIL and UID is the current users identifiers
    //Get identifiers from shared prefs on any screen
    return check == false ? CircularProgressIndicator() : Scaffold(
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
      children: [
        //Put ROWS of different widgets here, like make widget that returns a row for top title,
        //then widget that returns the movie title and genre, then description, then buttons

        //This row is just for MOVIE OF THE DAY
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("Trending Now", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),),
            ),
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

  String email, uid;
  List<dynamic> liked;
  List<dynamic> disliked;
  List<dynamic> combo;
  List<dynamic> watchlist;
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore db = FirebaseFirestore.instance;
  Future<List<Movie>> movies;

  // g[i] = snapshot.data.genre_list[snapshot.data.genre[i]];

  Future<List<Movie>> getMovies(List<dynamic> movies, String genre, String list) async {
    setState(() {
      done = false;
    });
    List<Movie> newMovies = [];
    for (int i = movies.length-1; i >= 0; i--) {
      final response = await dio.get(oneMovie + movies[i].toString() + apiKey);
      if (response.statusCode == 200) {
        Movie m = Movie.fromJsonSingle(response.data);
        if (list == "All") {

        } else if (list == "Liked") {
          if (!liked.contains(m.id)) {
            continue;
          }
        } else if (list == "Disliked") {
          if (!disliked.contains(m.id)) {
            continue;
          }
        } else {
          if (!watchlist.contains(m.id)) {
            continue;
          }
        }
        for (int i = 0; i < m.genre.length; i++) {
          if (genre == "Any" || m.genre_list[m.genre[i]] == genre) {
            newMovies.add(m);
            break;
          }
        }
      }
    }
    setState(() {
      done = true;
    });
    return newMovies;
  }


  String picBase = "https://image.tmdb.org/t/p/w500";

  //for individual movie, append id between oneMovie and apiKey
  String oneMovie = "https://api.themoviedb.org/3/movie/";

  String watchProviders = "/watch/providers?api_key=211ff81d2853a542be703d3104384047";

  String apiKey = "?api_key=211ff81d2853a542be703d3104384047";

  bool done = false;

  String genredropdownvalue = "Any";
  String listdropdownvalue = "All";

  var dio = Dio();

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
              watchlist = value['watchlist'];
              combo = liked + disliked;
              movies = getMovies(combo, genredropdownvalue, listdropdownvalue);
            });
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: movies,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Center(
              child: Column(
                children: [
                  Padding(
                    child: Text("Liked/Disliked Movies", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),),
                    padding: EdgeInsets.only(top: 20),
                  ),
                  //Put downdowns here
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
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
                              movies = getMovies(combo, genredropdownvalue, listdropdownvalue);
                            });
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
                        padding: EdgeInsets.all(16.0),
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
                              movies = getMovies(combo, genredropdownvalue, listdropdownvalue);
                            });
                          },
                          items: <String>["Liked", "Disliked", "Watchlist", "All"].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left:28.0, top: 8.0, bottom: 8.0),
                        child: Text("Watchlist"),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                        child: Text("Movie"),
                      ),
                      Padding(
                        padding: EdgeInsets.only(right:28.0, top: 8.0, bottom: 8.0),
                        child: Text("Remove"),
                      ),

                    ],
                  ),
                  done == false ? CircularProgressIndicator() : snapshot.data.length == 0 ? noMovies() : Expanded(child: ListView.builder(
                      itemCount: snapshot.data.length,
                      itemBuilder: (context, index) {
                        bool check = false;
                        final movie = snapshot.data[index];
                        int size = movie.genre.length;
                        if (size > 2) {
                          size = 2;
                        }
                        List<String> g = new List.filled(size, "");
                        for (int i = 0; i < size; i++) {
                          if (i == size - 1) {
                            g[i] = movie.genre_list[movie.genre[i]];
                          } else {
                            g[i] = movie.genre_list[movie.genre[i]] + "/";
                          }
                        }
                        if (watchlist.contains(movie.id)) {
                          check = true;
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
                                Navigator.of(context).push(MaterialPageRoute(builder: (context) => viewMovie(movie: movie)));
                              },
                              contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                              leading: Container(
                                padding: EdgeInsets.only(right: 12.0),
                                decoration: BoxDecoration(
                                  border: Border(right: BorderSide(width: 1,color: Colors.black)),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.only(top:8),
                                  child: ElevatedButton(
                                    style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.white)),
                                    child: check == false ? Icon(Icons.add_circle_outline, color: Colors.black,) : Icon(Icons.remove_red_eye, color: Colors.black,),
                                    onPressed: () {
                                      List<int> l = [];
                                      l.add(movie.id);
                                      //if check false add to watchlist
                                      if (!check) {
                                        watchlist.add(movie.id);
                                        db.collection('users').doc(uid).update({
                                          'watchlist' : FieldValue.arrayUnion(l),
                                        });
                                        setState(() {
                                          check = true;
                                        });
                                      } else {
                                        //else remove from watchlist
                                        watchlist.remove(movie.id);
                                        db.collection('users').doc(uid).update({
                                          'watchlist' : watchlist,
                                        });
                                        setState(() {
                                          check = false;
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ),
                              title: Text(movie.name,style:TextStyle(fontSize: 20, color: Colors.black),),
                              subtitle: Row(
                                children: g.map((item) => new Text(item, style: TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis,)).toList(),
                              ),
                              trailing: ElevatedButton(

                                child: Icon(Icons.remove,color: Colors.black,size: 30.0,),
                                onPressed: () {
                                  if (liked.contains(movie.id)) {
                                    List<dynamic> n = liked;
                                    liked.remove(movie.id);
                                    db.collection('users').doc(uid).update({
                                      'liked' : n,
                                    });
                                    setState(() {
                                      liked = n;
                                    });
                                  } else if (disliked.contains(movie.id)) {
                                    List<dynamic> n = disliked;
                                    disliked.remove(movie.id);
                                    db.collection('users').doc(uid).update({
                                      'disliked' : n,
                                    });
                                    setState(() {
                                      disliked = n;
                                    });
                                  }
                                  if (watchlist.contains(movie.id)) {
                                    List<dynamic> n = watchlist;
                                    watchlist.remove(movie.id);
                                    db.collection('users').doc(uid).update({
                                      'watchlist' : n,
                                    });
                                    setState(() {
                                      watchlist = n;
                                    });
                                  }
                                  setState(() {
                                    combo = liked + disliked;
                                  });
                                  movies = getMovies(combo, genredropdownvalue, listdropdownvalue);
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Text("Something went wrong, try again later");
          } else {
            return MyLoadingScreen();
          }
        }
    );
  }
}

class MovieOfDay extends StatefulWidget {
  @override
  _MovieOfDayState createState() => _MovieOfDayState();
}

class _MovieOfDayState extends State<MovieOfDay> {

  String email, uid;
  List<dynamic> liked;
  List<dynamic> disliked;
  Timestamp time;
  int index;
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore db = FirebaseFirestore.instance;
  bool done = false;

  var dio = Dio();

  Future<Movie> movie;

  String picBase = "https://image.tmdb.org/t/p/w500";

  String oneMovie = "https://api.themoviedb.org/3/movie/";

  String apiKey = "?api_key=211ff81d2853a542be703d3104384047";

  String trending = "https://api.themoviedb.org/3/trending/movie/day?api_key=211ff81d2853a542be703d3104384047";


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

  void changeMovie() {
    if (this.mounted) {
      setState(() {
        index++;
      });
    }
    db.collection("users").doc(uid).update({
      "trendingIndex" : index,
    });
    movie = fetchTrending();
  }

  Future<Movie> fetchTrending() async {
    bool done = false;
    int id;
    final response = await dio.get(trending);
    if (response.statusCode == 200) {
      Timestamp t = Timestamp.now();

      if ((t.seconds - time.seconds) >= 86400) {
        //if its been more than a day, reset trending index and time
        index = 0;
        time = t;
        db.collection('users').doc(uid).update({
          'lastLogin' : t,
          'trendingIndex' : 0,
        });
      }

      //get id of next movie to see if user has already seen it

      if (index == 20) {
        throw Exception("Failed to load movie");
      }

      id = response.data['results'][index]['id'];

      while (checkIfSeen(id)) {
        //print(id.toString());
        print("has been seen");
        if (this.mounted) {
          setState(() {
            index += 1;
          });
        }
        db.collection('users').doc(uid).update({
          'trendingIndex' : index,
        });

        if (index == 20) {
          throw Exception("Failed to load movie");
        }
        id = response.data['results'][index]['id'];
      }
      return Movie.fromJson(response.data['results'][index]);
    } else {

      print(response.statusCode);
      throw Exception("Failed to load movie");
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
              liked = value['liked'];
              disliked = value['disliked'];
              index = value['trendingIndex'];
              time = value['lastLogin'];
              movie = fetchTrending();
              done = true;
            });
          });
        }
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image(image: NetworkImage(picBase + snapshot.data.pic), width: 250, height: 350,),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      //THIS WIDGET WILL CONTAIN THE DAILY MOVIES TITLE GENRES AND DESCRIPTION
                      Text(snapshot.data.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
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
                      Expanded(child: Text(snapshot.data.desc)),
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
                          onPressed: () {
                            List<int> l = [];
                            l.add(snapshot.data.id);
                            db.collection('users').doc(uid).update({
                              'liked' : FieldValue.arrayUnion(l),
                            });
                            changeMovie();
                          },
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
                          onPressed: () {
                            List<int> l = [];
                            l.add(snapshot.data.id);
                            db.collection('users').doc(uid).update({
                              'disliked' : FieldValue.arrayUnion(l),
                            });
                            changeMovie();
                          },
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
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 240, right: 20, left: 20),
                    child: Text("You have seen all the trending movies for the day. Come back tomorrow for more!", style: TextStyle(fontSize: 20),),
                  ),
                ],
              ),
            );
          } else {
            return Padding(
              padding: EdgeInsets.only(top: 240),
              child: CircularProgressIndicator(),
            );
          }
        }
    );
  }
}


Widget noMovies() {
  return Expanded(child: ListView.builder(
    itemCount: 1,
    itemBuilder: (context, index) {
      return Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Text("None of your Movies match these conditions, try again"),
        ),
      );
    },
  ),
  );
}

