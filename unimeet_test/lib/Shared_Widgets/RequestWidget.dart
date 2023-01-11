import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:unimeet_test/Models/PostModel.dart';
import 'package:unimeet_test/Models/UserModel.dart';
import 'package:unimeet_test/Services/FirebaseServices.dart';
import 'package:unimeet_test/UniMeetColors/UniMeetConstants.dart';
import 'package:intl/intl.dart';

import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class RequestWidget extends StatefulWidget {
  final PostModel post;
  final String CurrentUUID;
  final String clubID;
  const RequestWidget(
      {super.key,
      required this.post,
      required this.CurrentUUID,
      required this.clubID});

  @override
  State<RequestWidget> createState() => _RequestWidgetState();
}

class _RequestWidgetState extends State<RequestWidget> {
  final youtubeVideoEXP = RegExp(r'youtu');
  final urlToIdEXP = RegExp(r'([0-9A-z-_]{11})');
  YoutubePlayerController? _youtube_controller;
  int _likes = 0;
  int _comments = 0;
  bool _isLiked = false;
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

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          FutureBuilder(
            future: usersRef.doc(widget.CurrentUUID).get(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator.adaptive(
                    valueColor: AlwaysStoppedAnimation(Colors.black),
                  ),
                );
              }

              UserModel user =
                  UserModel.fromDoc(snapshot.data as DocumentSnapshot);
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundImage: CachedNetworkImageProvider(
                                    user.profilePicture as String),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  buildName(user),
                                  buildTime(widget.post),
                                ],
                              ),
                              Spacer(),
                              IconButton(
                                onPressed: () async {
                                  FirebaseServices.approveRequest(widget.clubID,
                                      widget.CurrentUUID, widget.post);
                                },
                                icon: const Icon(
                                  Icons.add,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 15),
                          Text(
                            widget.post.postText as String,
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          if (widget.post.fileType == '')
                            const SizedBox.shrink()
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
                        ],
                      ),
                    ),
                  ),
                  const Divider(
                    thickness: 6,
                    color: Color.fromARGB(255, 245, 227, 227),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
