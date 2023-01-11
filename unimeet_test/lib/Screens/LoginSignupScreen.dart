import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:unimeet_test/Screens/SignupScreen.dart';
import 'package:unimeet_test/Screens/LoginScreen.dart';
import 'package:unimeet_test/UniMeetColors/UniMeetConstants.dart';

class LoginSignupScreen extends StatefulWidget {
  const LoginSignupScreen({Key? key}) : super(key: key);

  @override
  State<LoginSignupScreen> createState() => _LoginSignupScreenState();
}

class _LoginSignupScreenState extends State<LoginSignupScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[350],
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 56,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Container(
                child: Column(
                  children: [
                    Image.asset('Images/UniMeet-1.png'),
                    SizedBox(height: 100),
                    const Text(
                      'UniMeet',
                      style: TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                        color: blueWhaleColor,
                      ),
                    ),
                    const Text(
                      'Educational Social Media Platform',
                      style: TextStyle(
                        fontFamily: 'Bebas Neue',
                        fontSize: 15,
                        fontWeight: FontWeight.normal,
                        color: blueWhaleColor,
                      ),
                    ),
                    const SizedBox(
                      height: 80,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                            width: 100,
                            height: 100,
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    PageTransition(
                                        type: PageTransitionType.bottomToTop,
                                        duration:
                                            const Duration(milliseconds: 500),
                                        child: LoginScreen()));
                              },
                              style: ButtonStyle(
                                overlayColor: MaterialStateProperty.all<Color>(
                                    Color.fromARGB(19, 0, 0, 0)),
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.transparent),
                                shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(30.0))),
                              ),
                              child: const Text(
                                "Log in",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: lolaColor,
                                  fontFamily: 'Bebas Neue',
                                ),
                              ),
                            )),
                        SizedBox(
                            width: 100,
                            height: 100,
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    PageTransition(
                                        type: PageTransitionType.topToBottom,
                                        duration:
                                            const Duration(milliseconds: 500),
                                        child: SignupScreen()));
                              },
                              style: ButtonStyle(
                                overlayColor: MaterialStateProperty.all<Color>(
                                    Color.fromARGB(19, 0, 0, 0)),
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.transparent),
                                shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(30.0))),
                              ),
                              child: const Text(
                                "Sign up",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: lolaColor,
                                  fontFamily: 'Bebas Neue',
                                ),
                              ),
                            )),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
