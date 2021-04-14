class Movie {
  String name;
  String desc;
  List<dynamic> genre;
  int id;
  String pic;
  List<dynamic> watch;
  Map<int, String> genre_list = {
    28:"Action", 12:"Adventure", 16:"Animation",
    35:"Comedy", 80:"Crime", 99:"Documentary", 18:"Drama", 10751:"Family", 14:"Fantasy",
    36:"History", 27:"Horror", 10402:"Music", 9648:"Mystery", 10749:"Romance", 878:"Science Fiction",
    10770:"TV Movie", 53:"Thriller", 10752:"War", 37:"Western"
  };

  Movie({this.name, this.desc, this.genre, this.id, this.pic, this.watch});

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      name: json["title"],
      desc: json["overview"],
      genre: json["genre_ids"],
      id : json['id'],
      pic : json["poster_path"],
    );
  }

  //Json is different when just a single movie is queried
  factory Movie.fromJsonSingle(Map<String, dynamic> json) {
    int size = json['genres'].length;

    List<dynamic> g = [];
    for (int i = 0; i < size; i++){
      g.add(json['genres'][i]['id']);
    }

    return Movie(
      name: json["title"],
      desc: json["overview"],
      genre: g,
      id : json['id'],
      pic : json["poster_path"],
    );
  }
}