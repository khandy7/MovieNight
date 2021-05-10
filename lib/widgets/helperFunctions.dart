import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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


Widget getWatchProviders(List<dynamic> names, String link, int size) {
  Future<void> _launched;
  return Expanded(
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
                    child: Text(names[index]),
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
  );
}


bool checkIfSeen(int id, List<dynamic> seen) {
  if (id == null) {
    return false;
  }
  if (seen.contains(id)) {
    return true;
  } else {
    return false;
  }
}

bool checkIfGenre(List<dynamic> genres, String genre, Map genre_list) {
  if (genre == "Any") {
    return true;
  } else {
    for (int i = 0; i < genres.length; i++) {
      if (genre_list[genre] == genres[i]) {
        return true;
      }
    }
  }
  return false;
}
