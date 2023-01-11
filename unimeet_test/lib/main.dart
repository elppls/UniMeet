import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:unimeet_test/Screens/LoginSignupScreen.dart';
import 'package:unimeet_test/Screens/FeedScreen.dart';

Future<void> main() async {
  //makes the status bar the same color as the app bar
  SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  //if the user is logged in, there will be data, automatically goes to the application, otherwise will go to the login signup screen
  Widget getFeedOrLoginScreen() {
    return StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, snapshot) {
          if (snapshot.hasData) {
            return FeedScreen(
                CurrentUUID: FirebaseAuth.instance.currentUser!.uid);
          } else {
            return const LoginSignupScreen();
          }
        });
  }

  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: getFeedOrLoginScreen(),
    );
  }
}
