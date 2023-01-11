import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:unimeet_test/Models/ClubModel.dart';
import 'package:unimeet_test/UniMeetColors/UniMeetConstants.dart';
import 'package:http/http.dart' as http;

import '../Models/UserModel.dart';
import '../Services/FirebaseServices.dart';

class AddAdminScreen extends StatefulWidget {
  final ClubModel club;
  final String CurrentUUID;
  const AddAdminScreen(
      {super.key, required this.club, required this.CurrentUUID});

  @override
  State<AddAdminScreen> createState() => _AddAdminScreenState();
}

class _AddAdminScreenState extends State<AddAdminScreen> {
  UserModel? currentUser;
  getUser() async {
    currentUser = await FirebaseServices.getUser(widget.CurrentUUID);
  }

  builduser(UserModel user) {
    String fullname = '${user.firstname} ${user.lastname}';

    return Expanded(
      child: Card(
        child: Column(
          children: [
            ListTile(
              leading: user.profilePicture == ''
                  ? const CircleAvatar(
                      radius: 25,
                      backgroundImage:
                          AssetImage('Images/No_Image_Available.jpg'))
                  : CircleAvatar(
                      radius: 20,
                      backgroundImage:
                          NetworkImage(user.profilePicture as String),
                    ),
              title: Text(fullname as String),
              onTap: () {},
            ),
            Container(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    onPressed: () async {
                      await FirebaseServices.addAdmin(
                          user.id as String, widget.club);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        duration: Duration(milliseconds: 1250),
                        content: Text(
                            "Added ${user.firstname} ${user.lastname} as an admin"),
                      ));
                      FirebaseServices.sendNotification(
                          widget.club.name as String,
                          'You have been added as an admin',
                          user.token as String);
                    },
                    icon: Icon(Icons.add),
                  ),
                  IconButton(
                    onPressed: () async {
                      await FirebaseServices.removeAdmin(
                          user.id as String, widget.club);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        duration: Duration(milliseconds: 1250),
                        content: Text(
                            "Removed ${user.firstname} ${user.lastname} from the admin list"),
                      ));

                      FirebaseServices.sendNotification(
                          widget.club.name as String,
                          'You are no longer an admin',
                          user.token as String);
                    },
                    icon: Icon(Icons.remove),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    getUser();
    super.initState();
  }

  @override
  Future<QuerySnapshot>? _users;
  TextEditingController _searchController = TextEditingController();
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: lightRoyalBlueColor,
        centerTitle: true,
        elevation: 0.5,
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
            hintText: 'Search..',
            border: InputBorder.none,
            prefixIcon: const Icon(
              Icons.search,
              color: Colors.white,
            ),
            suffixIcon: IconButton(
              icon: const Icon(
                Icons.clear,
                color: blueWhaleColor,
              ),
              onPressed: () {
                _searchController.clear();
              },
            ),
          ),
          onChanged: (input) {
            if (input.isNotEmpty) {
              if (mounted) {
                setState(() {
                  _users = FirebaseServices.searchUsers(
                      input.toLowerCase(), currentUser!);
                });
              }
            }
          },
        ),
      ),
      body: _users == null
          ? Center(child: Container())
          : FutureBuilder(
              future: _users,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.data!.docs.length == 0) {
                  return Center(child: Text('User Not Found'));
                }
                return ListView.builder(
                    itemCount: snapshot.data.docs.length,
                    itemBuilder: (BuildContext context, int index) {
                      UserModel user =
                          UserModel.fromDoc(snapshot.data.docs[index]);
                      return builduser(user);
                    });
              },
            ),
    );
  }
}
