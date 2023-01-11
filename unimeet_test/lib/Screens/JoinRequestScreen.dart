import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:unimeet_test/Models/PostModel.dart';
import 'package:unimeet_test/Models/UserModel.dart';
import 'package:unimeet_test/Shared_Widgets/RequestWidget.dart';

import '../Services/FirebaseServices.dart';
import '../Shared_Widgets/ClubPostWidget.dart';
import '../UniMeetColors/UniMeetConstants.dart';

class JoinRequestScreen extends StatefulWidget {
  final String ClubID;
  const JoinRequestScreen({super.key, required this.ClubID});

  @override
  State<JoinRequestScreen> createState() => _JoinRequestScreenState();
}

class _JoinRequestScreenState extends State<JoinRequestScreen> {
  List _allRequests = [];
  Future<void> getAllRequests() async {
    List requests = await FirebaseServices.getAllJoinRequests(widget.ClubID);
    if (mounted) {
      setState(() {
        _allRequests = requests;
      });
    }
  }

  getUser(String userId) async {
    UserModel user = await FirebaseServices.getUser(userId);
  }

  buildjoinRequests(UserModel user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
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
            Text(
              user.firstname! + " " + user.lastname! as String,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  overflow: TextOverflow.visible),
            ),
            Spacer(),
            IconButton(
                onPressed: () {
                  FirebaseServices.addMember(
                      user.id as String, widget.ClubID as String);
                  FirebaseServices.removeJoinRequest(
                      user.id as String, widget.ClubID as String);
                },
                icon: Icon(Icons.add))
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: lightRoyalBlueColor,
          centerTitle: true,
          elevation: 0.5,
          title: Text('Requests')),
      body: RefreshIndicator(
        onRefresh: getAllRequests,
        child: Container(
          child: StreamBuilder(
            stream: ClubsRef.doc(widget.ClubID)
                .collection('joinRequests')
                .snapshots(),
            builder: (context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data!.docs.length < 1) {
                  return SizedBox.shrink();
                }
                return ListView.builder(
                  physics: AlwaysScrollableScrollPhysics(),
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context, index) {
                    return FutureBuilder(
                      future:
                          usersRef.doc(snapshot.data.docs[index]['id']).get(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Container();
                        }
                        UserModel userModel = UserModel.fromDoc(
                            snapshot.data as DocumentSnapshot);
                        return buildjoinRequests(userModel);
                      },
                    );
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
    );
  }
}
