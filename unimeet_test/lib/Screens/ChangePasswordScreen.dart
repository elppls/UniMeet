import 'dart:async';

import 'package:email_auth/email_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:unimeet_test/Screens/LoginSignupScreen.dart';
import 'package:unimeet_test/Services/otpServer.dart';
import 'package:unimeet_test/UniMeetColors/UniMeetConstants.dart';

class ChangePasswordScreen extends StatefulWidget {
  final String Email;
  const ChangePasswordScreen({super.key, required this.Email});

  @override
  State<ChangePasswordScreen> createState() => ChangePasswordScreenState();
}

class ChangePasswordScreenState extends State<ChangePasswordScreen> {
  late EmailAuth emailAuth;
  int _timerSeconds = 30;
  Timer? timer;

  String _otp = '';
  bool _isVisible = true;
  String _email = '';
  String _password = '';
  String _passwordConfirm = '';
  bool _resendCode = false;

  void sendOtp() async {
    await emailAuth.sendOtp(recipientMail: _email, otpLength: 6);
  }

  void validateOTP() {
    bool x = emailAuth.validateOtp(recipientMail: _email, userOtp: _otp);
    if (x == true) {
      if (mounted) {
        setState(() {
          _isVisible = false;
        });
      }
    } else {}
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

  void changePassword(String password) async {
    await FirebaseAuth.instance.currentUser?.updatePassword(password);

    await FirebaseAuth.instance.signOut();
    Navigator.pop(context);
    Navigator.pop(context);
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        emailAuth = EmailAuth(
          sessionName: "UniMeet",
        );
        await emailAuth.config(otpServer);
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
        _email = widget.Email;
        sendOtp();
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.grey[350],
      body: SingleChildScrollView(
        child: SafeArea(
            child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 80),
          child: Container(
              child: Column(
            children: [
              Visibility(
                visible: _isVisible,
                child: Column(
                  children: [
                    Image.asset('Images/UniMeet-1.png'),
                    const SizedBox(
                      height: 20,
                    ),
                    Pinput(
                      length: 6,
                      hapticFeedbackType: HapticFeedbackType.lightImpact,
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
                    SizedBox(
                      height: 30,
                    ),
                    ElevatedButton(
                      style: ButtonStyle(
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        backgroundColor:
                            MaterialStateProperty.all<Color>(blueWhaleColor),
                        maximumSize:
                            MaterialStateProperty.all<Size>(Size.infinite),
                        minimumSize: MaterialStateProperty.all<Size>(
                            const Size.fromHeight(50)),
                      ),
                      onPressed: () async {
                        validateOTP();
                      },
                      child: const Text('validate otp',
                          style: TextStyle(color: lolaColor)),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    ElevatedButton(
                        style: ButtonStyle(
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          backgroundColor:
                              MaterialStateProperty.all<Color>(blueWhaleColor),
                          maximumSize:
                              MaterialStateProperty.all<Size>(Size.infinite),
                          minimumSize: MaterialStateProperty.all<Size>(
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
                  ],
                ),
              ),
              Visibility(
                  visible: !_isVisible,
                  child: Column(
                    children: [
                      Image.asset('Images/UniMeet-1.png'),
                      SizedBox(
                        height: 30,
                      ),
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: (BorderRadius.circular(10)),
                            color: Colors.white,
                            border: Border.all(color: Colors.white)),
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: TextField(
                          obscureText: true,
                          enableSuggestions: false,
                          autocorrect: false,
                          textInputAction: TextInputAction.next,
                          style: const TextStyle(
                            color: Colors.black,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Enter New Password',
                            hintStyle: TextStyle(
                              color: lolaColor,
                            ),
                          ),
                          onChanged: (value) {
                            _password = value.trim();
                          },
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: (BorderRadius.circular(10)),
                            color: Colors.white,
                            border: Border.all(color: Colors.white)),
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: TextField(
                          obscureText: true,
                          enableSuggestions: false,
                          autocorrect: false,
                          textInputAction: TextInputAction.next,
                          style: const TextStyle(
                            color: Colors.black,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Confirm Password',
                            hintStyle: TextStyle(
                              color: lolaColor,
                            ),
                          ),
                          onChanged: (value) {
                            _passwordConfirm = value.trim();
                          },
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      ElevatedButton(
                        style: ButtonStyle(
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          backgroundColor:
                              MaterialStateProperty.all<Color>(blueWhaleColor),
                          maximumSize:
                              MaterialStateProperty.all<Size>(Size.infinite),
                          minimumSize: MaterialStateProperty.all<Size>(
                              const Size.fromHeight(50)),
                        ),
                        onPressed: () async {
                          if (_password == _passwordConfirm) {
                            changePassword(_password);
                          } else {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              duration: Duration(milliseconds: 1250),
                              content: Text("Passwords do not match"),
                            ));
                          }
                        },
                        child: const Text('Change Password',
                            style: TextStyle(color: lolaColor)),
                      ),
                    ],
                  ))
            ],
          )),
        )),
      ),
    );
  }
}
