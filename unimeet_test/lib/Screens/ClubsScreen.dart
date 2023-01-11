import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:unimeet_test/Models/ClubModel.dart';
import 'package:unimeet_test/Screens/ClubScreen.dart';
import 'package:unimeet_test/Screens/CreateClubScreen.dart';
import 'package:unimeet_test/UniMeetColors/UniMeetConstants.dart';

import '../Services/FirebaseServices.dart';

class ClubsScreen extends StatefulWidget {
  final String CurrentUUID;

  const ClubsScreen({super.key, required this.CurrentUUID});

  @override
  State<ClubsScreen> createState() => _ClubsScreenState();
}

class _ClubsScreenState extends State<ClubsScreen> {
  List _allClubs = [];
  String _emptySearchbar = '';

  Future<void> getAllClubs() async {
    List clubs = await FirebaseServices.getAllClubs();
    if (mounted) {
      setState(() {
        _allClubs = clubs;
      });
    }
  }

  viewClub(ClubModel club) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: ((context) => ClubScreen(
              CurrentUUID: widget.CurrentUUID,
              ClubID: club.id as String,
            ))));
  }

  buildClub(ClubModel club) {
    return GestureDetector(
      onTap: () => viewClub(club),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10),
          height: 80,
          decoration: BoxDecoration(
            border: Border.all(color: lightRoyalBlueColor),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20.0),
                child: Container(
                  height: 60.0,
                  width: 60.0,
                  child: club.profilePicture == ''
                      ? Image.asset('Images/Image_not_available.png')
                      : CachedNetworkImage(
                          imageUrl: club.profilePicture as String,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              const SizedBox(
                width: 15,
              ),
              Container(
                width: 120,
                child: Text(
                  club.name as String,
                  maxLines: 10,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
              const Spacer(flex: 22),
              club.private == false
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Spacer(),
                        const Text('Open'),
                        const Spacer(),
                        club.verfied == true
                            ? const FaIcon(
                                FontAwesomeIcons.solidCircleCheck,
                                color: verifyColor,
                              )
                            : SizedBox.shrink(),
                        club.verfied == true ? Spacer() : SizedBox.shrink(),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Spacer(),
                        const Text('Private'),
                        const Spacer(),
                        club.verfied == true
                            ? const FaIcon(
                                FontAwesomeIcons.solidCircleCheck,
                                color: verifyColor,
                              )
                            : const SizedBox.shrink(),
                        club.verfied == true
                            ? const Spacer()
                            : const SizedBox.shrink(),
                      ],
                    ),
              Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  buildClubSearch(ClubModel club) {
    return ListTile(
      leading: CircleAvatar(
        radius: 20,
        backgroundImage: NetworkImage(club.profilePicture as String),
      ),
      title: Text(club.name as String),
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: ((context) => ClubsScreen(
                  CurrentUUID: widget.CurrentUUID,
                ))));
      },
    );
  }

  @override
  void initState() {
    getAllClubs();
    super.initState();
  }

  @override
  Future<QuerySnapshot>? _clubs;
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
            hintText: 'Search Clubs',
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
                  _clubs = FirebaseServices.searchClubs(input.toLowerCase());
                });
              }
            }
            if (mounted) {
              setState(() {
                _emptySearchbar = input;
              });
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.pink,
        child: const Icon(
          Icons.add,
          color: lolaColor,
        ),
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => CreateClubScreen(
                        CurrentUUID: widget.CurrentUUID,
                      )));
        },
      ),
      body: FutureBuilder(
        future: _clubs,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData ||
              _emptySearchbar == '' ||
              snapshot.data!.docs.length == 0) {
            return RefreshIndicator(
              onRefresh: getAllClubs,
              child: Container(
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('clubs')
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
                          ClubModel club =
                              ClubModel.fromDoc(snapshot.data.docs[index]);

                          return Column(
                            children: [
                              const SizedBox(
                                height: 10,
                              ),
                              buildClub(club),
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
            );
          }
          return ListView.builder(
              itemCount: snapshot.data.docs.length,
              itemBuilder: (BuildContext context, int index) {
                ClubModel club = ClubModel.fromDoc(snapshot.data.docs[index]);
                return buildClubSearch(club);
              });
        },
      ),
    );
  }
}
