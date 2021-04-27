import 'package:flutter/material.dart';
import 'package:movie_helper/models/movieModel.dart';
import 'package:dio/dio.dart';
import 'package:movie_helper/loading_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class viewMovie extends StatefulWidget {

final Movie movie;

viewMovie({this.movie});

@override
_viewMovieState createState() => _viewMovieState();

}

class _viewMovieState extends State<viewMovie> {

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

  Widget _launchStatus(BuildContext context, AsyncSnapshot<void> snapshot) {
    if (snapshot.hasError) {
      return Text('Error: ${snapshot.error}');
    } else {
      return const Text('');
    }
  }


  @override
  void initState() {
    super.initState();
    movie = getMovie();
    providers = getProviders();
  }


  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Future.wait([movie, providers]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.hasData) {
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
                          child: Image(image: NetworkImage(picBase + snapshot.data[0].pic), width: 300, height: 400,),
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
                        Padding(
                          padding: EdgeInsets.only(bottom:4.0, top:6.0),
                          child: size == 0 ? Text("Not available in the US", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),) : Text("Available at:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),),
                        ),
                        size == 0 ? Text("") : Expanded(
                          child: SizedBox(
                            height: 200.0,
                            child: CustomScrollView(
                              slivers: <Widget>[
                                SliverGrid(
                                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                                    maxCrossAxisExtent: 200.0,
                                    mainAxisSpacing: 15.0,
                                    crossAxisSpacing: 10.0,
                                    childAspectRatio: 4.0,
                                  ),
                                  delegate: SliverChildBuilderDelegate(
                                        (BuildContext context, int index) {
                                      return Container(
                                        alignment: Alignment.center,
                                        color: Colors.white,
                                        child: GestureDetector(
                                          child: Text(snapshot.data[1][index]),
                                          onTap: () {
                                            _launched = _launchInBrowser(link);
                                          },
                                        ),
                                      );
                                    },
                                    childCount: size,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
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