import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:path/path.dart';

final String tableFavourites = 'Favourites';
final String columnId = 'id';
final String columnTitle = 'title';
final String columnTitleLong = 'title_long';
final String columnYear = 'year';
final String columnRating = 'rating';
final String columnRuntime = 'runtime';
final String columnDesc = 'description_full';
final String columnImage = 'medium_cover_image';

class Favourites {
  String id;
  String title;
  String titleLong;
  String year;
  String rating;
  String runtime;
  String desc;
  String image;

  Favourites(this.id, this.title, this.titleLong, this.year, this.rating,
      this.runtime, this.desc, this.image);

  Map<String, dynamic> toMap() {
    var map = <String, String>{
      columnId: id,
      columnTitle: title,
      columnTitleLong: titleLong,
      columnYear: year,
      columnRating: rating,
      columnRuntime: runtime,
      columnDesc: desc,
      columnImage: image,
    };
    return map;
  }

  Favourites.fromMap(Map<String, dynamic> map) {
    id = map[columnId].toString();
    title = map[columnTitle].toString();
    titleLong = map[columnTitleLong].toString();
    year = map[columnYear].toString();
    rating = map[columnRating].toString();
    runtime = map[columnRuntime].toString();
    desc = map[columnDesc].toString();
    image = map[columnImage].toString();
  }
}

class FavouritesProvider {
  Database db;

  Future open(String _path) async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, _path);
    db = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute(
          'CREATE TABLE Favourites(id TEXT, title TEXT, title_long TEXT, year TEXT, '
          'rating TEXT, runtime TEXT, description_full TEXT,medium_cover_image TEXT)');
    });
  }

  Future<void> insert(Favourites favourites) async {
    await db.insert(tableFavourites, favourites.toMap());
//    await db.rawInsert('INSERT INTO Favourites(id, title, title_long, year, '
//        'rating, runtime, description_full,medium_cover_image) VALUES(${favourites._Id},${favourites._Title},${favourites._TitleLong},'
//        '${favourites._Year},${favourites._Rating},${favourites._Runtime},${favourites._Desc},${favourites._Image})');
    return;
  }

  Future<List<Favourites>> getFavouritesAll() async {
    List<Map> maps = await db.rawQuery('SELECT * FROM Favourites');
    List<Favourites> data = [];
    if (maps != null && maps.length > 0) {
      maps.forEach((element) {
        data.add(Favourites.fromMap(element));
      });
      return data;
    }
    return null;
  }

  Future<Favourites> getFavourites(String id) async {
    List<Map> maps = await db.query(tableFavourites,
        columns: [
          columnId,
          columnTitle,
          columnTitleLong,
          columnYear,
          columnRating,
          columnRuntime,
          columnDesc,
          columnImage
        ],
        where: '$columnId = ?',
        whereArgs: [id]);
    if (maps != null && maps.length > 0) {
      return Favourites.fromMap(maps.first);
    }
    return null;
  }

  Future<int> delete(String id) async {
    return await db
        .delete(tableFavourites, where: '$columnId = ?', whereArgs: [id]);
  }

  Future close() async => db.close();
}
