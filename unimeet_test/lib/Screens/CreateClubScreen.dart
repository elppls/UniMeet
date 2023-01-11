import 'package:flutter/material.dart';
import 'package:unimeet_test/Models/ClubModel.dart';
import 'package:unimeet_test/UniMeetColors/UniMeetConstants.dart';
import 'package:uuid/uuid.dart';

import '../Services/FirebaseServices.dart';

class CreateClubScreen extends StatefulWidget {
  final String CurrentUUID;

  const CreateClubScreen({super.key, required this.CurrentUUID});

  @override
  State<CreateClubScreen> createState() => _CreateClubScreenState();
}

class _CreateClubScreenState extends State<CreateClubScreen> {
  String _clubName = '';
  String _uniName = '';
  bool _uniOnly = false;
  String _specificYear = '';
  bool _open = true;
  bool _private = false;
  String _bio = '';

  getUniName() async {
    List matchesToList = [];
    var docSnapshot = await usersRef.doc(widget.CurrentUUID).get();
    if (docSnapshot.exists) {
      Map<String, dynamic>? data = docSnapshot.data();
      String value = data?['email'];
      final uniDomain = RegExp(r'(?<=)[^.]+[a-zA-Z]');
      Iterable<Match> matches = uniDomain.allMatches(value);
      for (final Match in matches) {
        String match = Match[0]!;
        matchesToList.add(match);
      }
    }
    if (matchesToList[1] == 'std') {
      _uniName = matchesToList[2];
    } else {
      _uniName = matchesToList[1];
    }
  }

  @override
  void initState() {
    super.initState();
    getUniName();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: lightRoyalBlueColor,
          title: Text(
            'Create Club',
          ),
          actions: [
            IconButton(
                icon: const Icon(Icons.add),
                onPressed: () async {
                  ClubModel club = ClubModel(
                      id: Uuid().v4(),
                      name: _clubName,
                      nameHelper: _clubName.toLowerCase(),
                      profilePicture: '',
                      coverPicture: '',
                      bio: _bio,
                      uniName: _uniName,
                      verfied: false,
                      open: _open,
                      private: _private,
                      uniOnly: _uniOnly,
                      specificYear: _specificYear);

                  if (_clubName == '') {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      duration: Duration(milliseconds: 1250),
                      content: Text("Please add a name for the club"),
                    ));
                  } else {
                    await FirebaseServices.createClub(club);
                    await FirebaseServices.addAdmin(widget.CurrentUUID, club);
                    await FirebaseServices.addClubTojoinedClubsList(
                        widget.CurrentUUID, club.id as String);
                    Navigator.pop(context);
                  }
                }),
          ],
        ),
        backgroundColor: Colors.white,
        body: SafeArea(
            child: Container(
          child: ListView(
            physics:
                BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: 50,
                      decoration: BoxDecoration(
                          borderRadius: (BorderRadius.circular(10)),
                          color: Colors.white,
                          border: Border.all(color: Colors.green)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 10),
                        child: TextField(
                          textInputAction: TextInputAction.next,
                          style: const TextStyle(
                            color: Colors.black,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Enter Club name',
                            hintStyle: TextStyle(
                              color: lolaColor,
                            ),
                          ),
                          onChanged: (value) {
                            _clubName = value.trim();
                          },
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      height: 180,
                      decoration: BoxDecoration(
                          borderRadius: (BorderRadius.circular(10)),
                          color: Colors.white,
                          border: Border.all(color: Colors.green)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: TextField(
                          maxLength: 420,
                          maxLines: 6,
                          textInputAction: TextInputAction.next,
                          style: const TextStyle(
                            color: Colors.black,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Add bio',
                            hintStyle: TextStyle(
                              color: lolaColor,
                            ),
                          ),
                          onChanged: (value) {
                            _bio = value.trim();
                          },
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      decoration: BoxDecoration(
                          borderRadius: (BorderRadius.circular(10)),
                          color: Colors.white,
                          border: Border.all(color: Colors.green)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (_open == true)
                            const Text('Open')
                          else
                            const Text('Closed'),
                          PopupMenuButton(
                            constraints: const BoxConstraints.expand(
                                width: 100, height: 110),
                            onSelected: (String result) {
                              if (mounted) {
                                setState(() {
                                  if (result == 'open')
                                    _open = true;
                                  else
                                    _open = false;
                                });
                              }
                            },
                            icon: const Icon(
                              Icons.arrow_drop_down,
                              color: Colors.black,
                              size: 20,
                            ),
                            itemBuilder: (context) {
                              return <PopupMenuItem<String>>[
                                const PopupMenuItem(
                                  child: Text('Open'),
                                  value: 'open',
                                ),
                                const PopupMenuItem(
                                  child: Text('Closed'),
                                  value: 'closed',
                                ),
                              ];
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      decoration: BoxDecoration(
                          borderRadius: (BorderRadius.circular(10)),
                          color: Colors.white,
                          border: Border.all(color: Colors.green)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (_private == true)
                            const Text('Private')
                          else
                            const Text('Not Private'),
                          PopupMenuButton(
                            constraints: const BoxConstraints.expand(
                                width: 100, height: 110),
                            onSelected: (String result) {
                              if (mounted) {
                                setState(() {
                                  if (result == 'private')
                                    _private = true;
                                  else
                                    _private = false;
                                });
                              }
                            },
                            icon: const Icon(
                              Icons.arrow_drop_down,
                              color: Colors.black,
                              size: 20,
                            ),
                            itemBuilder: (context) {
                              return <PopupMenuItem<String>>[
                                const PopupMenuItem(
                                  child: Text('Private'),
                                  value: 'private',
                                ),
                                const PopupMenuItem(
                                  child: Text('Not Private'),
                                  value: 'notPrivate',
                                ),
                              ];
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      decoration: BoxDecoration(
                          borderRadius: (BorderRadius.circular(10)),
                          color: Colors.white,
                          border: Border.all(color: Colors.green)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'University Students only?',
                            style: TextStyle(fontSize: 16),
                          ),
                          Checkbox(
                            activeColor: Colors.green,
                            value: _uniOnly,
                            onChanged: (bool? value) {
                              if (mounted) {
                                setState(() {
                                  _uniOnly = value ?? true;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      decoration: BoxDecoration(
                          borderRadius: (BorderRadius.circular(10)),
                          color: Colors.white,
                          border: Border.all(color: Colors.green)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (_specificYear == '')
                            Text('Specific Year?')
                          else
                            Text(_specificYear),
                          PopupMenuButton(
                            constraints: const BoxConstraints.expand(
                                width: 100, height: 150),
                            onSelected: (String result) {
                              if (mounted) {
                                setState(() {
                                  _specificYear = result;
                                });
                              }
                            },
                            icon: const Icon(
                              Icons.arrow_drop_down,
                              color: Colors.black,
                              size: 20,
                            ),
                            itemBuilder: (context) {
                              return <PopupMenuItem<String>>[
                                const PopupMenuItem(
                                  child: Text('No'),
                                  value: '',
                                ),
                                const PopupMenuItem(
                                  child: Text('2017'),
                                  value: '2017',
                                ),
                                const PopupMenuItem(
                                  child: Text('2018'),
                                  value: '2018',
                                ),
                                const PopupMenuItem(
                                  child: Text('2019'),
                                  value: '2019',
                                ),
                                const PopupMenuItem(
                                  child: Text('2020'),
                                  value: '2020',
                                ),
                                const PopupMenuItem(
                                  child: Text('2021'),
                                  value: '2021',
                                ),
                                const PopupMenuItem(
                                  child: Text('2022'),
                                  value: '202',
                                ),
                                const PopupMenuItem(
                                  child: Text('2023'),
                                  value: '2023',
                                ),
                                const PopupMenuItem(
                                  child: Text('2024'),
                                  value: '2024',
                                ),
                                const PopupMenuItem(
                                  child: Text('2025'),
                                  value: '2025',
                                ),
                              ];
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        )));
  }
}
