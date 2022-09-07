//core packages
import 'package:firebase_auth/firebase_auth.dart';
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

//change this to true to enable splash
bool splashEnabled = true;

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'MARSHMALLOW',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        backgroundColor: backgroundBlue,
      ),
      home: splashEnabled ? SplashPage() : PageInitializer(),
    );
  }
}

class SplashPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      backgroundColor: blue,
      splash: Image.asset(
        'assets/splash.png',
      ),
      nextScreen: PageInitializer(),
      splashTransition: SplashTransition.fadeTransition,
      splashIconSize: 175,
    );
  }
}

class PageInitializer extends StatefulWidget {
  const PageInitializer({Key? key}) : super(key: key);

  @override
  _PageInitializerState createState() => _PageInitializerState();
}

class _PageInitializerState extends State<PageInitializer> {
  @override
  Widget build(BuildContext context) {
    FirebaseAuth _auth = FirebaseAuth.instance;
    final user = _auth.currentUser;
    if (user != null) {
      User loggedInUser = user;
      print('AUTO LOG IN SUCCESS(main.dart): Signed in As:${loggedInUser.uid}');
      return HomePage();
    } else {
      return WelcomePage();
    }
  }
}
