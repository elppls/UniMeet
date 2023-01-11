import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_auth/email_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:pinput/pinput.dart';
import 'package:unimeet_test/Screens/LoginScreen.dart';
import 'package:unimeet_test/Services/auth_service.dart';
import 'package:unimeet_test/Services/otpServer.dart';
import 'package:unimeet_test/UniMeetColors/UniMeetConstants.dart';
import 'package:unimeet_test/auth.config.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  String _firstName = '';
  String _lastName = '';
  String _type = '';
  String _email = '';
  String _otp = '';
  String _password = '';
  bool _isVisible = true;
  bool _isVisible2 = false;
  bool _newOtpVisible = false;
  int x = 1;
  int _timerSeconds = 30;
  bool _resendCode = false;
  Timer? timer;
  String? _token;
  bool emailAlreadyExists = true;

  late EmailAuth emailAuth;

  final facultyEmailValidation = RegExp(r'[A-Za-z0-9.]+@[a-zA-Z]+\.edu\.jo');
  final studentEmailValidation =
      RegExp(r'^[A-Za-z0-9]+@std\.[a-zA-Z]+\.edu\.jo$');

  final lengthExp = RegExp(r'^.{8,}$$');
  final hasOneNumberExp = RegExp(r'.*[0-9].*$');
  final hasSpecialChar = RegExp(r'.*[@!#%&()^~{}].*$');

  void sendOtp() async {
    await emailAuth.sendOtp(recipientMail: _email, otpLength: 6);
  }

  void resendOTP() async {
    await emailAuth.sendOtp(recipientMail: _email, otpLength: 6);
    if (mounted) {
      setState(() {
        _timerSeconds = 30;
        _resendCode = false;
      });
    }
  }

  void showAndHide() {
    if (mounted) {
      setState(() {
        _isVisible = false;
        _isVisible2 = true;
      });
    }
  }

  Future<bool> checkEmailAlreadyExists() async {
    try {
      final emailList =
          await FirebaseAuth.instance.fetchSignInMethodsForEmail(_email);
      if (emailList.isEmpty) {
        if (mounted) {
          setState(() {
            emailAlreadyExists = false;
          });
        }
        return Future.value(false);
      } else {
        if (mounted) {
          setState(() {
            emailAlreadyExists = true;
          });
        }
        return Future.value(true);
      }
    } catch (e) {}

    return Future.value(true);
  }

  void showNewOTP() {
    if (mounted) {
      setState(() {
        _newOtpVisible = true;
      });
    }
  }

  void validateOTP() {
    bool validated =
        emailAuth.validateOtp(recipientMail: _email, userOtp: _otp);
    if (validated == true) {
      AuthService.signup(
          _firstName, _lastName, _email, _password, _type, _token!);
      Navigator.pop(context);
    } else {
      showNewOTP();
    }
  }

  @override
  void initState() {
    emailAuth = EmailAuth(
      sessionName: "UniMeet",
    );
    emailAuth.config(otpServer);
    timer = Timer.periodic(Duration(seconds: 1), (_) {
      if (mounted) {
        if (_timerSeconds != 0) {
          if (mounted) {
            setState(() {
              _timerSeconds--;
            });
          }
        } else {
          _resendCode = true;
        }
      }
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[350],
      body: ListView(
        children: [
          Container(
            child: SingleChildScrollView(
              child: SafeArea(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 25, vertical: 40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          Image.asset('Images/UniMeet-1.png'),
                          const SizedBox(height: 20),
                          Visibility(
                            visible: _isVisible,
                            child: const Text(
                              'Sign up',
                              style: TextStyle(
                                  fontSize: 25,
                                  fontFamily: 'Bebas Neue',
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Visibility(
                            visible: _isVisible,
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Container(
                                    height: 50,
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            (BorderRadius.circular(10)),
                                        color: Colors.white,
                                        border:
                                            Border.all(color: Colors.white)),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 15),
                                      child: TextField(
                                        textInputAction: TextInputAction.next,
                                        style: const TextStyle(
                                          color: lolaColor,
                                        ),
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          hintText: 'Enter First Name',
                                          hintStyle: TextStyle(
                                            color: lolaColor,
                                          ),
                                        ),
                                        onChanged: (value) {
                                          _firstName = value.trim();
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
                                        borderRadius:
                                            (BorderRadius.circular(10)),
                                        color: Colors.white,
                                        border:
                                            Border.all(color: Colors.white)),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 15),
                                      child: TextField(
                                        textInputAction: TextInputAction.next,
                                        style: const TextStyle(
                                          color: lolaColor,
                                        ),
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          hintText: 'Enter Last Name',
                                          hintStyle: TextStyle(
                                            color: lolaColor,
                                          ),
                                        ),
                                        onChanged: (value) {
                                          _lastName = value.trim();
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
                                        borderRadius:
                                            (BorderRadius.circular(10)),
                                        color: Colors.white,
                                        border:
                                            Border.all(color: Colors.white)),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 15),
                                      child: TextField(
                                        textInputAction: TextInputAction.next,
                                        style: const TextStyle(
                                          color: lolaColor,
                                        ),
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          hintText: 'Enter Email',
                                          hintStyle: TextStyle(
                                            color: lolaColor,
                                          ),
                                        ),
                                        onChanged: (value) {
                                          setState(() {
                                            if (facultyEmailValidation
                                                .hasMatch(value.trim())) {
                                              _email = value.trim();
                                              _type = 'Faculty';
                                            } else if (studentEmailValidation
                                                .hasMatch(value.trim())) {
                                              _email = value.trim();
                                              _type = 'Student';
                                            }
                                          });
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
                                        borderRadius:
                                            (BorderRadius.circular(10)),
                                        color: Colors.white,
                                        border:
                                            Border.all(color: Colors.white)),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 15),
                                      child: TextField(
                                        textInputAction: TextInputAction.done,
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
                                          _password = value.trim();
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
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                      ),
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              blueWhaleColor),
                                      maximumSize:
                                          MaterialStateProperty.all<Size>(
                                              Size.infinite),
                                      minimumSize:
                                          MaterialStateProperty.all<Size>(
                                              const Size.fromHeight(50)),
                                    ),
                                    onPressed: () async {
                                      if (lengthExp.hasMatch(_password) ==
                                          false) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                          duration:
                                              Duration(milliseconds: 1250),
                                          content: Text(
                                              "Password must have 8 charchters"),
                                        ));
                                      } else if (hasOneNumberExp
                                              .hasMatch(_password) ==
                                          false) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                          duration:
                                              Duration(milliseconds: 1250),
                                          content: Text(
                                              "Password must have atleast one number"),
                                        ));
                                      } else if (hasSpecialChar
                                              .hasMatch(_password) ==
                                          false) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                          duration:
                                              Duration(milliseconds: 1250),
                                          content: Text(
                                              "Password must have atleast one special character"),
                                        ));
                                      } else {
                                        if (_email != '' &&
                                            _firstName != '' &&
                                            _lastName != '' &&
                                            _password != '') {
                                          if (await checkEmailAlreadyExists() ==
                                                  false ||
                                              emailAlreadyExists == false) {
                                            sendOtp();
                                            showAndHide();
                                            if (mounted) {
                                              setState(() {
                                                _timerSeconds = 30;
                                              });
                                            }
                                          }
                                        } else if (_firstName == '') {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(const SnackBar(
                                            duration:
                                                Duration(milliseconds: 1250),
                                            content: Text(
                                                "Please enter Your First Name"),
                                          ));
                                        } else if (_lastName == '') {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(const SnackBar(
                                            duration:
                                                Duration(milliseconds: 1250),
                                            content: Text(
                                                "Please enter Your Last Name"),
                                          ));
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(const SnackBar(
                                            duration:
                                                Duration(milliseconds: 1250),
                                            content: Text(
                                                "Please enter a valid email"),
                                          ));
                                        }
                                      }
                                    },
                                    child: const Text('Sign up',
                                        style: TextStyle(color: lolaColor)),
                                  ),
                                ]),
                          ),
                        ],
                      ),
                      Visibility(
                        visible: _isVisible2,
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Validate OTP',
                                    style: TextStyle(
                                        fontSize: 25,
                                        fontFamily: 'Bebas Neue',
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Image.asset(
                                    'Images/doggo.gif',
                                    height: 100,
                                    width: 100,
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Pinput(
                                length: 6,
                                hapticFeedbackType:
                                    HapticFeedbackType.lightImpact,
                                pinAnimationType: PinAnimationType.scale,
                                mainAxisAlignment: MainAxisAlignment.center,
                                defaultPinTheme: PinTheme(
                                  width: MediaQuery.of(context).size.width * 1,
                                  height: 40,
                                  decoration: BoxDecoration(
                                      color: Color.fromARGB(255, 141, 141, 141),
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                                onChanged: (value) {
                                  _otp = value.trim();
                                },
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
                                  validateOTP();
                                },
                                child: const Text('validate otp',
                                    style: TextStyle(color: lolaColor)),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              ElevatedButton(
                                  style: ButtonStyle(
                                    shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                    ),
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            blueWhaleColor),
                                    maximumSize:
                                        MaterialStateProperty.all<Size>(
                                            Size.infinite),
                                    minimumSize:
                                        MaterialStateProperty.all<Size>(
                                            const Size.fromHeight(50)),
                                  ),
                                  onPressed: () {
                                    if (_resendCode) {
                                      resendOTP();
                                    } else {
                                      null;
                                    }
                                  },
                                  child: Text(
                                    'Resend OTP | $_timerSeconds',
                                    style: TextStyle(color: lolaColor),
                                  )),
                              const SizedBox(
                                height: 20,
                              ),
                              const Text(
                                'Please check your spam folder if you did not receive an OTP',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 10),
                              )
                            ]),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
