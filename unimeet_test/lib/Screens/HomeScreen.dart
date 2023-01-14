import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:unimeet_test/Models/UserModel.dart';
import 'package:unimeet_test/Screens/MessagesScreen.dart';
import 'package:unimeet_test/Screens/SearchScreen.dart';
import 'package:unimeet_test/Services/FirebaseServices.dart';
import 'package:unimeet_test/Shared_Widgets/PostWidget.dart';
import 'package:unimeet_test/UniMeetColors/UniMeetConstants.dart';
import 'package:async/async.dart' show StreamGroup;
import 'package:http/http.dart' as http;

import '../Models/PostModel.dart';
import '../Shared_Widgets/ClubPostWidget.dart';

class HomeScreen extends StatefulWidget {
  final String CurrentUUID;
  const HomeScreen({Key? key, required this.CurrentUUID}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List _allPostsClub = [];
  List _allPostsFollowing = [];
  List _allJoinedClubs = [];
  List _allPosts = [];
  List _allFollowing = [];
  bool hasPosts = false;
  var channel;
  var flutterLocalNotificationsPlugin;

  void requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings permission = await messaging.requestPermission(
      alert: true,
      badge: true,
    );
  }

  void firebaseMessagingLOAD() async {
    if (!kIsWeb) {
      channel = const AndroidNotificationChannel(
        'high_importance_channel',
        'High Importance Notifications',
        importance: Importance.high,
        enableVibration: true,
      );

      flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  void firebaseMessagingListen() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null && !kIsWeb) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              icon: 'launch_background',
            ),
          ),
        );
      }
    });
  }

  Future<void> getAllFollowing() async {
    List following = await FirebaseServices.getAllFollowing(widget.CurrentUUID);
    if (mounted) {
      _allFollowing = following;
    }
  }

  Future<void> getAllPostsClub() async {
    for (String club in _allJoinedClubs) {
      List posts = await FirebaseServices.getAllPostsClub(club);
      if (mounted) {
        _allPostsClub = _allPostsClub + posts;
      }
    }
  }

  Future<void> getAllUserPosts() async {
    for (String following in _allFollowing) {
      List posts = await FirebaseServices.getAllPosts(following);
      if (mounted) {
        _allPostsFollowing = _allPostsFollowing + posts;
      }
    }
  }

  Future<void> getAllClubs() async {
    List allClubs =
        await FirebaseServices.getAllJoinedClubs(widget.CurrentUUID);
    if (mounted) _allJoinedClubs = allClubs;
  }

  combinePostsToOneList() {
    List Posts = [];
    for (PostModel post in _allPostsFollowing) {
      Posts.add(StreamBuilder(
          stream: usersRef.doc(post.creatorId).snapshots(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              UserModel user = UserModel.fromDoc(snapshot.data);
              return PostWidget(
                post: post,
                CurrentUUID: widget.CurrentUUID,
                VisitedUUID: post.creatorId as String,
                user: user,
              );
            } else {
              return SizedBox.shrink();
            }
          }));
    }

    for (PostModel post in _allPostsClub) {
      Posts.add(StreamBuilder(
          stream: usersRef.doc(post.creatorId).snapshots(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              UserModel user = UserModel.fromDoc(snapshot.data);
              return ClubPostWidget(
                  post: post,
                  CurrentUUID: user.id as String,
                  VisitedUUID: widget.CurrentUUID,
                  clubID: post.clubId as String);
            } else {
              return SizedBox.shrink();
            }
          }));
    }
    if (!Posts.isEmpty) {
      hasPosts = true;
    }
    _allPosts = Posts;
    return Posts;
  }

  showPosts() {
    print(_allPosts[1]);
  }

  Future<void> getAll() async {
    await getAllClubs();
    await getAllPostsClub();
    await getAllFollowing();
    await getAllUserPosts();
    await combinePostsToOneList();
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await this.getAll();

        requestPermission();
        firebaseMessagingLOAD();
        firebaseMessagingListen();
        if (mounted) {
          setState(() {});
        }
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          toolbarHeight: 60,
          backgroundColor: lightRoyalBlueColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(10),
            ),
          ),
          title: Row(
            children: [
              Image.asset(
                'Images/UniMeet-2.png',
                scale: 5,
              ),
              Spacer(),
              Text(
                'Home',
                textAlign: TextAlign.end,
                style: TextStyle(fontSize: 15),
              ),
            ],
          ),
          actions: []),
      body: NestedScrollView(
        body: hasPosts
            ? SingleChildScrollView(
                child: ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: _allPostsClub.length + _allPostsFollowing.length,
                  itemBuilder: (context, index) {
                    if (index >= _allPostsClub.length != true) {
                      final PostModel post = _allPostsClub[index];

                      return StreamBuilder(
                        stream: usersRef.doc(post.creatorId).snapshots(),
                        builder:
                            (BuildContext context, AsyncSnapshot snapshot) {
                          final PostModel post = _allPostsClub[index];
                          if (snapshot.hasData) {
                            UserModel user = UserModel.fromDoc(snapshot.data);
                            return ClubPostWidget(
                                post: post,
                                CurrentUUID: widget.CurrentUUID,
                                VisitedUUID: user.id as String,
                                clubID: post.clubId as String);
                          } else {
                            return SizedBox.shrink();
                          }
                        },
                      );
                    }

                    final PostModel post =
                        _allPostsFollowing[index - _allPostsClub.length];
                    return StreamBuilder(
                      stream: usersRef.doc(post.creatorId).snapshots(),
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        final PostModel post =
                            _allPostsFollowing[index - _allPostsClub.length];
                        if (snapshot.hasData) {
                          UserModel user = UserModel.fromDoc(snapshot.data);
                          return PostWidget(
                              post: post,
                              CurrentUUID: widget.CurrentUUID,
                              VisitedUUID: user.id as String,
                              user: user);
                        } else {
                          return SizedBox.shrink();
                        }
                      },
                    );
                  },
                ),
              )
            : Center(
                child: CircularProgressIndicator(
                color: lightRoyalBlueColor,
              )),
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              backgroundColor: Colors.white,
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    IconButton(
                      iconSize: 25,
                      splashColor: Colors.transparent,
                      onPressed: () async {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SearchScreen(
                              CurrentUUID: widget.CurrentUUID,
                            ),
                          ),
                        );
                      },
                      icon: Icon(
                        Icons.search,
                        color: Colors.black,
                      ),
                    ),
                    IconButton(
                      iconSize: 25,
                      splashColor: Colors.transparent,
                      onPressed: () async {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MessagesScreen(
                              CurrentUUID: widget.CurrentUUID,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.message,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ],
              toolbarHeight: 40,
              automaticallyImplyLeading: false,
              floating: true,
              snap: true,
            )
          ];
        },
      ),
    );
  }
}
