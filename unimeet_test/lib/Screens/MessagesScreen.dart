import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:unimeet_test/Models/UserModel.dart';
import 'package:unimeet_test/Screens/MessageScreen.dart';
import 'package:unimeet_test/Services/FirebaseServices.dart';
import 'package:intl/intl.dart';
import 'package:unimeet_test/UniMeetColors/UniMeetConstants.dart';

class MessagesScreen extends StatefulWidget {
  final String CurrentUUID;
  const MessagesScreen({super.key, required this.CurrentUUID});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  var _user;
  String _lastMessageTimeString = '';
  bool _loading = true;

  getUser(String userId) async {
    UserModel user = await FirebaseServices.getUser(userId);
    _user = user;
    if (_user != null) {}
    return user;
  }

  Future<String> getLastMessage(UserModel user) async {
    String _lastMessage = await FirebaseServices.getLastMessage(
        widget.CurrentUUID, user.id as String);

    await FirebaseServices.getLastMessage(widget.CurrentUUID, user.id as String)
        .then((String result) {
      return result;
    });
    return _lastMessage;
  }

  Future<String> buildTime(UserModel user) async {
    var timeMillisec = await FirebaseServices.getLastMessageTime(
        widget.CurrentUUID, user.id as String);
    DateTime posttime = DateTime.fromMillisecondsSinceEpoch(
        timeMillisec.millisecondsSinceEpoch);
    var clockTime;
    var difference = DateTime.now().difference(posttime);
    if (difference.inHours < 24) {
      clockTime = DateFormat('hh:mm').format(posttime);
    } else {
      clockTime = DateFormat('dd/MM/yyyy').format(posttime);
    }
    var clockToString = clockTime.toString();
    return clockToString;
  }

  buildName(UserModel user) {
    String fullname = '${user.firstname} ${user.lastname}';
    return Text(
      fullname as String,
      style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          overflow: TextOverflow.visible),
    );
  }

  viewMessage(String VisitedUUID) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: ((context) => MessageScreen(
              CurrentUUID: widget.CurrentUUID,
              VisitedUId: VisitedUUID,
            ))));
  }

  buildMessage(UserModel user) {
    return GestureDetector(
      onTap: () => viewMessage(user.id as String),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10),
          height: 80,
          decoration: BoxDecoration(
            border: Border.all(color: lightRoyalBlueColor),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20.0),
                child: Container(
                  height: 60.0,
                  width: 60.0,
                  child: user.profilePicture == ''
                      ? Image.asset('Images/Image_not_available.png')
                      : CachedNetworkImage(
                          imageUrl: user.profilePicture as String,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              const SizedBox(
                width: 15,
              ),
              Expanded(
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      buildName(user),
                      FutureBuilder(
                        future: getLastMessage(user),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Container();
                          }
                          return Container(
                            child: Text(
                              (snapshot.data as String).length < 20
                                  ? snapshot.data as String
                                  : '${(snapshot.data as String).substring(1, 20)}...',
                              style: TextStyle(overflow: TextOverflow.visible),
                            ),
                          );
                        },
                      )
                    ],
                  ),
                ),
              ),
              Spacer(),
              FutureBuilder(
                future: buildTime(user),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Container();
                  }
                  return Container(
                    child: Text(snapshot.data as String),
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: lightRoyalBlueColor,
          title: Container(
            child: Row(
              children: const [
                SizedBox(
                  width: 30,
                ),
              ],
            ),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('messages')
                        .doc(widget.CurrentUUID)
                        .collection('chats')
                        .snapshots(),
                    builder: (context, AsyncSnapshot snapshot) {
                      if (!snapshot.hasData) {
                        return Center(
                          child: Container(),
                        );
                      }

                      return ListView.builder(
                        itemCount: snapshot.data.docs.length,
                        itemBuilder: (context, index) {
                          return FutureBuilder(
                            future: usersRef
                                .doc(snapshot.data.docs[index]["exist"])
                                .get(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return Container();
                              }
                              UserModel userModel = UserModel.fromDoc(
                                  snapshot.data as DocumentSnapshot);
                              return Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  child: buildMessage(userModel));
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ),

              // ignore: prefer_const_constructors
            ],
          ),
        ));
  }
}
