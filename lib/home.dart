
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
  Timestamp t;

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
              t = value["lastLogin"];
            });
            Timestamp n = Timestamp.now();
            if ((n.seconds - t.seconds) >= 86400) {
              db.collection('users').doc(uid).update({
                "lastLogin" : n,
                "trendingIndex" : 0,
              });
            } else if(trendingIndex >= 20) {
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
              padding: EdgeInsets.only(right:16.0, left:16.0, bottom: 8.0, top:4),
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
  Map combo = {};
  List<dynamic> watchlist;
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore db = FirebaseFirestore.instance;
  Future<List<Movie>> movies;
  Map map_liked;
  Map map_disliked;
  // g[i] = snapshot.data.genre_list[snapshot.data.genre[i]];

  Future<List<Movie>> getMovies(Map movies, String genre, String list) async {
    setState(() {
      done = false;
    });
    List<Movie> newMovies = [];
    movies.forEach((key, value) {
      bool good = true;
      Movie m = new Movie(id: int.parse(key), name: value[0], genre: []);
      for (int i = 1; i < value.length; i++) {
        m.genre.add(value[i]);
      }
      if (list == "All") {

      } else if (list == "Liked") {
        if (!map_liked.containsKey(m.id.toString())) {
          good = false;
        }
      } else if (list == "Disliked") {
        if (!map_disliked.containsKey(m.id.toString())) {
          good = false;
        }
      } else {
        if (!watchlist.contains(m.id)) {
          good = false;
        }
      }
      if (good != false) {
        for (int i = 0; i < m.genre.length; i++) {
          if (genre == "Any" || m.genre_list[m.genre[i]] == genre) {
            newMovies.add(m);
            break;
          }
        }
      }
    });

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
  String listdropdownvalue = "Liked";

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
              map_liked = value['map_liked'];
              map_disliked = value['map_disliked'];
              watchlist = value['watchlist'];
              combo.addAll(map_liked);
              combo.addAll(map_disliked);
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
                                    child: check == false ? Icon(Icons.add_circle_outline, color: Colors.black,) : Icon(Icons.check_circle, color: Colors.black,),
                                    onPressed: () {
                                      List<int> l = [];
                                      l.add(movie.id);
                                      //if check false add to watchlist
                                      if (!check) {
                                       setState(() {
                                         watchlist.add(movie.id);
                                       });
                                        db.collection('users').doc(uid).update({
                                          'watchlist' : watchlist,
                                        });
                                        setState(() {
                                          check = true;
                                        });
                                      } else {
                                        //else remove from watchlist
                                        setState(() {
                                          watchlist.remove(movie.id);
                                        });
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
                                  if (map_liked.containsKey(movie.id.toString())) {
                                    setState(() {
                                      map_liked.remove(movie.id.toString());
                                    });
                                    db.collection('users').doc(uid).update({
                                      'map_liked' : map_liked,
                                    });
                                  } else if (map_disliked.containsKey(movie.id.toString())) {
                                    setState(() {
                                      map_disliked.remove(movie.id.toString());
                                    });
                                    db.collection('users').doc(uid).update({
                                      'map_disliked' : map_disliked,
                                    });
                                  }
                                  if (watchlist.contains(movie.id)) {
                                    setState(() {
                                      watchlist.remove(movie.id);
                                    });
                                    db.collection('users').doc(uid).update({
                                      'watchlist' : watchlist,
                                    });
                                  }
                                  setState(() {
                                    combo.clear();
                                    combo.addAll(map_liked);
                                    combo.addAll(map_disliked);
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
  Timestamp time;
  int index;
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore db = FirebaseFirestore.instance;
  bool done = false;
  Map map_liked;
  Map map_disliked;
  List<dynamic> seen;

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
    if (seen.contains(id)) {
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
              index = value['trendingIndex'];
              time = value['lastLogin'];
              map_liked = value['map_liked'];
              map_disliked = value['map_disliked'];
              seen = value['seen'];
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
                      Flexible( child: Text(snapshot.data.name,style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),overflow: TextOverflow.ellipsis,),)
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
                      padding: EdgeInsets.only(right:16.0, left:16.0, bottom:8),
                      child: ConstrainedBox(
                        constraints: BoxConstraints.tightFor(width: 90, height: 40),
                        child: ElevatedButton(
                          onPressed: () {
                            Map l = map_liked;
                            List<dynamic> k = [snapshot.data.id];
                            List<dynamic> a = [snapshot.data.name];
                            for (int i = 0; i < snapshot.data.genre.length; i++) {
                              a.add(snapshot.data.genre[i]);
                            }
                            l[snapshot.data.id.toString()] = a;
                            db.collection('users').doc(uid).update({
                              "seen" : FieldValue.arrayUnion(k),
                              'map_liked' : l,
                            });
                            changeMovie();
                          },
                          child: Text("LIKE?", style: TextStyle(color: Colors.white),),
                          style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.blue)),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(right:16.0, left:16.0, bottom:8),
                      child: ConstrainedBox(
                        constraints: BoxConstraints.tightFor(width: 90, height: 40),
                        child: ElevatedButton(
                          onPressed: () {
                            Map l = map_disliked;
                            List<dynamic> k = [snapshot.data.id];
                            List<dynamic> a = [snapshot.data.name];
                            for (int i = 0; i < snapshot.data.genre.length; i++) {
                              a.add(snapshot.data.genre[i]);
                            }
                            l[snapshot.data.id.toString()] = a;
                            db.collection('users').doc(uid).update({
                              "seen" : FieldValue.arrayUnion(k),
                              'map_disliked' : l,
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

