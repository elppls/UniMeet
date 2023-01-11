import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_dialog/easy_dialog.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:unimeet_test/Models/PostModel.dart';
import '../Models/UserModel.dart';
import '../Services/FirebaseServices.dart';
import '../UniMeetColors/UniMeetConstants.dart';

class CreatePostScreen extends StatefulWidget {
  final String CurrentUUID;
  const CreatePostScreen({Key? key, required this.CurrentUUID})
      : super(key: key);

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  String _imageURL = '';
  bool _boolImage = false;
  String _fileTypeString = '';
  bool _imageVideoOrFile = false;
  String _postText = '';
  String _youtubeURL = '';
  bool uploading = false;

  Future<void> uploadPicture() async {
    uploading = true;
    if (mounted) setState(() {});
    _imageVideoOrFile = true;
    ImagePicker picker = ImagePicker();

    XFile? file = await picker.pickImage(source: ImageSource.gallery);

    String uniqueFileName = DateTime.now().microsecondsSinceEpoch.toString();
    Reference referenceDirImages = storageRef
        .child('Users')
        .child(widget.CurrentUUID)
        .child('postsImages');
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
            .child('Users')
            .child(widget.CurrentUUID)
            .child('postsDocuments')
            .child(uniqueFileName + fileName)
            .putData(fileBytes!);
        showImage();
        Reference downloadURL = storageRef
            .child('Users')
            .child(widget.CurrentUUID)
            .child('postsDocuments')
            .child(uniqueFileName + fileName);

        storageRef
            .child('Users')
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

  Future<void> uploadVideo() async {
    uploading = true;
    if (mounted) {
      setState(() {
        _imageVideoOrFile = true;
      });
    }
    _imageVideoOrFile = true;
    ImagePicker picker = ImagePicker();

    XFile? file = await picker.pickVideo(source: ImageSource.gallery);
    if (file == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        duration: Duration(milliseconds: 1250),
        content: Text("Please choose a Video"),
      ));
      Navigator.pop(context);
    }
    if (file != null) {
      String uniqueFileName = DateTime.now().microsecondsSinceEpoch.toString();
      Reference referenceDirImages = storageRef
          .child('Users')
          .child(widget.CurrentUUID)
          .child('postsVideos');
      Reference refImagetoupload = referenceDirImages.child(uniqueFileName);

      try {
        await refImagetoupload.putFile(File(file.path));
        _imageURL = await refImagetoupload.getDownloadURL();
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
  }

  showImage() {
    if (mounted) {
      setState(() {
        _fileTypeString = _imageURL;
      });
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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Post'),
        backgroundColor: lightRoyalBlueColor,
        actions: [
          if (uploading)
            SizedBox.shrink()
          else
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                String fileTypeHandler = _fileTypeString;
                if (_postText != '') {
                  PostModel post = PostModel(
                    postText: _postText,
                    creatorId: widget.CurrentUUID,
                    fileType: fileTypeHandler,
                  );
                  FirebaseServices.uploadPost(post);

                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    duration: Duration(milliseconds: 1250),
                    content: Text("Please add text to the post"),
                  ));
                }
              },
            ),
        ],
      ),
      backgroundColor: Colors.white,
      body: FutureBuilder(
        future: usersRef.doc(widget.CurrentUUID).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container();
          }
          UserModel userModel =
              UserModel.fromDoc(snapshot.data as DocumentSnapshot);

          String fullname = '${userModel.firstname} ${userModel.lastname}';
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
                            userModel.profilePicture == ''
                                ? const CircleAvatar(
                                    radius: 25,
                                    backgroundImage: AssetImage(
                                        'Images/No_Image_Available.jpg'))
                                : CircleAvatar(
                                    radius: 30,
                                    backgroundImage: NetworkImage(
                                        userModel.profilePicture as String),
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
                            )
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
