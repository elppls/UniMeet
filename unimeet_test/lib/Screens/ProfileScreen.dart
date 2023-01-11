import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:unimeet_test/Models/PostModel.dart';
import 'package:unimeet_test/Models/UserModel.dart';
import 'package:unimeet_test/Screens/EditScreen.dart';
import 'package:unimeet_test/Screens/LoginSignupScreen.dart';
import 'package:unimeet_test/Screens/MessageScreen.dart';
import 'package:unimeet_test/Services/FirebaseServices.dart';
import 'package:unimeet_test/Shared_Widgets/PostWidget.dart';
import 'package:unimeet_test/UniMeetColors/UniMeetConstants.dart';

import 'package:http/http.dart' as http;

class ProfileScreen extends StatefulWidget {
  final String CurrentUUID;
  final String VisitedUId;
  const ProfileScreen(
      {Key? key, required this.CurrentUUID, required this.VisitedUId})
      : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? current;
  UserModel? visited;
  getUsers() async {
    current = await FirebaseServices.getUser(widget.CurrentUUID);
    visited = await FirebaseServices.getUser(widget.VisitedUId);
  }

  int _followers = 0;
  int _following = 0;
  bool _isOwnProfile = false;
  bool _isfollow = false;
  bool _isBothfollow = false;
  List _allPosts = [];

  follow() {
    FirebaseServices.follow(widget.CurrentUUID, widget.VisitedUId);
    if (mounted) {
      setState(() {
        _isfollow = true;
        _followers++;
      });
    }

    FirebaseServices.sendNotification('You have a new follower!',
        '${current?.firstname} has added you', visited?.token as String);
  }

  unfollow() {
    FirebaseServices.unfollow(widget.CurrentUUID, widget.VisitedUId);
    if (mounted) {
      setState(() {
        _isfollow = false;
        _followers--;
      });
    }
  }

  getNumberOfFollowers() async {
    int followers = await FirebaseServices.followersCount(widget.VisitedUId);
    if (mounted) {
      setState(() {
        _followers = followers;
      });
    }
  }

  getNumberOfFollowing() async {
    int following = await FirebaseServices.followingCount(widget.VisitedUId);
    if (mounted) {
      setState(() {
        _following = following;
      });
    }
  }

  following() async {
    bool isFollowing =
        await FirebaseServices.following(widget.CurrentUUID, widget.VisitedUId);
    if (mounted) {
      setState(() {
        _isfollow = isFollowing;
      });
    }
  }

  bothfollowing() async {
    bool isFollowing = await FirebaseServices.bothFollowing(
        widget.CurrentUUID, widget.VisitedUId);
    if (mounted) {
      setState(() {
        _isBothfollow = isFollowing;
      });
    }
  }

  followAction() {
    if (_isfollow)
      unfollow();
    else
      follow();
  }

  Future<void> getAllPosts() async {
    List posts = await FirebaseServices.getAllPosts(widget.VisitedUId);
    if (mounted) {
      setState(() {
        _allPosts = posts;
      });
    }
  }

  logoutAlert(BuildContext context) {
    Widget noBtn = TextButton(
      child: const Text("No"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget yesBtn = TextButton(
      child: const Text("Yes"),
      onPressed: () {
        _signOut();

        Navigator.pop(context);
      },
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Logout?"),
          content: const Text("Do you really want to logout?"),
          actions: [
            noBtn,
            yesBtn,
          ],
        );
      },
    );
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  void initState() {
    getUsers();
    getNumberOfFollowers();
    getNumberOfFollowing();
    following();
    bothfollowing();
    getAllPosts();
    if (widget.CurrentUUID == widget.VisitedUId) {
      _isOwnProfile = true;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
            child: RefreshIndicator(
              onRefresh: getAllPosts,
              child: ListView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                children: [
                  Container(
                    height: 125,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: userModel.coverImage == ''
                            ? AssetImage('Images/Image_not_available.png')
                                as ImageProvider
                            : CachedNetworkImageProvider(
                                userModel.coverImage as String),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      child: Visibility(
                        visible: _isOwnProfile,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            PopupMenuButton(
                              onSelected: (result) {
                                if (result == "edit" &&
                                    widget.CurrentUUID == widget.VisitedUId) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditScreen(
                                        user: userModel,
                                      ),
                                    ),
                                  );
                                }

                                if (result == "logout") {
                                  logoutAlert(context);
                                }
                              },
                              icon: Container(
                                color: Colors.white,
                                child: const Icon(
                                  Icons.settings,
                                  color: Colors.black,
                                  size: 20,
                                ),
                              ),
                              itemBuilder: (context) {
                                return <PopupMenuItem<String>>[
                                  // ignore: prefer_const_constructors
                                  PopupMenuItem(
                                    child: const Text('Logout'),
                                    value: 'logout',
                                  ),
                                  PopupMenuItem(
                                    child: Text('Edit'),
                                    value: "edit",
                                  ),
                                ];
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    transform: Matrix4.translationValues(0, -30, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          transform: Matrix4.translationValues(30, 0, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(55.0),
                                child: Container(
                                  height: 130.0,
                                  width: 130.0,
                                  child: userModel.profilePicture == ''
                                      ? Image.asset(
                                          'Images/No_Image_Available.jpg')
                                      : CachedNetworkImage(
                                          imageUrl: userModel.profilePicture
                                              as String,
                                          fit: BoxFit.cover,
                                        ),
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Container(
                                  transform:
                                      Matrix4.translationValues(0, 15, 0),
                                  child: Padding(
                                    padding: EdgeInsets.fromLTRB(0, 20, 30, 0),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          fullname,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            overflow: TextOverflow.visible,
                                            fontSize: 26,
                                            fontWeight: FontWeight.bold,
                                            shadows: <Shadow>[
                                              Shadow(
                                                offset: Offset(0.2, 0.2),
                                                blurRadius: 3.0,
                                                color: Color.fromARGB(
                                                    255, 0, 0, 0),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          transform: Matrix4.translationValues(
                                              0, 0, 0),
                                          child: Text(
                                            userModel.bio as String,
                                            textAlign: TextAlign.start,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              overflow: TextOverflow.visible,
                                              shadows: <Shadow>[
                                                Shadow(
                                                  offset: Offset(0.2, 0.2),
                                                  blurRadius: 1.0,
                                                  color: Color.fromARGB(
                                                      255, 0, 0, 0),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Table(
                          border: TableBorder.all(color: Colors.transparent),
                          columnWidths: const {
                            0: FlexColumnWidth(9),
                            1: FlexColumnWidth(4),
                            2: FlexColumnWidth(4),
                            3: FlexColumnWidth(2),
                          },
                          children: [
                            TableRow(children: [
                              Container(),
                              Text(
                                textAlign: TextAlign.center,
                                '${_followers}',
                                style: const TextStyle(fontSize: 20),
                              ),
                              Text(
                                textAlign: TextAlign.center,
                                '${_following}',
                                style: const TextStyle(fontSize: 20),
                              ),
                              Container(),
                            ]),
                            TableRow(children: [
                              Container(),
                              const Text(
                                textAlign: TextAlign.center,
                                'Followers',
                                style:
                                    TextStyle(fontSize: 10, color: Colors.grey),
                              ),
                              const Text(
                                textAlign: TextAlign.center,
                                'Following',
                                style:
                                    TextStyle(fontSize: 10, color: Colors.grey),
                              ),
                              Container(),
                            ]),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        !_isOwnProfile
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor: _isfollow
                                          ? MaterialStateProperty.all<Color>(
                                              lightRoyalBlueColor)
                                          : MaterialStateProperty.all<Color>(
                                              const Color.fromARGB(
                                                  255, 250, 91, 144)),
                                      shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(15.0),
                                            side: const BorderSide(
                                                color: Colors.black, width: 1)),
                                      ),
                                    ),
                                    onPressed: () {
                                      bothfollowing();
                                      followAction();
                                    },
                                    child: _isfollow
                                        ? const Text('Followed')
                                        : const Text('Follow'),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  IconButton(
                                    icon: FaIcon(
                                      FontAwesomeIcons.solidComments,
                                      color: _isBothfollow
                                          ? Colors.red
                                          : Colors.grey,
                                    ),
                                    iconSize: 30,
                                    onPressed: () {
                                      _isBothfollow
                                          ? Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    MessageScreen(
                                                  CurrentUUID:
                                                      widget.CurrentUUID,
                                                  VisitedUId: widget.VisitedUId,
                                                ),
                                              ),
                                            )
                                          : ScaffoldMessenger.of(context)
                                              .showSnackBar(const SnackBar(
                                              duration:
                                                  Duration(milliseconds: 1250),
                                              content: Text(
                                                  "You both need to Follow each other in order to get in touch"),
                                            ));
                                    },
                                  ),
                                ],
                              )
                            : const SizedBox.shrink(),
                        Container(
                          child: StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection('posts')
                                .doc(widget.VisitedUId)
                                .collection('userPosts')
                                .orderBy('datePosted', descending: true)
                                .snapshots(),
                            builder: (context, AsyncSnapshot snapshot) {
                              if (snapshot.hasData) {
                                if (snapshot.data!.docs.length < 1) {
                                  return SizedBox.shrink();
                                }
                                return ListView.builder(
                                  shrinkWrap: true,
                                  primary: false,
                                  itemCount: _allPosts.length,
                                  itemBuilder: (context, index) {
                                    return PostWidget(
                                      post: _allPosts[index],
                                      user: userModel,
                                      CurrentUUID: widget.CurrentUUID,
                                      VisitedUUID: widget.VisitedUId,
                                    );
                                  },
                                );
                              }
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
