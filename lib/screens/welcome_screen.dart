// ignore_for_file: library_private_types_in_public_api, deprecated_member_use

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/screens/login_screen.dart';
import 'package:flutter_chat_app/screens/registration_screen.dart';

import 'componenets/rounded_button.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  static String id = "welcome_screen";

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  AnimationController? animationController;
  Animation? animation;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
      //  upperBound: 100.0,
    );

    // animation = CurvedAnimation(parent: animationController!, curve: Curves.easeIn);
    animation = ColorTween(begin: Colors.blueGrey, end: Colors.white)
        .animate(animationController!);
    animationController?.forward();

    // animation!.addStatusListener((status) {
    //   if(status == AnimationStatus.completed){
    //     animationController!.reverse(from: 1.0);
    //   }else if(status ==AnimationStatus.dismissed){
    //     animationController!.forward();
    //   }
    // });
    animationController?.addListener(() {
      setState(() {});
    //  print(animation?.value);
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    animationController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: animation!.value,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding:  EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.1),
              child: Row(
                children: <Widget>[
                  Flexible(
                    child: Hero(
                      tag: "logo",
                      child: SizedBox(
                        height: 60,
                        child: Image.asset('assets/images/logo.png'),
                      ),
                    ),
                  ),
                  TypewriterAnimatedTextKit(
                    speed: const Duration(milliseconds: 100),
                    text: const ['Mo Chat'],
                    textStyle: const TextStyle(
                      fontSize: 45.0,
                      color: Colors.black,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 48.0,
            ),
            RoundedButton(
              color: Colors.lightBlueAccent,
              title: 'Log In',
              onPressed: () {
                Navigator.pushNamed(context, LoginScreen.id);
              },
            ),
            RoundedButton(
              color: Colors.blueAccent,
              title:'Register',
              onPressed: () {
                Navigator.pushNamed(context, RegistrationScreen.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}

