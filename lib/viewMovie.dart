import 'package:flutter/material.dart';
import 'package:movie_helper/models/movieModel.dart';
import 'package:dio/dio.dart';
import 'package:movie_helper/loading_screen.dart';

class viewMovie extends StatefulWidget {

final Movie movie;

viewMovie({this.movie});

@override
_viewMovieState createState() => _viewMovieState();

}

class _viewMovieState extends State<viewMovie> {

  String picBase = "https://image.tmdb.org/t/p/w500";
  String base = "https://api.themoviedb.org/3/movie/";
  String apiKey = "?api_key=211ff81d2853a542be703d3104384047&language=en-US";

  Future<Movie> movie;

  var dio = Dio();

  Future<Movie> getMovie() async {
    var response = await dio.get(base + widget.movie.id.toString() + apiKey);
    if (response.statusCode == 200) {
      return Movie.fromJsonSingle(response.data);
    }
  }


  @override
  void initState() {
    super.initState();
    movie = getMovie();
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
                          child: Image(image: NetworkImage(picBase + snapshot.data.pic), width: 350, height: 450,),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              //THIS WIDGET WILL CONTAIN THE DAILY MOVIES TITLE GENRES AND DESCRIPTION
                              Flexible( child: Text(snapshot.data.name,style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),overflow: TextOverflow.ellipsis,),),
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
                      ],
                    )
                  ],
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Text("Something went wrong");
          } else {
            return MyLoadingScreen();
          }
        }

    );
  }
}