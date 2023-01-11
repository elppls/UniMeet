import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:unimeet_test/Models/UserModel.dart';
import 'package:unimeet_test/Screens/ProfileScreen.dart';
import 'package:unimeet_test/Services/FirebaseServices.dart';
import 'package:unimeet_test/UniMeetColors/UniMeetConstants.dart';

class SearchScreen extends StatefulWidget {
  final String CurrentUUID;
  const SearchScreen({Key? key, required this.CurrentUUID}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  UserModel? currentUser;
  builduser(UserModel user) {
    String fullname = '${user.firstname} ${user.lastname}';

    return ListTile(
      leading: user.profilePicture == ''
          ? const CircleAvatar(
              radius: 25,
              backgroundImage: AssetImage('Images/No_Image_Available.jpg'))
          : CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(user.profilePicture as String),
            ),
      title: Text(fullname as String),
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: ((context) => ProfileScreen(
                CurrentUUID: widget.CurrentUUID,
                VisitedUId: user.id as String))));
      },
    );
  }

  getUser() async {
    currentUser = await FirebaseServices.getUser(widget.CurrentUUID);
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
          ? Center(
              child: Container(),
            )
          : FutureBuilder(
              future: _users,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.data!.docs.length == 0) {
                  return Center(child: Text('no data'));
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
