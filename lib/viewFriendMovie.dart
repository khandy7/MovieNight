import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:movie_helper/models/movieModel.dart';
import 'package:dio/dio.dart';
import 'package:movie_helper/loading_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:movie_helper/widgets/helperFunctions.dart';

class viewFriendMovie extends StatefulWidget {

  final Movie movie;

  viewFriendMovie({this.movie});

  @override
  _viewFriendMovieState createState() => _viewFriendMovieState();

}

class _viewFriendMovieState extends State<viewFriendMovie> {

  String picBase = "https://image.tmdb.org/t/p/w500";
  String base = "https://api.themoviedb.org/3/movie/";
  String watchProviders = "/watch/providers";
  String apiKey = "?api_key=211ff81d2853a542be703d3104384047&language=en-US";
  String link;

  Future<Movie> movie;
  Future<List<String>> providers;
  Future<void> _launched;


  var dio = Dio();

  Future<Movie> getMovie() async {
    var response = await dio.get(base + widget.movie.id.toString() + apiKey);
    if (response.statusCode == 200) {
      return Movie.fromJsonSingle(response.data);
    }
  }


  Future<List<String>> getProviders() async {
    List<String> namesRent = [];
    List<String> namesBuy = [];
    List<String> namesFlatrate = [];
    var response = await dio.get(base + widget.movie.id.toString() + watchProviders + apiKey);
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

  Future<void> _launchInBrowser(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: false,
        forceWebView: false,
        headers: <String, String>{'my_header_key': 'my_header_value'},
      );
    } else {
      throw 'Could not launch $url';
    }
  }

  String email;
  String uid;
  Map map_liked;
  Map map_disliked;
  List<dynamic> watchlist;
  List<dynamic> seen;
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore db = FirebaseFirestore.instance;
  bool done = false;

  @override
  void initState() {
    super.initState();
    if (mounted) {
      setState(() {
        email = auth.currentUser.email.toString();
        uid = auth.currentUser.uid.toString();
      });
      db.collection('users').doc(uid).get().then((value) {
        if (mounted) {
          setState(() {
            map_liked = value['map_liked'];
            map_disliked = value['map_disliked'];
            watchlist = value['watchlist'];
            seen = value['seen'];
            done = true;
          });
        }
      });
    }
    movie = getMovie();
    providers = getProviders();
  }


  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Future.wait([movie, providers]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.hasData) {
            bool s = false;
            bool liked = false;
            bool watch = false;
            int size = snapshot.data[0].genre.length;
            List<String> g = new List.filled(size, "");
            for (int i = 0; i < size; i++) {
              if (i == size - 1) {
                g[i] = snapshot.data[0].genre_list[snapshot.data[0].genre[i]];
              } else {
                g[i] = snapshot.data[0].genre_list[snapshot.data[0].genre[i]] + "/";
              }
            }
            size = snapshot.data[1].length;
            if (seen.contains(snapshot.data[0].id)) {
              s = true;
              if (!map_liked.containsKey(snapshot.data[0].id.toString()) && !map_disliked.containsKey(snapshot.data[0].id.toString())) {
                s = false;
              }
            }
            if (watchlist.contains(snapshot.data[0].id)) {
              watch = true;
            }
            if (map_liked.containsKey(snapshot.data[0].id.toString())) {
              liked = true;
            }
            return Scaffold(
              appBar: AppBar(
                centerTitle: true,
                title: Text("View Movie"),
              ),
              body: Center(
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: snapshot.data[0].pic == null ? Image(image: NetworkImage("https://d994l96tlvogv.cloudfront.net/uploads/film/poster/poster-image-coming-soon-placeholder-no-logo-500-x-740_23991.png"), width: 225, height: 325,) : Image(image: NetworkImage(picBase + snapshot.data[0].pic), width: 225, height: 325,),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          //THIS WIDGET WILL CONTAIN THE DAILY MOVIES TITLE GENRES AND DESCRIPTION
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
                        height: 100,
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
                    s == false ? Text("") : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        liked == false ? Text("       Watchlist") : Text("     Watchlist"),
                        liked == false ? Text("Currently Disliked") : Text("Currently Liked"),
                      ],
                    ),
                    s == false ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
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
                                setState(() {
                                  s = true;
                                });
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
                                setState(() {
                                  s = true;
                                  liked = true;
                                });
                              },
                              child: Text("LIKE?", style: TextStyle(color: Colors.white),),
                              style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.blue)),
                            ),
                          ),
                        ),
                      ],
                    ) : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(right: 30, top: 4, bottom: 4),
                          child: ConstrainedBox(
                            constraints: BoxConstraints.tightFor(width: 90, height: 40),
                            child: ElevatedButton(
                              style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.white)),
                              child: watch == false ? Icon(Icons.add_circle_outline, color: Colors.black,) : Icon(Icons.check_circle, color: Colors.black,),
                              onPressed: () {
                                if (watch == false) {
                                  if (mounted) {
                                    setState(() {
                                      watchlist.add(snapshot.data[0].id);
                                    });
                                  }
                                  db.collection('users').doc(uid).update({
                                    'watchlist' : watchlist,
                                  });
                                  if (mounted) {
                                    setState(() {
                                      watch = true;
                                    });
                                  }
                                } else {
                                  if (mounted) {
                                    setState(() {
                                      watchlist.remove(snapshot.data[0].id);
                                    });
                                  }
                                  db.collection('users').doc(uid).update({
                                    'watchlist' : watchlist,
                                  });
                                  if (mounted) {
                                    setState(() {
                                      watch = false;
                                    });
                                  }
                                }
                              },
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 25, top: 4, bottom: 4),
                          child: ConstrainedBox(
                            constraints: BoxConstraints.tightFor(width: 90, height: 40),
                            child:  ElevatedButton(
                              style: liked == false ?  ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.red)) : ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.blue)),
                              onPressed: () {
                                if (liked) {
                                  //remove from liked, add to disliked
                                  Map l = map_disliked;
                                  List<dynamic> a = [snapshot.data[0].name];
                                  for (int i = 0; i < snapshot.data[0].genre.length; i++) {
                                    a.add(snapshot.data[0].genre[i]);
                                  }
                                  l[snapshot.data[0].id.toString()] = a;
                                  db.collection('users').doc(uid).update({
                                    'map_disliked' : l,
                                  });
                                  if (mounted) {
                                    setState(() {
                                      map_liked.remove(snapshot.data[0].id.toString());
                                    });
                                  }
                                  db.collection('users').doc(uid).update({
                                    'map_liked' : map_liked,
                                  });
                                  setState(() {
                                    liked = false;
                                  });

                                } else {
                                  //remove from disliked, add to liked\
                                  Map l = map_liked;
                                  List<dynamic> a = [snapshot.data[0].name];
                                  for (int i = 0; i < snapshot.data[0].genre.length; i++) {
                                    a.add(snapshot.data[0].genre[i]);
                                  }
                                  l[snapshot.data[0].id.toString()] = a;
                                  db.collection('users').doc(uid).update({
                                    'map_liked' : l,
                                  });
                                  if (mounted) {
                                    setState(() {
                                      map_disliked.remove(snapshot.data[0].id.toString());
                                    });
                                  }
                                  db.collection('users').doc(uid).update({
                                    'map_disliked' : map_disliked,
                                  });
                                  setState(() {
                                    liked = true;
                                  });
                                }
                              },
                              child: liked == false ? Text("Move to liked", style: TextStyle(color: Colors.black),) : Text("Move to disliked",style: TextStyle(color: Colors.black)),
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
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          } else {
            return MyLoadingScreen();
          }
        }

    );
  }
}