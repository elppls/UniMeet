import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:unimeet_test/UniMeetColors/UniMeetConstants.dart';
import 'package:unimeet_test/Services/FirebaseServices.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import '../Models/UserModel.dart';

class MessageScreen extends StatefulWidget {
  final String CurrentUUID;
  final String VisitedUId;
  const MessageScreen(
      {Key? key, required this.CurrentUUID, required this.VisitedUId})
      : super(key: key);

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  UserModel? current;
  UserModel? visited;
  getUsers() async {
    current = await FirebaseServices.getUser(widget.CurrentUUID);
    visited = await FirebaseServices.getUser(widget.VisitedUId);
  }

  buildMessage(String message, bool isOwnProfile, Timestamp time) {
    var timeMillisec = time.millisecondsSinceEpoch;
    var toTime = DateTime.fromMillisecondsSinceEpoch(timeMillisec);
    var clockTime = DateFormat('hh:mm a').format(toTime);
    var clockToString = clockTime.toString();
    return Row(
      mainAxisAlignment:
          isOwnProfile ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(width: 10),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.5,
                    decoration: BoxDecoration(
                      color: isOwnProfile
                          ? Color.fromARGB(80, 37, 18, 144)
                          : Color.fromARGB(57, 51, 3, 113),
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                      border: Border.all(
                        width: 0.3,
                        color: Colors.green,
                        style: BorderStyle.solid,
                      ),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: Expanded(
                      child: Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              message as String,
                              style: const TextStyle(
                                overflow: TextOverflow.visible,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Text(
                                clockToString,
                                overflow: TextOverflow.visible,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await getUsers();
      });
    });
    super.initState();
  }

  TextEditingController _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: lightRoyalBlueColor,
        title: FutureBuilder(
            future: usersRef.doc(widget.VisitedUId).get(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return SizedBox.shrink();
              } else {
                UserModel targetedUser =
                    UserModel.fromDoc(snapshot.data as DocumentSnapshot);

                return Row(
                  children: [
                    targetedUser.profilePicture == ''
                        ? const CircleAvatar(
                            radius: 25,
                            backgroundImage:
                                AssetImage('Images/No_Image_Available.jpg'))
                        : CircleAvatar(
                            radius: 25,
                            backgroundImage: CachedNetworkImageProvider(
                                targetedUser.profilePicture as String),
                          ),
                    SizedBox(
                      width: 30,
                    ),
                    Text('${targetedUser.firstname} ${targetedUser.lastname!}')
                  ],
                );
              }
            }),
      ),
      body: FutureBuilder(
          future: usersRef.doc(widget.VisitedUId).get(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator.adaptive(
                  valueColor: AlwaysStoppedAnimation(Colors.black),
                ),
              );
            }
            UserModel userModel =
                UserModel.fromDoc(snapshot.data as DocumentSnapshot);

            String fullname = '${userModel.firstname} ${userModel.lastname}';
            return SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      child: StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('messages')
                            .doc(widget.CurrentUUID)
                            .collection('chats')
                            .doc(widget.VisitedUId)
                            .collection('messages')
                            .orderBy('time', descending: true)
                            .snapshots(),
                        builder: (context, AsyncSnapshot snapshot) {
                          if (snapshot.hasData) {
                            if (snapshot.data!.docs.length < 1) {
                              return Center(
                                child: Container(),
                              );
                            }
                            return ListView.builder(
                              reverse: true,
                              itemCount: snapshot.data.docs.length,
                              itemBuilder: (context, index) {
                                return buildMessage(
                                    snapshot.data.docs[index]["message"],
                                    snapshot.data.docs[index]["sender"] ==
                                        widget.CurrentUUID,
                                    snapshot.data.docs[index]["time"]);
                              },
                            );
                          }
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        child: SizedBox(
                          width: 290,
                          child: TextField(
                              controller: _controller,
                              decoration: const InputDecoration(
                                hintText: 'Send Message',
                                fillColor: lightRoyalBlueColor,
                                filled: true,
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10),
                                  ),
                                ),
                              )),
                        ),
                      ),

                      // ignore: prefer_const_constructors
                      IconButton(
                        icon: const Icon(Icons.send),
                        iconSize: 20,
                        onPressed: () {
                          if (_controller.text == "") {
                          } else {
                            String message = _controller.text;
                            _controller.clear();
                            FirebaseServices.messageSend(
                                widget.CurrentUUID, widget.VisitedUId, message);

                            FirebaseServices.sendNotification(
                                'New message',
                                '${current?.firstname} Has sent you a message',
                                visited?.token as String);
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
    );
  }
}
