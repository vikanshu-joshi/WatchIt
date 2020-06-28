import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:watchit/screens/home.dart';

class SplashScreen extends StatefulWidget {
  static const route = 'splash';
  static var database;

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(
        vsync: this, duration: Duration(milliseconds: 2000));
    Future.delayed(Duration(seconds: 1), () => _controller.forward());
    super.initState();
  }



  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Align(
          child: ScaleTransition(
            scale: Tween(begin: 0.0, end: 0.4).animate(
                CurvedAnimation(parent: _controller, curve: Curves.bounceOut))
              ..addStatusListener((status) {
                if (status == AnimationStatus.completed) {
                  Navigator.of(context).pushReplacementNamed(HomeScreen.route);
                }
              }),
            child: Image.asset(
              'assets/images/logo.png',
            ),
          ),
        ),
      ),
    );
  }
}
