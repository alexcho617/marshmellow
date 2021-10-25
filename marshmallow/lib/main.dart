import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:bordered_text/bordered_text.dart';
import 'package:marshmallow/screens/home/home.dart';
import 'package:marshmallow/utils/text.dart';
import 'package:marshmallow/utils/colors.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'MARSHMALLOW',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          backgroundColor: backgroundBlue,
        ),
      home: SplashPage(),
    );
  }
}

class SplashPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: Image.asset(
        'assets/splash.png',
        width: 250
      ),
      nextScreen: HomePage(),
      
      splashTransition: SplashTransition.fadeTransition,
     
    );
  }
}
