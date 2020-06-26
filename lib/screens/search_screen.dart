import 'dart:collection';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';
import 'package:watchit/screens/movie_detail.dart';

class SearchScreen extends StatefulWidget {
  static const route = 'search';

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController _controller;
  Response _response;
  LinkedHashMap<dynamic, dynamic> _data;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  void _getMovies() async {
    _response = null;
    _data = null;
    setState(() {});
    _response = await get('https://yts.mx/api/v2/list_movies.json?query_term=' +
        _controller.text.trim() +
        '&limit=50&sort_by=year&order_by=desc');
    _data = jsonDecode(_response.body);
    setState(() {});
  }

  Widget _searchedGrid(MediaQueryData mQuery) {
    return _data == null
        ? Center(
            child: Text(
              'Loading..........',
              style: TextStyle(color: Colors.white),
            ),
          )
        : _data['data']['movie_count'] == 0
            ? Center(
                child: Text('Not found'),
              )
            : GridView.builder(
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: mQuery.size.width * 0.3,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.5),
                itemCount: _data['data']['movies'].length,
                itemBuilder: (_, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) =>
                              MovieDetail(_data['data']['movies'][index])));
                    },
                    child: Tooltip(
                      message: _data['data']['movies'][index]['title_long'],
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            child: CachedNetworkImage(
                              fit: BoxFit.fill,
                              imageUrl: _data['data']['movies'][index]
                                  ['medium_cover_image'],
                              placeholder: (c, s) {
                                return Container(
                                  color: Colors.white,
                                );
                              },
                              errorWidget: (c, s, _) {
                                return Container(
                                  padding: const EdgeInsets.all(45),
                                  color: Color.fromRGBO(90, 90, 90, 1),
                                  child: Image.asset('assets/images/logo.png'),
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 8.0, bottom: 8.0),
                            child: Text(
                              _data['data']['movies'][index]['title'],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.white),
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                });
  }

  @override
  Widget build(BuildContext context) {
    var mQuery = MediaQuery.of(context);
    return Scaffold(
      backgroundColor: Color.fromRGBO(80, 80, 80, 1),
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
              icon: Icon(LineAwesomeIcons.search),
              onPressed: () {
                _getMovies();
                FocusScope.of(context).unfocus();
              })
        ],
        title: TextField(
          controller: _controller,
          cursorColor: Colors.white,
          style: TextStyle(color: Colors.white),
          keyboardType: TextInputType.text,
          onSubmitted: (_) {
            _getMovies();
            FocusScope.of(context).unfocus();
          },
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: 'Search',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
          ),
        ),
      ),
      body: Container(
          padding: const EdgeInsets.all(10),
          width: mQuery.size.width,
          height: mQuery.size.height,
          child: _controller.text.isEmpty
              ? Container(
                  width: mQuery.size.width,
                  height: mQuery.size.height,
                )
              : _searchedGrid(mQuery)),
    );
  }
}
