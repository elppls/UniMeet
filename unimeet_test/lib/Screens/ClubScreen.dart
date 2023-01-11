import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:unimeet_test/Models/ClubModel.dart';
import 'package:unimeet_test/Models/PostModel.dart';
import 'package:unimeet_test/Screens/AddAdminScreen.dart';
import 'package:unimeet_test/Screens/CreateClubPostScreen.dart';
import 'package:unimeet_test/Screens/EditClubScreen.dart';
import 'package:unimeet_test/Screens/JoinRequestScreen.dart';
import 'package:unimeet_test/Screens/RemoveMemberScreen.dart';
import 'package:unimeet_test/Screens/PostRequestsScreen.dart';
import 'package:unimeet_test/Shared_Widgets/ClubPostWidget.dart';
import 'package:unimeet_test/UniMeetColors/UniMeetConstants.dart';

import '../Models/UserModel.dart';
import '../Services/FirebaseServices.dart';

class ClubScreen extends StatefulWidget {
  final String CurrentUUID;
  final String ClubID;

  const ClubScreen(
      {super.key, required this.CurrentUUID, required this.ClubID});

  @override
  State<ClubScreen> createState() => _ClubScreenState();
}

class _ClubScreenState extends State<ClubScreen> {
  List _allPosts = [];
  List _allAdmins = [];
  bool wait = true;
  bool _isVerified = false;
  int _numOfPostRequests = 0;
  int _numOfJoinRequests = 0;
  bool _isJoined = false;
  bool _isRequestedToJoin = false;
  String _yearUser = '';
  String _type = '';
  var _user;

  Future<void> getAllAdmins() async {
    List admins = await FirebaseServices.getAllAdmins(widget.ClubID);
    if (mounted) {
      setState(() {
        _allAdmins = admins;
      });
    }
  }

  Future<void> getNumOfPostRequests() async {
    int requests = await FirebaseServices.getNumOfRequests(widget.ClubID);
    if (mounted) {
      setState(() {
        _numOfPostRequests = requests;
      });
    }
  }

  Future<void> getNumOfJoinRequests() async {
    int requests = await FirebaseServices.getNumOfJoinRequests(widget.ClubID);
    if (mounted) {
      setState(() {
        _numOfJoinRequests = requests;
      });
    }
  }

  bool adminOrMember() {
    for (int i = 0; i < _allAdmins.length; i++) {
      if (widget.CurrentUUID == _allAdmins[i]) return true;
    }
    return false;
  }

  Future<void> refreshPage() async {
    getAllAdmins();
    getAllPosts();
    getNumOfJoinRequests();
    getNumOfPostRequests();
  }

  verifyClub() {
    if (_isVerified == false) {
      _isVerified = true;
    } else {
      _isVerified = false;
    }

    ClubModel club = ClubModel(id: widget.ClubID, verfied: _isVerified);
    FirebaseServices.verifyClub(club);
    if (mounted) {
      setState(() {});
    }
  }

  showPosts() {
    List<Widget> Posts = [];
    for (PostModel post in _allPosts) {
      Posts.add(StreamBuilder(
          stream: usersRef.doc(post.creatorId).snapshots(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              UserModel user = UserModel.fromDoc(snapshot.data);
              return ClubPostWidget(
                  post: post,
                  CurrentUUID: user.id as String,
                  VisitedUUID: widget.CurrentUUID,
                  clubID: widget.ClubID);
            } else {
              return SizedBox.shrink();
            }
          }));
    }
    return Posts;
  }

  Future<void> getAllPosts() async {
    List posts = await FirebaseServices.getAllPostsClub(widget.ClubID);
    if (mounted) {
      setState(() {
        _allPosts = posts;
        wait = false;
      });
    }
  }

  checkJoined() async {
    bool isJoined =
        await FirebaseServices.joinedClub(widget.CurrentUUID, widget.ClubID);
    if (mounted) {
      setState(() {
        _isJoined = isJoined;
      });
    }
  }

  checkRequestedToJoin() async {
    bool isRequestedToJoin = await FirebaseServices.requestedToJoinClub(
        widget.CurrentUUID, widget.ClubID);
    if (mounted) {
      setState(() {
        _isRequestedToJoin = isRequestedToJoin;
      });
    }
  }

  checkVerfied() async {
    bool verfied = await FirebaseServices.verfiedClub(widget.ClubID);
    if (mounted) {
      setState(() {
        _isVerified = verfied;
      });
    }
  }

  joinAndLeaveClub() {
    if (_isJoined == false) {
      FirebaseServices.joinClub(widget.CurrentUUID, widget.ClubID);
      FirebaseServices.addClubTojoinedClubsList(
          widget.CurrentUUID, widget.ClubID);
      if (mounted) {
        setState(() {
          _isJoined = true;
        });
      }
    } else {
      FirebaseServices.leaveClub(widget.CurrentUUID, widget.ClubID);
      FirebaseServices.removeClubFromJoinedClubList(
          widget.CurrentUUID, widget.ClubID);
      if (mounted) {
        setState(() {
          _isJoined = false;
        });
      }
    }
  }

  requestToJoinClub() {
    if (_isRequestedToJoin == false) {
      FirebaseServices.requestToJoinClub(widget.CurrentUUID, widget.ClubID);

      if (mounted) {
        setState(() {
          _isRequestedToJoin = true;
        });
      }
    } else {
      FirebaseServices.leaveClub(widget.CurrentUUID, widget.ClubID);
      FirebaseServices.removeRequestToJoinClub(
          widget.CurrentUUID, widget.ClubID);
      if (mounted) {
        setState(() {
          _isRequestedToJoin = false;
        });
      }
    }
  }

  void getUser() async {
    final user = await FirebaseServices.getUser(widget.CurrentUUID);
    _user = user;
    _type = user.type as String;
    final yearUniUser = RegExp(r'[0-9].{0,3}');
    String userEmail = user.email as String;
    final match = yearUniUser.firstMatch(userEmail);
    _yearUser = match![0] as String;

    print(_yearUser);
  }

  getUniName() async {
    List matchesToList = [];
    var docSnapshot = await usersRef.doc(widget.CurrentUUID).get();
    if (docSnapshot.exists) {
      Map<String, dynamic>? data = docSnapshot.data();
      String value = data?['email'];
      final uniDomain = RegExp(r'(?<=)[^@.]+[a-zA-Z]');
      Iterable<Match> matches = uniDomain.allMatches(value);
      for (final Match in matches) {
        String match = Match[0]!;
        matchesToList.add(match);
      }
    }
    if (matchesToList[1] == 'std') {
      matchesToList[2];
    } else {
      matchesToList[1];
    }
  }

  void initState() {
    getAllPosts();
    getAllAdmins();
    getNumOfPostRequests();
    getNumOfJoinRequests();
    checkJoined();
    checkRequestedToJoin();
    checkVerfied();
    getUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: adminOrMember() == true || _isJoined
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateClubPostScreen(
                      CurrentUUID: widget.CurrentUUID,
                      ClubID: widget.ClubID,
                    ),
                  ),
                );
              },
              backgroundColor: lightRoyalBlueColor,
              child: const Icon(
                Icons.post_add_outlined,
                color: lolaColor,
              ),
            )
          : null,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FutureBuilder(
          future: ClubsRef.doc(widget.ClubID).get(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator.adaptive(
                  valueColor: AlwaysStoppedAnimation(Colors.black),
                ),
              );
            }
            ClubModel club =
                ClubModel.fromDoc(snapshot.data as DocumentSnapshot);
            return RefreshIndicator(
              onRefresh: refreshPage,
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
                        image: club.coverPicture == ''
                            ? AssetImage('Images/Image_not_available.png')
                                as ImageProvider
                            : CachedNetworkImageProvider(
                                club.coverPicture as String),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      child: Visibility(
                        visible: adminOrMember() == true,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            PopupMenuButton(
                              onSelected: (result) {
                                if (result == "edit") {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditClubScreen(
                                        club: club,
                                      ),
                                    ),
                                  );
                                } else if (result == "addAdmin") {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AddAdminScreen(
                                        club: club,
                                        CurrentUUID: widget.CurrentUUID,
                                      ),
                                    ),
                                  );
                                } else if (result == "removeMember") {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => RemoveMemberScreen(
                                        club: club,
                                        CurrentUUID: widget.CurrentUUID,
                                      ),
                                    ),
                                  );
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
                                return const <PopupMenuItem<String>>[
                                  // ignore: prefer_const_constructors
                                  PopupMenuItem(
                                    value: 'addAdmin',
                                    child: Text('Add/Remove an Admin'),
                                  ),
                                  PopupMenuItem(
                                    value: 'removeMember',
                                    child: Text('Add/Remove a Member'),
                                  ),
                                  PopupMenuItem(
                                    value: "edit",
                                    child: Text('Edit'),
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
                    transform: Matrix4.translationValues(0, -60, 0),
                    padding: EdgeInsets.symmetric(horizontal: 0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(25.0),
                          child: Container(
                            height: 160.0,
                            width: 160.0,
                            child: club.profilePicture == ''
                                ? Image.asset('Images/No_Image_Available.jpg')
                                : CachedNetworkImage(
                                    imageUrl: club.profilePicture as String,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              club.name as String,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                            club.verfied == true
                                ? const SizedBox(
                                    width: 5,
                                  )
                                : const SizedBox.shrink(),
                            club.verfied == true
                                ? const FaIcon(
                                    FontAwesomeIcons.solidCircleCheck,
                                    color: verifyColor,
                                  )
                                : const SizedBox.shrink(),
                          ],
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          club.bio as String,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        adminOrMember() == true
                            ? Row(
                                children: [
                                  SizedBox(
                                    width: 180,
                                    child: ElevatedButton(
                                      style: ButtonStyle(
                                        shape: MaterialStateProperty.all<
                                            RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(0.0),
                                          ),
                                        ),
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                                Colors.white),
                                        maximumSize:
                                            MaterialStateProperty.all<Size>(
                                                Size.infinite),
                                        minimumSize:
                                            MaterialStateProperty.all<Size>(
                                                const Size.fromHeight(40)),
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    PostRequestsScreen(
                                                      ClubID: widget.ClubID,
                                                    )));
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Requests',
                                              style: TextStyle(
                                                  color: blueWhaleColor)),
                                          Text(
                                            _numOfPostRequests.toString(),
                                            style:
                                                TextStyle(color: Colors.black),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 180,
                                    child: ElevatedButton(
                                      style: ButtonStyle(
                                        shape: MaterialStateProperty.all<
                                            RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(0.0),
                                          ),
                                        ),
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                                Colors.white),
                                        maximumSize:
                                            MaterialStateProperty.all<Size>(
                                                Size.infinite),
                                        minimumSize:
                                            MaterialStateProperty.all<Size>(
                                                const Size.fromHeight(40)),
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    JoinRequestScreen(
                                                      ClubID: widget.ClubID,
                                                    )));
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Join Requests',
                                              style: TextStyle(
                                                  color: blueWhaleColor)),
                                          Text(
                                            _numOfJoinRequests.toString(),
                                            style:
                                                TextStyle(color: Colors.black),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : (club.specificYear == '' ||
                                        club.specificYear == _yearUser) &&
                                    (_isJoined == true || club.private == false)
                                ? ElevatedButton(
                                    onPressed: () {
                                      joinAndLeaveClub();
                                    },
                                    child: _isJoined
                                        ? Text('Joined')
                                        : Text('Join'),
                                    style: ButtonStyle(
                                      backgroundColor: _isJoined
                                          ? MaterialStateProperty.all<Color>(
                                              Colors.grey)
                                          : MaterialStateProperty.all<Color>(
                                              lightRoyalBlueColor),
                                      shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                      ),
                                    ),
                                  )
                                : ElevatedButton(
                                    onPressed: () {
                                      requestToJoinClub();
                                    },
                                    child: _isRequestedToJoin
                                        ? Text('Requested to Join')
                                        : Text('Join'),
                                    style: ButtonStyle(
                                      backgroundColor: _isRequestedToJoin
                                          ? MaterialStateProperty.all<Color>(
                                              Colors.grey)
                                          : MaterialStateProperty.all<Color>(
                                              lightRoyalBlueColor),
                                      shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                      ),
                                    ),
                                  ),
                        _type == 'University'
                            ? ElevatedButton(
                                onPressed: () {
                                  verifyClub();
                                },
                                child: club.verfied == true
                                    ? Text('Verified')
                                    : Text('Verify'),
                                style: ButtonStyle(
                                  backgroundColor: _isVerified
                                      ? MaterialStateProperty.all<Color>(
                                          Colors.grey)
                                      : MaterialStateProperty.all<Color>(
                                          lightRoyalBlueColor),
                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                  ),
                                ),
                              )
                            : SizedBox.shrink(),
                        if (wait == false &&
                                _allPosts.isEmpty == false &&
                                _yearUser == '' ||
                            club.specificYear == '' ||
                            club.specificYear == _yearUser ||
                            adminOrMember() == true ||
                            _type == 'Faculty')
                          club.open == true || club.private == false
                              ? Column(
                                  children: <Widget>[...showPosts()],
                                )
                              : (club.open == false || club.private == true) &&
                                      (_isJoined || adminOrMember() == true)
                                  ? Column(
                                      children: <Widget>[...showPosts()],
                                    )
                                  : const SizedBox.shrink()
                        else if (club.specificYear != _yearUser)
                          const Center(
                            child: Text(
                              'You cannot view or join this club',
                              textAlign: TextAlign.center,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
