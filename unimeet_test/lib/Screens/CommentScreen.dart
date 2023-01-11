import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:unimeet_test/Models/PostModel.dart';
import 'package:unimeet_test/Models/UserModel.dart';
import 'package:intl/intl.dart';
import 'package:unimeet_test/UniMeetColors/UniMeetConstants.dart';

import 'package:http/http.dart' as http;
import '../Services/FirebaseServices.dart';

class CommentScreen extends StatefulWidget {
  final String CurrentUUID;
  final String VisitedUUID;
  final PostModel PostId;
  const CommentScreen({
    super.key,
    required this.CurrentUUID,
    required this.PostId,
    required this.VisitedUUID,
  });

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  bool ownComment = false;
  UserModel? VisitedUser;
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

  buildTime(Timestamp comment) {
    var timeMillisec = comment.millisecondsSinceEpoch;
    DateTime posttime = DateTime.fromMillisecondsSinceEpoch(timeMillisec);
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

  copyText(String commentText) async {
    await Clipboard.setData(ClipboardData(text: commentText));
  }

  deleteComment(String commentId) async {
    await FirebaseServices.deleteComment(commentId, widget.PostId.id as String);
  }

  bool checkOwnComment(String creatorId) {
    if (widget.CurrentUUID == creatorId) {
      return true;
    }
    return false;
  }

  buildComment(String commentId, String commentText, String creatorId,
      Timestamp datePosted) {
    return FutureBuilder(
      future:
          FirebaseFirestore.instance.collection('users').doc(creatorId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SizedBox.shrink();
        } else {
          UserModel commenter =
              UserModel.fromDoc(snapshot.data as DocumentSnapshot);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    commenter.profilePicture == ''
                        ? const CircleAvatar(
                            radius: 25,
                            backgroundImage:
                                AssetImage('Images/No_Image_Available.jpg'))
                        : CircleAvatar(
                            radius: 25,
                            backgroundImage: CachedNetworkImageProvider(
                                commenter.profilePicture as String),
                          ),
                    const SizedBox(width: 10),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.75,
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 222, 219, 219),
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                        border: Border.all(
                          width: 0.3,
                          color: Colors.black,
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
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  buildName(commenter),
                                  PopupMenuButton(
                                    onSelected: (result) async {
                                      if (result == "copy") {
                                        copyText(commentText);
                                      } else if (result == "delete") {
                                        deleteComment(commentId);
                                      }
                                    },
                                    icon: Container(
                                      color: Colors.white,
                                      child: const Icon(
                                        Icons.more_horiz,
                                        color: Colors.black,
                                        size: 20,
                                      ),
                                    ),
                                    itemBuilder: (context) {
                                      return <PopupMenuItem<String>>[
                                        // ignore: prefer_const_constructors
                                        PopupMenuItem(
                                          child: const Text('Copy Text'),
                                          value: 'copy',
                                        ),

                                        PopupMenuItem(
                                          child: Text('Delete'),
                                          value: "delete",
                                          enabled: checkOwnComment(creatorId) ||
                                              widget.PostId.creatorId
                                                      as String ==
                                                  widget.CurrentUUID,
                                        ),
                                      ];
                                    },
                                  ),
                                ],
                              ),
                              Text(
                                commentText as String,
                                style: const TextStyle(
                                  overflow: TextOverflow.visible,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              )
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
          );
        }
      },
    );
  }

  getUser() async {
    VisitedUser = await FirebaseServices.getUser(widget.VisitedUUID);
  }

  @override
  void initState() {
    getUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController _controller = TextEditingController();
    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              Expanded(
                child: Container(
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('comments')
                        .doc(widget.PostId.id)
                        .collection('comments')
                        .orderBy('datePosted', descending: false)
                        .snapshots(),
                    builder: (context, AsyncSnapshot snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data!.docs.length < 1) {
                          return SizedBox.shrink();
                        }

                        return ListView.builder(
                          reverse: false,
                          itemCount: snapshot.data.docs.length,
                          itemBuilder: (context, index) {
                            return buildComment(
                                snapshot.data.docs[index].id,
                                snapshot.data.docs[index]["commentText"],
                                snapshot.data.docs[index]["creatorId"],
                                snapshot.data.docs[index]["datePosted"]);
                          },
                        );
                      }
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                  ),
                ),
              ),
              Divider(),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: TextField(
                          controller: _controller,
                          decoration: const InputDecoration(
                            hintText: 'Add a Comment',
                            fillColor: Color.fromARGB(255, 186, 186, 186),
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
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.1,
                    child: IconButton(
                      icon: const Icon(Icons.send),
                      iconSize: 20,
                      onPressed: () {
                        String comment = _controller.text;
                        _controller.clear();
                        FirebaseServices.addComment(widget.PostId.id as String,
                            comment, widget.CurrentUUID);

                        FirebaseServices.sendNotification(
                            'New Comment!',
                            'Someone Posted a comment on your post',
                            VisitedUser?.token as String);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
