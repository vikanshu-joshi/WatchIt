import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:line_awesome_icons/line_awesome_icons.dart';
import 'package:watchit/database.dart';

class MovieDetail extends StatefulWidget {
  final LinkedHashMap<String, dynamic> detail;

  MovieDetail(this.detail);

  @override
  _MovieDetailState createState() => _MovieDetailState();
}

class _MovieDetailState extends State<MovieDetail> {
  LinkedHashMap<dynamic, dynamic> json;
  PageController _screenshotsController;
  LinkedHashMap<dynamic, dynamic> _suggestionsData;
  FavouritesProvider _favourites;
  bool _isFavourite = false;

  void _getMovieDetail() async {
    var response = await http.get(
        'https://yts.mx/api/v2/movie_details.json?movie_id=' +
            widget.detail['id'].toString() +
            '&with_images=true&with_cast=true');
    json = jsonDecode(response.body);
    if (mounted) setState(() {});
    String url = 'https://yts.mx/api/v2/movie_suggestions.json?movie_id=' +
        widget.detail['id'].toString();
    response = await http.get(url);
    _suggestionsData = jsonDecode(response.body);
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    _favourites = FavouritesProvider();
    _screenshotsController = PageController(initialPage: 0, keepPage: false);
    _getMovieDetail();
    _favourites.open('favourites.db').then((_) {
      _favourites.getFavourites(widget.detail['id'].toString()).then((value) {
        if (value != null) {
          _isFavourite = true;
          if (mounted) setState(() {});
        }
      });
    });
    super.initState();
  }

  Widget _screenShots(MediaQueryData mQuery, Orientation orientation) {
    return Container(
      width: mQuery.size.width,
      height: orientation == Orientation.portrait
          ? mQuery.size.height * 0.3
          : mQuery.size.height * 0.9,
      child: PageView.builder(
          controller: _screenshotsController,
          itemBuilder: (_, index) {
            return json == null
                ? Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20)),
                    margin: const EdgeInsets.all(10),
                    width: mQuery.size.width,
                    height: mQuery.size.height * 0.3,
                    child: CupertinoActivityIndicator(
                      animating: true,
                    ),
                  )
                : Container(
                    margin: const EdgeInsets.all(10),
                    width: mQuery.size.width,
                    height: mQuery.size.height * 0.3,
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: CachedNetworkImage(
                            errorWidget: (c, s, _) {
                              return Container(
                                width: mQuery.size.width,
                                height: mQuery.size.height * 0.3,
                                padding: const EdgeInsets.all(85),
                                color: Color.fromRGBO(90, 90, 90, 1),
                                child: Image.asset('assets/images/logo.png'),
                              );
                            },
                            placeholder: (c, s) {
                              return Container(
                                width: mQuery.size.width,
                                height: mQuery.size.height * 0.3,
                                color: Colors.white,
                                child: CupertinoActivityIndicator(
                                  animating: true,
                                ),
                              );
                            },
                            fit: BoxFit.fill,
                            imageUrl: json['data']['movie'][
                                'medium_screenshot_image' +
                                    ((index % 3) + 1).toString()])),
                  );
          }),
    );
  }

  @override
  void dispose() {
    _favourites.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var mQuery = MediaQuery.of(context);
    return Scaffold(
      body: OrientationBuilder(
        builder: (ctx, orientation) => Stack(
          fit: StackFit.expand,
          children: <Widget>[
            CachedNetworkImage(
              fit: BoxFit.fill,
              width: mQuery.size.width,
              height: mQuery.size.height,
              imageUrl: widget.detail['medium_cover_image'],
              placeholder: (c, s) {
                return Container(
                  width: mQuery.size.width,
                  height: mQuery.size.height,
                  padding: const EdgeInsets.all(60),
                  color: Color.fromRGBO(90, 90, 90, 1),
                  child: Image.asset('assets/images/logo.png'),
                );
              },
              errorWidget: (c, s, _) {
                return Container(
                  width: mQuery.size.width,
                  height: mQuery.size.height,
                  padding: const EdgeInsets.all(60),
                  color: Color.fromRGBO(90, 90, 90, 1),
                  child: Image.asset('assets/images/logo.png'),
                );
              },
            ),
            Container(
              color: Colors.black.withOpacity(0.5),
              width: mQuery.size.width,
              height: mQuery.size.height,
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      _screenShots(mQuery, orientation),
                      Container(
                          child: ListTile(
                        title: Text(
                          widget.detail['title'],
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold),
                        ),
                        trailing: IconButton(
                            icon: Icon(
                              _isFavourite
                                  ? LineAwesomeIcons.heart
                                  : LineAwesomeIcons.heart_o,
                              color: _isFavourite ? Colors.red : Colors.white,
                            ),
                            onPressed: () {
                              if (_isFavourite) {
                                _isFavourite = false;
                                _favourites
                                    .delete(widget.detail['id'].toString());
                              } else {
                                _isFavourite = true;
                                var data = Favourites(
                                    widget.detail['id'].toString(),
                                    widget.detail['title'].toString(),
                                    widget.detail['title_long'].toString(),
                                    widget.detail['year'].toString(),
                                    widget.detail['rating'].toString(),
                                    widget.detail['runtime'].toString(),
                                    widget.detail['description_full']
                                        .toString(),
                                    widget.detail['medium_cover_image']
                                        .toString());
                                _favourites.insert(data);
                              }
                              setState(() {});
                            }),
                      )),
                      Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(top: 50, bottom: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Text(widget.detail['year'].toString(),
                                style: TextStyle(
                                  color: Colors.white,
                                )),
                            Container(
                              child: Row(
                                children: <Widget>[
                                  Icon(
                                    LineAwesomeIcons.star,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(widget.detail['rating'].toString(),
                                      style: TextStyle(
                                        color: Colors.white,
                                      ))
                                ],
                              ),
                            ),
                            Container(
                              child: Row(
                                children: <Widget>[
                                  Icon(
                                    Icons.access_time,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                      widget.detail['runtime'].toString() +
                                          ' min',
                                      style: TextStyle(
                                        color: Colors.white,
                                      ))
                                ],
                              ),
                            ),
                            Container(
                              child: Row(
                                children: <Widget>[
                                  Icon(
                                    Icons.play_arrow,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text('Trailer',
                                      style: TextStyle(
                                        color: Colors.white,
                                      ))
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Divider(
                          color: Colors.white,
                        ),
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          width: mQuery.size.width,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              RaisedButton.icon(
                                padding: const EdgeInsets.only(
                                    top: 10, bottom: 10, right: 20, left: 10),
                                onPressed: () {},
                                icon: Icon(LineAwesomeIcons.play,
                                    color: Colors.white),
                                label: Text('Watch Now',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 18)),
                                color: Colors.green,
                              ),
                              RaisedButton.icon(
                                padding: const EdgeInsets.only(
                                    top: 10, bottom: 10, right: 20, left: 10),
                                onPressed: () {},
                                icon: Icon(LineAwesomeIcons.download,
                                    color: Colors.white),
                                label: Text('Download',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 18)),
                                color: Colors.blue,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Divider(
                          color: Colors.white,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(widget.detail['description_full'],
                            textAlign: TextAlign.justify,
                            style: TextStyle(
                                height: 1.5,
                                color: Colors.white,
                                letterSpacing: 0.5,
                                wordSpacing: 1)),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Divider(
                          color: Colors.white,
                        ),
                      ),
                      Container(
                        height: orientation == Orientation.portrait
                            ? mQuery.size.height * 0.25
                            : mQuery.size.height * 0.5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Text(
                                'Suggestions',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _suggestionsData == null
                                      ? 10
                                      : _suggestionsData['data']['movies']
                                          .length,
                                  itemBuilder: (_, index) {
                                    return _suggestionsData == null
                                        ? Container(
                                            color: Colors.white,
                                            margin: const EdgeInsets.all(5),
                                            width: orientation ==
                                                    Orientation.portrait
                                                ? mQuery.size.width * 0.3
                                                : mQuery.size.width * 0.2,
                                            child: CupertinoActivityIndicator(),
                                          )
                                        : GestureDetector(
                                            onTap: () {
                                              Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (_) =>
                                                          MovieDetail(
                                                              _suggestionsData[
                                                                          'data']
                                                                      ['movies']
                                                                  [index])));
                                            },
                                            child: Tooltip(
                                              message: _suggestionsData['data']
                                                      ['movies'][index]
                                                  ['title_long'],
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(1),
                                                color: Colors.white,
                                                margin: const EdgeInsets.all(5),
                                                width: orientation ==
                                                        Orientation.portrait
                                                    ? mQuery.size.width * 0.3
                                                    : mQuery.size.width * 0.2,
                                                child: CachedNetworkImage(
                                                  imageUrl: _suggestionsData[
                                                              'data']['movies']
                                                          [index]
                                                      ['medium_cover_image'],
                                                  fit: BoxFit.fill,
                                                  placeholder: (c, s) {
                                                    return Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              50),
                                                      color: Color.fromRGBO(
                                                          90, 90, 90, 1),
                                                      child: Image.asset(
                                                          'assets/images/logo.png'),
                                                    );
                                                  },
                                                  errorWidget: (c, s, _) {
                                                    return Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              50),
                                                      color: Color.fromRGBO(
                                                          90, 90, 90, 1),
                                                      child: Image.asset(
                                                          'assets/images/logo.png'),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                          );
                                  }),
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 100,
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
