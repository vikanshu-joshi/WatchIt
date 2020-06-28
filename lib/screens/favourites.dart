import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:watchit/database.dart';
import 'package:watchit/screens/movie_detail.dart';

class FavouritesScreen extends StatefulWidget {
  static const route = 'favourites';

  @override
  _FavouritesScreenState createState() => _FavouritesScreenState();
}

class _FavouritesScreenState extends State<FavouritesScreen> {
  FavouritesProvider _favouritesDB;
  List<Favourites> _favouritesList;

  @override
  Widget build(BuildContext context) {
    var mQuery = MediaQuery.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Favourites'),
      ),
      body: _favouritesList == null || _favouritesList.isEmpty
          ? Container(
              color: Colors.white,
              width: mQuery.size.width,
              height: mQuery.size.height,
              child: Center(
                child: Text(
                  'No Favourites',
                  style: TextStyle(color: Colors.black, fontSize: 20),
                ),
              ),
            )
          : Container(
              color: Color.fromRGBO(70, 70, 70, 1),
              width: mQuery.size.width,
              height: mQuery.size.height,
              padding: const EdgeInsets.all(10),
              child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: mQuery.size.width * 0.5,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 0.5),
                  itemCount: _favouritesList.length,
                  itemBuilder: (_, index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_){
                          return MovieDetail(_favouritesList[index].toMap());
                        }));
                      },
                      child: Tooltip(
                        message: _favouritesList[index].titleLong,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              child: CachedNetworkImage(
                                fit: BoxFit.fill,
                                imageUrl: _favouritesList[index].image,
                                placeholder: (c, s) {
                                  return Container(
                                    color: Colors.white,
                                  );
                                },
                                errorWidget: (c, s, _) {
                                  return Container(
                                    padding: const EdgeInsets.all(45),
                                    color: Color.fromRGBO(90, 90, 90, 1),
                                    child:
                                        Image.asset('assets/images/logo.png'),
                                  );
                                },
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 8.0, bottom: 8.0),
                              child: Text(
                                _favouritesList[index].title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: Colors.white),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  }),
            ),
    );
  }

  @override
  void initState() {
    _favouritesList = List<Favourites>();
    _favouritesDB = FavouritesProvider();
    _favouritesDB
        .open('favourites.db')
        .then((value) => _favouritesDB.getFavouritesAll().then((value) {
              _favouritesList = value;
              if (mounted) setState(() {});
            }));
  }

  @override
  void dispose() {
    _favouritesDB.close();
    super.dispose();
  }
}
