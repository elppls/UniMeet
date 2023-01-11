import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:unimeet_test/Models/PostModel.dart';
import 'package:unimeet_test/Shared_Widgets/RequestWidget.dart';

import '../Services/FirebaseServices.dart';
import '../Shared_Widgets/ClubPostWidget.dart';
import '../UniMeetColors/UniMeetConstants.dart';

class PostRequestsScreen extends StatefulWidget {
  final String ClubID;

  const PostRequestsScreen({super.key, required this.ClubID});

  @override
  State<PostRequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<PostRequestsScreen> {
  List _allRequests = [];
  Future<void> getAllRequests() async {
    List requests = await FirebaseServices.getAllPostRequests(widget.ClubID);
    if (mounted) {
      setState(() {
        _allRequests = requests;
      });
    }
  }

  buildPostRequests(PostModel post) {
    return RequestWidget(
        post: post,
        CurrentUUID: post.creatorId as String,
        clubID: widget.ClubID);
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
            stream:
                ClubsRef.doc(widget.ClubID).collection('requests').snapshots(),
            builder: (context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data!.docs.length < 1) {
                  return SizedBox.shrink();
                }
                return ListView.builder(
                  physics: AlwaysScrollableScrollPhysics(),
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context, index) {
                    PostModel post =
                        PostModel.fromDoc(snapshot.data.docs[index]);

                    return Column(
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        buildPostRequests(post),
                      ],
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
