import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ntp/ntp.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:unimeet_test/Models/PostModel.dart';
import 'package:unimeet_test/Models/UserModel.dart';
import 'package:unimeet_test/Services/FirebaseServices.dart';
import 'package:unimeet_test/UniMeetColors/UniMeetConstants.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';

import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../Screens/CommentScreen.dart';
import '../Screens/ProfileScreen.dart';

class ClubPostWidget extends StatefulWidget {
  final PostModel post;
  final String CurrentUUID;
  final String VisitedUUID;
  final String clubID;
  const ClubPostWidget(
      {super.key,
      required this.post,
      required this.CurrentUUID,
      required this.clubID,
      required this.VisitedUUID});

  @override
  State<ClubPostWidget> createState() => _ClubPostWidgetState();
}

class _ClubPostWidgetState extends State<ClubPostWidget> {
  final youtubeVideoEXP = RegExp(r'youtu');
  final videoEXP = RegExp(r'postsVideos');

  VideoPlayerController? _videocontroller;
  final urlToIdEXP = RegExp(r'([0-9A-z-_]{11})');
  YoutubePlayerController? _youtube_controller;
  int _likes = 0;
  int _comments = 0;
  bool _isLiked = false;
  List _allAdmins = [];

  final documentEXP = RegExp(r'postsDocuments');
  final pdfEXP = RegExp(r'.pdf');
  final docEXP = RegExp(r'.doc');
  final docxEXP = RegExp(r'.docx');
  var dio = Dio();

  bool adminOrMember() {
    for (int i = 0; i < _allAdmins.length; i++) {
      if (widget.VisitedUUID == _allAdmins[i]) return true;
    }
    return false;
  }

  buildName(UserModel user) {
    String fullname = '${user.firstname} ${user.lastname}';
    return Text(
      fullname as String,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Future<void> getAllAdmins() async {
    List admins = await FirebaseServices.getAllAdmins(widget.clubID);
    if (mounted) {
      setState(() {
        _allAdmins = admins;
      });
    }
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
        await FirebaseServices.deleteClubPost(
            widget.CurrentUUID, widget.post.id as String, widget.clubID);
        Navigator.pop(context);
      },
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete?"),
          content: const Text("Do you really want to delete this post?"),
          actions: [
            noBtn,
            yesBtn,
          ],
        );
      },
    );
  }

  Future downloadDocument(Dio dio, String url, String savePath) async {
    if (await Permission.storage.request().isGranted) {
      try {
        Response response = await dio.get(
          url,
          options: Options(
              responseType: ResponseType.bytes,
              followRedirects: false,
              validateStatus: (status) {
                return status! < 500;
              }),
        );
        File file = File(savePath);
        var raf = file.openSync(mode: FileMode.write);
        raf.writeFromSync(response.data);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          duration: Duration(milliseconds: 3250),
          content: Text('Downloaded inside ' + savePath),
        ));
        await raf.close();
      } catch (e) {
        print(e);
      }
    }
  }

  buildTime(PostModel post) {
    var timeMillisec = post.datePosted?.millisecondsSinceEpoch;
    DateTime posttime = DateTime.fromMillisecondsSinceEpoch(timeMillisec!);
    var clockTime;
    var difference = DateTime.now().difference(posttime);
    if (difference.inHours < 24) {
      clockTime = DateFormat('hh:mm').format(posttime);
    } else {
      clockTime = DateFormat('dd/MM/yyyy').format(posttime);
    }
    var clockToString = clockTime.toString();

    return Text(
      clockToString as String,
      style: const TextStyle(
        fontSize: 14,
      ),
    );
  }

  void newPost() {
    checkLike();
    getLikesCount();
    getCommentsCount();
  }

  getLikesCount() async {
    _likes =
        await FirebaseServices.postLikeCountClub(widget.clubID, widget.post);
    if (mounted) setState(() {});
  }

  getCommentsCount() async {
    _comments = await FirebaseServices.commentCount(widget.post.id as String);
    if (mounted) setState(() {});
  }

  likeAction() async {
    if (_isLiked == false) {
      like();
    } else {
      unlike();
    }
  }

  checkLike() async {
    bool isLiked = await FirebaseServices.likedPostClub(
        widget.VisitedUUID, widget.clubID, widget.post);

    _isLiked = isLiked;
    if (mounted) setState(() {});
  }

  like() {
    FirebaseServices.likeClubPost(
        widget.clubID, widget.VisitedUUID, widget.post);

    _isLiked = true;
    _likes++;
  }

  unlike() {
    FirebaseServices.unlikeClubPost(
        widget.clubID, widget.VisitedUUID, widget.post);

    _isLiked = false;
    _likes--;
  }

  bool getYoutubeController() {
    if (youtubeVideoEXP.hasMatch(widget.post.fileType.toString())) {
      final trimmed =
          urlToIdEXP.firstMatch(widget.post.fileType.toString())!.group(0);
      _youtube_controller = YoutubePlayerController(
        initialVideoId: trimmed.toString(),
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
          hideThumbnail: true,
        ),
      );
    }
    return true;
  }

  bool getVideoController() {
    _videocontroller =
        VideoPlayerController.network(widget.post.fileType.toString())
          ..initialize();

    return true;
  }

  @override
  void initState() {
    getAllAdmins();
    getLikesCount();
    checkLike();
    getCommentsCount();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    newPost();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          FutureBuilder(
            future: usersRef.doc(widget.CurrentUUID).get(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox.shrink();
              }

              UserModel user =
                  UserModel.fromDoc(snapshot.data as DocumentSnapshot);
              return Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: lightRoyalBlueColor,
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: user.profilePicture == ''
                                    ? GestureDetector(
                                        onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ProfileScreen(
                                              CurrentUUID: widget.VisitedUUID,
                                              VisitedUId: widget.CurrentUUID,
                                            ),
                                          ),
                                        ),
                                        child: const CircleAvatar(
                                            radius: 25,
                                            backgroundImage: AssetImage(
                                                'Images/No_Image_Available.jpg')),
                                      )
                                    : GestureDetector(
                                        onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ProfileScreen(
                                              CurrentUUID: widget.VisitedUUID,
                                              VisitedUId: widget.CurrentUUID,
                                            ),
                                          ),
                                        ),
                                        child: CircleAvatar(
                                          radius: 25,
                                          backgroundImage:
                                              CachedNetworkImageProvider(user
                                                  .profilePicture as String),
                                        ),
                                      ),
                              ),
                              Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    buildName(user),
                                    SizedBox(
                                      height: 10,
                                    ),
                                  ]),
                              Spacer(),
                              widget.CurrentUUID == widget.VisitedUUID ||
                                      adminOrMember() == true
                                  ? IconButton(
                                      onPressed: () {
                                        deleteAlert(context);
                                      },
                                      icon: Icon(Icons.clear))
                                  : SizedBox.shrink()
                            ],
                          ),
                          SizedBox(height: 10),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 15),
                            child: Text(
                              widget.post.postText as String,
                              style: const TextStyle(
                                fontSize: 15,
                              ),
                            ),
                          ),
                          if (widget.post.fileType == '')
                            const SizedBox.shrink()
                          else if (videoEXP
                                  .hasMatch(widget.post.fileType.toString()) &&
                              getVideoController())
                            Column(
                              children: [
                                const SizedBox(height: 10),
                                Column(
                                  children: [
                                    Container(
                                      height: 250,
                                      decoration: BoxDecoration(
                                        color: blueWhaleColor,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: VideoPlayer(_videocontroller!),
                                    ),
                                    IconButton(
                                      icon: _videocontroller!.value.isPlaying
                                          ? Icon(Icons.pause)
                                          : Icon(Icons.play_arrow),
                                      onPressed: () {
                                        _videocontroller!.value.isPlaying
                                            ? _videocontroller!.pause()
                                            : _videocontroller!.play();
                                      },
                                    ),
                                  ],
                                )
                              ],
                            )
                          else if (documentEXP
                              .hasMatch(widget.post.fileType.toString()))
                            Center(
                              child: Column(
                                children: [
                                  const SizedBox(height: 12),
                                  OutlinedButton(
                                      style: ButtonStyle(
                                        overlayColor:
                                            MaterialStateProperty.all<Color>(
                                                Color.fromARGB(19, 0, 0, 0)),
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                                Colors.transparent),
                                        shape: MaterialStateProperty.all(
                                            RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        30.0))),
                                      ),
                                      onPressed: () async {
                                        String fullPath = '';
                                        const downloadsFolderPath =
                                            '/storage/emulated/0/Download/';
                                        Directory dir =
                                            Directory(downloadsFolderPath);

                                        String uniqueFileName = DateTime.now()
                                            .microsecondsSinceEpoch
                                            .toString();
                                        if (pdfEXP.hasMatch(
                                            widget.post.fileType.toString())) {
                                          fullPath = dir.path +
                                              "/${uniqueFileName}.pdf";
                                        } else if (docEXP.hasMatch(
                                            widget.post.fileType.toString())) {
                                          fullPath = dir.path +
                                              "/${uniqueFileName}.doc";
                                        } else if (docxEXP.hasMatch(
                                            widget.post.fileType.toString())) {
                                          fullPath = dir.path +
                                              "/${uniqueFileName}.doc";
                                        }

                                        downloadDocument(
                                            dio,
                                            widget.post.fileType.toString(),
                                            fullPath);
                                      },
                                      child: const Text(
                                        'Download Document',
                                        style: TextStyle(color: Colors.black),
                                      )),
                                ],
                              ),
                            )
                          else if (youtubeVideoEXP
                                  .hasMatch(widget.post.fileType.toString()) &&
                              getYoutubeController())
                            Column(
                              children: [
                                const SizedBox(height: 15),
                                Container(
                                  height: 250,
                                  decoration: BoxDecoration(
                                    color: blueWhaleColor,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: YoutubePlayerBuilder(
                                    player: YoutubePlayer(
                                      controller: _youtube_controller!,
                                      showVideoProgressIndicator: true,
                                    ),
                                    builder: (context, player) {
                                      return Column(
                                        children: [player],
                                      );
                                    },
                                  ),
                                )
                              ],
                            )
                          else
                            Column(
                              children: [
                                const SizedBox(height: 15),
                                Container(
                                  height: 250,
                                  decoration: BoxDecoration(
                                      color: blueWhaleColor,
                                      borderRadius: BorderRadius.circular(10),
                                      image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image: CachedNetworkImageProvider(
                                            widget.post.fileType as String),
                                      )),
                                )
                              ],
                            ),
                          const SizedBox(
                            height: 30,
                          ),
                          Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  child: Text(
                                    ' ${_likes} Likes',
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.normal),
                                  ),
                                ),
                                Container(
                                  child: Text(
                                    ' ${_comments} Comments',
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.normal),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      likeAction();
                                    },
                                    icon: FaIcon(FontAwesomeIcons.solidHeart),
                                    color: _isLiked ? Colors.red : Colors.grey,
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => CommentScreen(
                                            CurrentUUID: widget.VisitedUUID,
                                            PostId: widget.post,
                                            VisitedUUID: widget.VisitedUUID,
                                          ),
                                        ),
                                      );
                                    },
                                    icon: const FaIcon(
                                      FontAwesomeIcons.solidComment,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          SizedBox(
            height: 20,
          )
        ],
      ),
    );
  }
}
