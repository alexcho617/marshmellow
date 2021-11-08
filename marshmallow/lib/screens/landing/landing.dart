
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marshmallow/screens/home/home.dart';
import 'package:marshmallow/utils/colors.dart';
import 'package:marshmallow/utils/text.dart';
import 'package:marshmallow/widgets/button.dart';

import 'package:introduction_screen/introduction_screen.dart';


class LandingPage extends StatelessWidget {
  final onboardingPagesList = [
    PageViewModel(
      titleWidget: SizedBox(height: 15), 
      bodyWidget: Image.asset(
        'assets/landing1.png',
        width: 288
      ),
    ), 
    PageViewModel(
      titleWidget: SizedBox(height: 15), 
      bodyWidget: Image.asset(
        'assets/landing2.png',
        width: 288
      ),
    ),
    PageViewModel(
      titleWidget: SizedBox(height: 15), 
      bodyWidget: Image.asset(
        'assets/landing3.png',
        width: 288
      ),
    ),
    PageViewModel(
      titleWidget: SizedBox(height: 30), 
      bodyWidget: Image.asset(
        'assets/landing4.png',
        width: 400
      ),
    ),
    PageViewModel(
      titleWidget: SizedBox(height: 250), 
      bodyWidget: Column(
        children: [
          Image.asset('assets/m.png', width: 100),
          point1style(data: 'Let’s Go!!'),
          SizedBox(height: 22),
          mediumButtonTheme('시작하기', (){Get.to(HomePage());})
        ]
      )
    )
  ];
  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      globalBackgroundColor: yellow,
      pages: onboardingPagesList,
      showDoneButton: false,
      showNextButton: false,
    );
  }
}
    



    