import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:watchit/screens/favourites.dart';
import 'package:watchit/screens/home.dart';
import 'package:watchit/screens/search_screen.dart';
import 'package:watchit/screens/splash.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Watch It !',
      theme: ThemeData(
        primaryColor: Color.fromARGB(255,86,60,144),
        primaryColorDark: Color.fromARGB(255,36,2,112),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SplashScreen(),
      routes: {
        SplashScreen.route : (_) => SplashScreen(),
        HomeScreen.route: (_) => HomeScreen(),
        SearchScreen.route: (_) => SearchScreen(),
        FavouritesScreen.route: (_) => FavouritesScreen()
      },
    );
  }
}
