import 'dart:async';
import 'dart:collection';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:line_awesome_icons/line_awesome_icons.dart';
import 'package:watchit/screens/search_screen.dart';
import 'package:connectivity/connectivity.dart';
import 'dart:convert' as convert;

import 'movie_detail.dart';

class HomeScreen extends StatefulWidget {
  static const route = 'home';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> _genre = [
    '3D Movies',
    'Latest',
    'Animation',
    'Action',
    'Adventure',
    'Comedy',
    'Crime',
    'Drama',
    'Fantasy',
    'Mystery',
    'Romance',
    'Thriller',
  ];
  List<LinkedHashMap<dynamic, dynamic>> json =
      List<LinkedHashMap<dynamic, dynamic>>(12);
  List<http.Response> response = List<http.Response>(12);
  bool _networkConnection = true;
  StreamSubscription<ConnectivityResult> _networkListener;

  @override
  void initState() {
    _connectivityChecker();
    _getMoviesList();
    _networkListener =
        Connectivity().onConnectivityChanged.listen((connectivityResult) {
      bool result = (connectivityResult == ConnectivityResult.mobile ||
          connectivityResult == ConnectivityResult.wifi);
      if (!_networkConnection && result) {
        _networkConnection = true;
        _getMoviesList();
      } else if (_networkConnection && !result) {
        _networkConnection = false;
      }
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    _networkListener.cancel();
    super.dispose();
  }

  void _connectivityChecker() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    _networkConnection = (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi);
    if (mounted) setState(() {});
  }

  Future<void> _getMoviesList() async {
    String url;
    for (int i = 0; i < _genre.length; i++) {
      if (i == 0) {
        url =
            'https://yts.mx/api/v2/list_movies.json?quality=3D&limit=50&sort_by=year&order_by=desc';
      } else if (i == 1) {
        url =
            'https://yts.mx/api/v2/list_movies.json?limit=50&sort_by=year&order_by=desc';
      } else {
        url = 'https://yts.mx/api/v2/list_movies.json?genre=' +
            _genre[i] +
            '&limit=50&sort_by=year&order_by=desc';
      }
      response[i] = await http.get(url);
      json[i] = convert.jsonDecode(response[i].body);
      if (mounted) {
        setState(() {});
      }
    }
  }

  Widget _noConnectionScreen(MediaQueryData mQuery) {
    return Container(
      width: mQuery.size.width,
      height: mQuery.size.height,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Image.asset(
            'assets/images/error.png',
            width: mQuery.size.width * 0.3,
            height: mQuery.size.height * 0.3,
          ),
          Text('No Internet',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 22),)
        ],
      ),
    );
  }

  Widget _mainScreen(
      MediaQueryData mQuery, int _index, Orientation orientation) {
    return Container(
      color: Color.fromRGBO(70, 70, 70, 1),
      padding: const EdgeInsets.all(5),
      height: orientation == Orientation.portrait
          ? mQuery.size.height * 0.35
          : mQuery.size.height * 0.7,
      width: mQuery.size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _genre[_index],
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
              child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: json[_index] == null
                      ? 10
                      : json[_index]['data']['movies'].length,
                  itemBuilder: (_, index) {
                    return json[_index] == null
                        ? Container(
                            color: Colors.white,
                            margin: const EdgeInsets.all(5),
                            width: orientation == Orientation.portrait
                                ? mQuery.size.width * 0.4
                                : mQuery.size.width * 0.2,
                            child: CupertinoActivityIndicator(),
                          )
                        : GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (_) => MovieDetail(
                                      json[_index]['data']['movies'][index])));
                            },
                            child: Tooltip(
                              message: json[_index]['data']['movies'][index]
                                  ['title_long'],
                              child: Container(
                                margin: const EdgeInsets.all(5),
                                width: orientation == Orientation.portrait
                                    ? mQuery.size.width * 0.4
                                    : mQuery.size.width * 0.2,
                                child: CachedNetworkImage(
                                  imageUrl: json[_index]['data']['movies']
                                      [index]['medium_cover_image'],
                                  fit: BoxFit.fill,
                                  placeholder: (c, s) {
                                    return Container(
                                      padding: const EdgeInsets.all(55),
                                      color: Color.fromRGBO(90, 90, 90, 1),
                                      child:
                                          Image.asset('assets/images/logo.png'),
                                    );
                                  },
                                  errorWidget: (c, s, _) {
                                    return Container(
                                      padding: const EdgeInsets.all(55),
                                      color: Color.fromRGBO(90, 90, 90, 1),
                                      child:
                                          Image.asset('assets/images/logo.png'),
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                  }))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var mQuery = MediaQuery.of(context);
    return Scaffold(
      backgroundColor: Color.fromRGBO(80, 80, 80, 1),
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: Image.asset(
            'assets/images/logo.png',
          ),
        ),
        title: Text('Home'),
        actions: _networkConnection
            ? <Widget>[
                IconButton(
                    icon: Icon(LineAwesomeIcons.search),
                    onPressed: () {
                      Navigator.of(context).pushNamed(SearchScreen.route);
                    }),
                IconButton(
                    icon: Icon(LineAwesomeIcons.heart_o), onPressed: () {}),
                IconButton(
                    icon: Icon(LineAwesomeIcons.download), onPressed: () {}),
              ]
            : <Widget>[],
      ),
      body: _networkConnection
          ? OrientationBuilder(
              builder: (ctx, orientation) => ListView.builder(
                  itemCount: _genre.length,
                  itemBuilder: (_, index) {
                    return Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: _mainScreen(mQuery, index, orientation));
                  }),
            )
          : _noConnectionScreen(mQuery),
    );
  }
}
