import 'dart:async';

import 'package:email_auth/email_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:unimeet_test/Services/FirebaseServices.dart';
import 'package:unimeet_test/Services/otpServer.dart';

import '../UniMeetColors/UniMeetConstants.dart';
import 'LoginSignupScreen.dart';

class DeleteProfileScreen extends StatefulWidget {
  final String Email;
  final String CurrentUUID;

  const DeleteProfileScreen(
      {super.key, required this.Email, required this.CurrentUUID});

  @override
  State<DeleteProfileScreen> createState() => _DeleteProfileScreenState();
}

class _DeleteProfileScreenState extends State<DeleteProfileScreen> {
  late EmailAuth emailAuth;
  int _timerSeconds = 30;
  Timer? timer;

  String _otp = '';
  bool _isVisible = true;
  String _email = '';
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

  Future<void> deleteProfile() async {
    await FirebaseServices.deleteProfile(widget.CurrentUUID);
    await FirebaseAuth.instance.currentUser?.delete();

    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => LoginSignupScreen()));
  }

  deleteAlert(BuildContext context) {
    Widget noBtn = TextButton(
      child: const Text("No"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget yesBtn = TextButton(
      child: const Text("Yes"),
      onPressed: () async {
        deleteProfile();
      },
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete?"),
          content: const Text("Do you really want to delete your profile?"),
          actions: [
            noBtn,
            yesBtn,
          ],
        );
      },
    );
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
                          deleteAlert(context);
                        },
                        child: const Text('Delete Profile?',
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
