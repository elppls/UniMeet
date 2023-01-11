import 'package:easy_dialog/easy_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:unimeet_test/Screens/FeedScreen.dart';
import 'package:unimeet_test/Services/FirebaseServices.dart';
import 'package:unimeet_test/Services/auth_service.dart';
import 'package:unimeet_test/UniMeetColors/UniMeetConstants.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  String _email = '';
  String _password = '';
  int counter = 0;
  String _forgetPasswordEmail = '';
  String _token = '';
  bool _isForgetPasswordVisible = false;
  void showToast() {
    if (mounted) {
      setState(() {
        _isForgetPasswordVisible = true;
      });
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        try {
          await FirebaseMessaging.instance.getToken().then((value) => {
                setState(() {
                  _token = value as String;
                })
              });
        } catch (e) {}

        setState(() {});
      });
    });
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.grey[350],
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 80),
          child: Container(
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Image.asset('Images/UniMeet-1.png'),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text(
                    'Log in',
                    style: TextStyle(
                        fontSize: 25,
                        fontFamily: 'Bebas Neue',
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 15),
                  Center(
                    child: Container(
                      width: 300,
                      alignment: Alignment.center,
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              height: 20,
                            ),
                            Container(
                              height: 50,
                              decoration: BoxDecoration(
                                  borderRadius: (BorderRadius.circular(10)),
                                  color: Colors.white,
                                  border: Border.all(color: Colors.white)),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 15),
                                child: TextField(
                                  textInputAction: TextInputAction.next,
                                  style: const TextStyle(
                                    color: Colors.black,
                                  ),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Enter Email',
                                    hintStyle: TextStyle(
                                      color: lolaColor,
                                    ),
                                  ),
                                  onChanged: (value) {
                                    _email = value.trim();
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Container(
                              height: 50,
                              decoration: BoxDecoration(
                                  borderRadius: (BorderRadius.circular(10)),
                                  color: Colors.white,
                                  border: Border.all(color: Colors.white)),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 15),
                                child: TextField(
                                  textInputAction: TextInputAction.next,
                                  obscureText: true,
                                  enableSuggestions: false,
                                  autocorrect: false,
                                  style: const TextStyle(
                                    color: lolaColor,
                                  ),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Enter Password',
                                    hintStyle: TextStyle(
                                      color: lolaColor,
                                    ),
                                  ),
                                  onChanged: (value) {
                                    _password = value;
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            ElevatedButton(
                              style: ButtonStyle(
                                shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        blueWhaleColor),
                                maximumSize: MaterialStateProperty.all<Size>(
                                    Size.infinite),
                                minimumSize: MaterialStateProperty.all<Size>(
                                    const Size.fromHeight(50)),
                              ),
                              onPressed: () async {
                                counter++;
                                if (counter >= 3) {
                                  showToast();
                                }

                                bool isValid =
                                    await AuthService.login(_email, _password);
                                if (isValid) {
                                  FirebaseServices.updateToken(_token,
                                      FirebaseAuth.instance.currentUser!.uid);

                                  Navigator.pop(context);
                                } else {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(const SnackBar(
                                    duration: Duration(milliseconds: 1250),
                                    content: Text("Wrong Email or Password"),
                                  ));
                                }
                              },
                              child: const Text('Log In',
                                  style: TextStyle(color: lolaColor)),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            Visibility(
                              visible: _isForgetPasswordVisible,
                              child: ElevatedButton(
                                style: ButtonStyle(
                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                  ),
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          blueWhaleColor),
                                  maximumSize: MaterialStateProperty.all<Size>(
                                      Size.infinite),
                                  minimumSize: MaterialStateProperty.all<Size>(
                                      const Size.fromHeight(50)),
                                ),
                                onPressed: () {
                                  EasyDialog(
                                    height: 250,
                                    contentList: [
                                      const Text(
                                        "Enter your Email",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                        textScaleFactor: 1.2,
                                      ),
                                      const SizedBox(height: 20),
                                      const SizedBox(height: 20),
                                      TextFormField(
                                        maxLines: 1,
                                        textInputAction: TextInputAction.next,
                                        style: const TextStyle(
                                          color: Colors.black,
                                        ),
                                        decoration: const InputDecoration(
                                          enabledBorder: UnderlineInputBorder(
                                            borderSide:
                                                BorderSide(color: Colors.cyan),
                                          ),
                                          focusedBorder: UnderlineInputBorder(
                                            borderSide:
                                                BorderSide(color: Colors.cyan),
                                          ),
                                          hintText: 'Email',
                                          hintStyle: TextStyle(
                                            color: blueWhaleColor,
                                          ),
                                        ),
                                        onChanged: (value) {
                                          _forgetPasswordEmail = value;
                                        },
                                      ),
                                      const SizedBox(height: 20),
                                      ElevatedButton(
                                        style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  blueWhaleColor),
                                          shape: MaterialStateProperty.all<
                                              RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            ),
                                          ),
                                          maximumSize:
                                              MaterialStateProperty.all<Size>(
                                                  Size.infinite),
                                          minimumSize:
                                              MaterialStateProperty.all<Size>(
                                                  const Size.fromHeight(40)),
                                        ),
                                        onPressed: () async {
                                          try {
                                            await FirebaseAuth.instance
                                                .sendPasswordResetEmail(
                                                    email: _forgetPasswordEmail
                                                        .trim());
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(const SnackBar(
                                              duration:
                                                  Duration(milliseconds: 1250),
                                              content: Text(
                                                  "Email has been sent, Please check spam if you are unable to find it"),
                                            ));

                                            Navigator.pop(context);
                                          } catch (e) {
                                            print(e);
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(const SnackBar(
                                              duration:
                                                  Duration(milliseconds: 1250),
                                              content: Text(
                                                  'Email does not exist or is badly formatted'),
                                            ));

                                            Navigator.pop(context);
                                          }
                                        },
                                        child: const Text(
                                            'Request new password',
                                            style: TextStyle(color: lolaColor)),
                                      ),
                                    ],
                                  ).show(context);
                                },
                                child: const Text('Forget Password',
                                    style: TextStyle(color: lolaColor)),
                              ),
                            ),
                          ]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
