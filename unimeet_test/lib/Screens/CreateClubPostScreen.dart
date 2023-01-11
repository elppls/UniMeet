import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_dialog/easy_dialog.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:unimeet_test/Models/ClubModel.dart';
import 'package:unimeet_test/Models/PostModel.dart';
import '../Models/UserModel.dart';
import '../Services/FirebaseServices.dart';

import 'package:http/http.dart' as http;
import '../UniMeetColors/UniMeetConstants.dart';

class CreateClubPostScreen extends StatefulWidget {
  final String CurrentUUID;
  final String ClubID;

  const CreateClubPostScreen(
      {super.key, required this.CurrentUUID, required this.ClubID});

  @override
  State<CreateClubPostScreen> createState() => _CreateClubPostScreenState();
}

class _CreateClubPostScreenState extends State<CreateClubPostScreen> {
  String _imageURL = '';
  bool _boolImage = false;
  String _fileTypeString = '';
  bool _imageVideoOrFile = false;
  String _postText = '';
  String _youtubeURL = '';
  List _allAdmins = [];
  List _allMembers = [];
  ClubModel? club;
  List<UserModel> membersUserModel = [];

  bool uploading = false;

  Future<void> uploadPicture() async {
    uploading = true;
    if (mounted) setState(() {});
    ImagePicker picker = ImagePicker();

    XFile? file = await picker.pickImage(source: ImageSource.gallery);

    String uniqueFileName = DateTime.now().microsecondsSinceEpoch.toString();
    Reference referenceDirImages = storageRef
        .child('Clubs')
        .child(widget.ClubID)
        .child(widget.CurrentUUID)
        .child('postsPictures');
    Reference refImagetoupload = referenceDirImages.child(uniqueFileName);

    try {
      await refImagetoupload.putFile(File(file!.path));
      _imageURL = await refImagetoupload.getDownloadURL();
      _boolImage = true;
      _imageVideoOrFile = true;

      showImage();
      uploading = false;
      if (mounted) setState(() {});
    } catch (error) {}
  }

  Future<void> uploadVideo() async {
    uploading = true;
    if (mounted) setState(() {});
    ImagePicker picker = ImagePicker();

    XFile? file = await picker.pickVideo(source: ImageSource.gallery);
    if (file == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        duration: Duration(milliseconds: 1250),
        content: Text("Please choose a Video"),
      ));

      Navigator.pop(context);
    }
    String uniqueFileName = DateTime.now().microsecondsSinceEpoch.toString();
    Reference referenceDirImages = storageRef
        .child('Clubs')
        .child(widget.ClubID)
        .child(widget.CurrentUUID)
        .child('postsVideos');
    Reference refImagetoupload = referenceDirImages.child(uniqueFileName);

    try {
      await refImagetoupload.putFile(File(file!.path));
      _imageURL = await refImagetoupload.getDownloadURL();
      _imageVideoOrFile = true;

      showImage();
      uploading = false;
      if (mounted) setState(() {});
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        duration: Duration(milliseconds: 1250),
        content: Text("Something went wrong, please try again"),
      ));
      Navigator.pop(context);
    }
  }

  showImage() {
    if (mounted) {
      setState(() {
        _fileTypeString = _imageURL;
      });
    }
  }

  Future<void> uploadDocuments() async {
    uploading = true;
    if (mounted) {
      setState(() {
        _imageVideoOrFile = true;
      });
    }
    _imageVideoOrFile = true;
    String uniqueFileName = DateTime.now().microsecondsSinceEpoch.toString();
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
        withData: true);
    if (result != null) {
      File file = File(result.files.single.path as String);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        duration: Duration(milliseconds: 1250),
        content: Text("Please choose a file"),
      ));
      Navigator.pop(context);
    }

    if (result != null) {
      try {
        Uint8List? fileBytes = await result.files.first.bytes;
        String fileName = result.files.first.name;
        await storageRef
            .child('Clubs')
            .child(widget.ClubID)
            .child(widget.CurrentUUID)
            .child('postsDocuments')
            .child(uniqueFileName + fileName)
            .putData(fileBytes!);
        showImage();
        Reference downloadURL = storageRef
            .child('Clubs')
            .child(widget.ClubID)
            .child(widget.CurrentUUID)
            .child('postsDocuments')
            .child(uniqueFileName + fileName);

        storageRef
            .child('Clubs')
            .child(widget.ClubID)
            .child(widget.CurrentUUID)
            .child('postsDocuments')
            .child(uniqueFileName + fileName)
            .putData(fileBytes);
        _imageURL = await downloadURL.getDownloadURL();
        showImage();
        uploading = false;
        if (mounted) setState(() {});
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          duration: Duration(milliseconds: 1250),
          content: Text("Something went wrong, please try again"),
        ));
        Navigator.pop(context);
      }
    }
  }

  void _addYoutubeURL() {
    EasyDialog(
      height: 250,
      contentList: [
        const Text(
          "Add Youtube URL",
          style: TextStyle(fontWeight: FontWeight.bold),
          textScaleFactor: 1.2,
        ),
        const SizedBox(height: 20),
        const SizedBox(height: 20),
        TextFormField(
          maxLines: 1,
          style: const TextStyle(
            color: Colors.black,
          ),
          decoration: const InputDecoration(
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.cyan),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.cyan),
            ),
            hintText: 'Enter URL',
            hintStyle: TextStyle(
              color: lolaColor,
            ),
          ),
          onChanged: (value) {
            _youtubeURL = value;
          },
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          style: ButtonStyle(
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
            ),
            backgroundColor:
                MaterialStateProperty.all<Color>(lightRoyalBlueColor),
            maximumSize: MaterialStateProperty.all<Size>(Size.infinite),
            minimumSize:
                MaterialStateProperty.all<Size>(const Size.fromHeight(40)),
          ),
          onPressed: () {
            _imageVideoOrFile = true;
            _fileTypeString = _youtubeURL;
          },
          child: const Text('Submit', style: TextStyle(color: lolaColor)),
        ),
      ],
    ).show(context);
  }

  Future<void> getAllAdmins() async {
    List admins = await FirebaseServices.getAllAdmins(widget.ClubID);
    if (mounted) {
      setState(() {
        _allAdmins = admins;
      });
    }
  }

  Future<void> getAllMembers() async {
    List members = await FirebaseServices.getAllMembers(widget.ClubID);
    if (mounted) {
      setState(() {
        _allMembers = members;
      });
    }

    for (final member in members) {
      UserModel user = await FirebaseServices.getUser(member);
      membersUserModel.add(user);
    }
  }

  bool adminOrMember() {
    for (int i = 0; i < _allAdmins.length; i++) {
      if (widget.CurrentUUID == _allAdmins[i]) return true;
    }
    return false;
  }

  getClub() async {
    club = await FirebaseServices.getClub(widget.ClubID);
  }

  @override
  void initState() {
    getAllAdmins();
    getAllMembers();
    getClub();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Post'),
        backgroundColor: lightRoyalBlueColor,
      ),
      backgroundColor: Colors.white,
      body: FutureBuilder(
        future: usersRef.doc(widget.CurrentUUID).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container();
          }
          UserModel user = UserModel.fromDoc(snapshot.data as DocumentSnapshot);

          String fullname = '${user.firstname} ${user.lastname}';
          return SafeArea(
            child: ListView(
              physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics()),
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 30,
                        ),
                        Container(
                            child: Row(
                          children: [
                            user.profilePicture == ''
                                ? const CircleAvatar(
                                    radius: 25,
                                    backgroundImage: AssetImage(
                                        'Images/No_Image_Available.jpg'))
                                : CircleAvatar(
                                    radius: 30,
                                    backgroundImage: NetworkImage(
                                        user.profilePicture as String),
                                  ),
                            const SizedBox(
                              width: 10,
                            ),
                            Container(
                              transform: Matrix4.translationValues(0, -5, 0),
                              child: Text(
                                fullname as String,
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Spacer(),
                            if (uploading)
                              SizedBox.shrink()
                            else
                              ElevatedButton(
                                  style: ButtonStyle(
                                    shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                    ),
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            lightRoyalBlueColor),
                                  ),
                                  onPressed: () async {
                                    String fileTypeHandler = _fileTypeString;
                                    if (_postText != '') {
                                      PostModel post = PostModel(
                                          postText: _postText,
                                          creatorId: widget.CurrentUUID,
                                          fileType: fileTypeHandler,
                                          clubId: widget.ClubID);
                                      if (adminOrMember() == true) {
                                        await FirebaseServices.uploadClubPost(
                                            post, widget.ClubID);

                                        for (final member in membersUserModel) {
                                          FirebaseServices.sendNotification(
                                              'New Post',
                                              'New Post in${club?.name}',
                                              member.token as String);
                                        }
                                      } else {
                                        await FirebaseServices
                                            .uploadClubPostRequest(
                                                post, widget.ClubID);
                                      }
                                    }

                                    Navigator.pop(context);
                                  },
                                  child: Text('add'))
                          ],
                        )),
                        const SizedBox(
                          height: 15,
                        ),
                        Container(
                          height: 200,
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
                                hintText: 'Add a post',
                                hintStyle: TextStyle(
                                  color: lolaColor,
                                ),
                              ),
                              onChanged: (value) {
                                _postText = value.trim();
                              },
                            ),
                          ),
                        ),
                        Visibility(
                          visible: _boolImage,
                          child: Container(
                            transform: Matrix4.translationValues(0, 60, 0),
                            child: Container(
                              height: 200,
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                fit: BoxFit.cover,
                                image: NetworkImage(_fileTypeString as String),
                              )),
                            ),
                          ),
                        ),
                        Visibility(
                          visible: !_imageVideoOrFile,
                          child: ElevatedButton(
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  lightRoyalBlueColor),
                              maximumSize: MaterialStateProperty.all<Size>(
                                  Size.infinite),
                              minimumSize: MaterialStateProperty.all<Size>(
                                  const Size.fromHeight(40)),
                            ),
                            onPressed: () {
                              uploadPicture();
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              // ignore: prefer_const_literals_to_create_immutables
                              children: [
                                const Text('Image',
                                    style: TextStyle(color: blueWhaleColor)),
                                const Icon(
                                  Icons.image,
                                  color: Colors.black,
                                )
                              ],
                            ),
                          ),
                        ),
                        Visibility(
                          visible: !_imageVideoOrFile,
                          child: ElevatedButton(
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  lightRoyalBlueColor),
                              maximumSize: MaterialStateProperty.all<Size>(
                                  Size.infinite),
                              minimumSize: MaterialStateProperty.all<Size>(
                                  const Size.fromHeight(40)),
                            ),
                            onPressed: () {
                              uploadVideo();
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Video',
                                    style: TextStyle(color: blueWhaleColor)),
                                Icon(
                                  Icons.videocam,
                                  color: Colors.black,
                                )
                              ],
                            ),
                          ),
                        ),
                        Visibility(
                          visible: !_imageVideoOrFile,
                          child: ElevatedButton(
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  lightRoyalBlueColor),
                              maximumSize: MaterialStateProperty.all<Size>(
                                  Size.infinite),
                              minimumSize: MaterialStateProperty.all<Size>(
                                  const Size.fromHeight(40)),
                            ),
                            onPressed: () {
                              _addYoutubeURL();
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Youtube URL',
                                    style: TextStyle(color: blueWhaleColor)),
                                FaIcon(
                                  FontAwesomeIcons.youtube,
                                  color: Colors.black,
                                )
                              ],
                            ),
                          ),
                        ),
                        Visibility(
                          visible: !_imageVideoOrFile,
                          child: ElevatedButton(
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  lightRoyalBlueColor),
                              maximumSize: MaterialStateProperty.all<Size>(
                                  Size.infinite),
                              minimumSize: MaterialStateProperty.all<Size>(
                                  const Size.fromHeight(40)),
                            ),
                            onPressed: () {
                              uploadDocuments();
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('File',
                                    style: TextStyle(color: blueWhaleColor)),
                                Icon(
                                  Icons.insert_drive_file,
                                  color: Colors.black,
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
