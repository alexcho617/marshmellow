//core packages
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart' as firebase_core;

//third party packages
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:bordered_text/bordered_text.dart';

//imports within project
import 'package:marshmallow/utils/text.dart';
import 'package:marshmallow/utils/colors.dart';
import 'package:marshmallow/screens/home/home.dart';
import 'package:marshmallow/screens/setting/setting.dart';

import 'package:marshmallow/screens/landing/landing.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await firebase_core.Firebase.initializeApp();

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
      
      backgroundColor: blue,
      splash: Image.asset('assets/splash.png',),
      nextScreen: WelcomePage(),
      splashTransition: SplashTransition.fadeTransition,
      splashIconSize: 175,
    );
  }
}
