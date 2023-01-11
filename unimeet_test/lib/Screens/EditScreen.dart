import 'dart:io';

import 'package:easy_dialog/easy_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:unimeet_test/Models/UserModel.dart';
import 'package:unimeet_test/Screens/ChangePasswordScreen.dart';
import 'package:unimeet_test/Screens/DeleteProfileScreen.dart';
import 'package:unimeet_test/Services/FirebaseServices.dart';
import 'package:unimeet_test/UniMeetColors/UniMeetConstants.dart';

class EditScreen extends StatefulWidget {
  final UserModel user;
  const EditScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  String? _firstName;
  String? _lastName;
  String _image = '';
  late String _bio;
  late File _coverPic;
  void saveName() {
    UserModel user = UserModel(
        id: widget.user.id, firstname: _firstName, lastname: _lastName);
    FirebaseServices.updateUserNames(user);
  }

  void savebio() {
    UserModel user = UserModel(id: widget.user.id, bio: _bio);
    FirebaseServices.updateBio(user);
  }

  void deleteProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DeleteProfileScreen(
            Email: widget.user.email as String,
            CurrentUUID: widget.user.id as String),
      ),
    );
  }

  void saveProfilePic() {
    UserModel user = UserModel(id: widget.user.id, profilePicture: _image);
    FirebaseServices.updateProfilePic(user);
  }

  Future<void> uploadProfilePic() async {
    ImagePicker picker = ImagePicker();
    bool? isGallery = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              style: ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                backgroundColor:
                    MaterialStateProperty.all<Color>(lightRoyalBlueColor),
                maximumSize: MaterialStateProperty.all<Size>(Size.infinite),
                minimumSize:
                    MaterialStateProperty.all<Size>(const Size.fromHeight(40)),
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text("Gallery"),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              style: ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                backgroundColor:
                    MaterialStateProperty.all<Color>(lightRoyalBlueColor),
                maximumSize: MaterialStateProperty.all<Size>(Size.infinite),
                minimumSize:
                    MaterialStateProperty.all<Size>(const Size.fromHeight(40)),
              ),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text(" Camera"),
            ),
          ],
        ),
      ),
    );

    if (isGallery == null) return;

    XFile? file = await picker.pickImage(
        source: isGallery ? ImageSource.gallery : ImageSource.camera);

    String uniqueFileName = DateTime.now().microsecondsSinceEpoch.toString();
    Reference referenceDirImages = storageRef
        .child('Users')
        .child(widget.user.id as String)
        .child('ProfilePics');
    Reference refImagetoupload = referenceDirImages.child(uniqueFileName);

    try {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        duration: Duration(milliseconds: 1250),
        content: Text("Uploading Picture"),
      ));
      await refImagetoupload.putFile(File(file!.path));
      _image = await refImagetoupload.getDownloadURL();

      UserModel user = UserModel(id: widget.user.id, profilePicture: _image);
      FirebaseServices.updateProfilePic(user);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        duration: Duration(milliseconds: 1250),
        content: Text("Picture Uploaded, Looking good :D"),
      ));
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        duration: Duration(milliseconds: 1250),
        content: Text("Picture couldn't be uploaded :("),
      ));
    }
  }

  Future<void> uploadCoverPic() async {
    ImagePicker picker = ImagePicker();
    bool? isGallery = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              style: ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                backgroundColor:
                    MaterialStateProperty.all<Color>(lightRoyalBlueColor),
                maximumSize: MaterialStateProperty.all<Size>(Size.infinite),
                minimumSize:
                    MaterialStateProperty.all<Size>(const Size.fromHeight(40)),
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text("Gallery"),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              style: ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                backgroundColor:
                    MaterialStateProperty.all<Color>(lightRoyalBlueColor),
                maximumSize: MaterialStateProperty.all<Size>(Size.infinite),
                minimumSize:
                    MaterialStateProperty.all<Size>(const Size.fromHeight(40)),
              ),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text("Camera "),
            ),
          ],
        ),
      ),
    );

    if (isGallery == null) return;

    XFile? file = await picker.pickImage(
        source: isGallery ? ImageSource.gallery : ImageSource.camera);
    String uniqueFileName = DateTime.now().microsecondsSinceEpoch.toString();
    Reference referenceDirImages = storageRef
        .child('Users')
        .child(widget.user.id as String)
        .child('CoverPics');
    Reference refImagetoupload = referenceDirImages.child(uniqueFileName);

    try {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        duration: Duration(milliseconds: 1250),
        content: Text("Uploading Picture"),
      ));
      await refImagetoupload.putFile(File(file!.path));
      _image = await refImagetoupload.getDownloadURL();

      UserModel user = UserModel(id: widget.user.id, coverImage: _image);
      FirebaseServices.updateCoverPic(user);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        duration: Duration(milliseconds: 1250),
        content: Text("Picture Uploaded!"),
      ));
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        duration: Duration(milliseconds: 1250),
        content: Text("Picture couldn't be uploaded :("),
      ));
    }
  }

  void _editName() {
    EasyDialog(
      height: 250,
      contentList: [
        const Text(
          "Change Your Name",
          style: TextStyle(fontWeight: FontWeight.bold),
          textScaleFactor: 1.2,
        ),
        const SizedBox(height: 20),
        TextFormField(
          initialValue: widget.user.firstname,
          textInputAction: TextInputAction.next,
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
            hintText: 'Enter First Name',
            hintStyle: TextStyle(
              color: blueWhaleColor,
            ),
          ),
          onChanged: (value) {
            _firstName = value.trim();
          },
        ),
        const SizedBox(height: 20),
        TextFormField(
          initialValue: widget.user.lastname,
          textInputAction: TextInputAction.next,
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
            hintText: 'Enter Last Name',
            hintStyle: TextStyle(
              color: blueWhaleColor,
            ),
          ),
          onChanged: (value) {
            _lastName = value.trim();
          },
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          style: ButtonStyle(
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  side: BorderSide(color: Colors.black, width: 1)),
            ),
            backgroundColor:
                MaterialStateProperty.all<Color>(lightRoyalBlueColor),
            maximumSize: MaterialStateProperty.all<Size>(Size.infinite),
            minimumSize:
                MaterialStateProperty.all<Size>(const Size.fromHeight(40)),
          ),
          onPressed: () {
            saveName();
          },
          child: const Text('Submit', style: TextStyle(color: blueWhaleColor)),
        ),
      ],
    ).show(context);
  }

  void _editBio() {
    EasyDialog(
      height: 250,
      contentList: [
        const Text(
          "Change Your Bio",
          style: TextStyle(fontWeight: FontWeight.bold),
          textScaleFactor: 1.2,
        ),
        const SizedBox(height: 20),
        const SizedBox(height: 20),
        TextFormField(
          initialValue: widget.user.bio,
          maxLines: 3,
          textInputAction: TextInputAction.next,
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
            hintText: 'Enter Bio',
            hintStyle: TextStyle(
              color: blueWhaleColor,
            ),
          ),
          onChanged: (value) {
            _bio = value;
          },
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          style: ButtonStyle(
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  side: BorderSide(color: Colors.black, width: 1)),
            ),
            backgroundColor:
                MaterialStateProperty.all<Color>(lightRoyalBlueColor),
            maximumSize: MaterialStateProperty.all<Size>(Size.infinite),
            minimumSize:
                MaterialStateProperty.all<Size>(const Size.fromHeight(40)),
          ),
          onPressed: () {
            savebio();
          },
          child: const Text('Submit', style: TextStyle(color: blueWhaleColor)),
        ),
      ],
    ).show(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[350],
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              style: ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    side: BorderSide(color: Colors.black, width: 1),
                  ),
                ),
                backgroundColor:
                    MaterialStateProperty.all<Color>(lightRoyalBlueColor),
                maximumSize: MaterialStateProperty.all<Size>(Size.infinite),
                minimumSize:
                    MaterialStateProperty.all<Size>(const Size.fromHeight(40)),
              ),
              onPressed: () {
                uploadProfilePic();
              },
              child: const Text('Change Profile Picture',
                  style: TextStyle(color: blueWhaleColor)),
            ),
            SizedBox(
              height: 20,
            ),
            ElevatedButton(
              style: ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    side: BorderSide(color: Colors.black, width: 1),
                  ),
                ),
                backgroundColor:
                    MaterialStateProperty.all<Color>(lightRoyalBlueColor),
                maximumSize: MaterialStateProperty.all<Size>(Size.infinite),
                minimumSize:
                    MaterialStateProperty.all<Size>(const Size.fromHeight(40)),
              ),
              onPressed: () {
                uploadCoverPic();
              },
              child: const Text('Change Cover Picture',
                  style: TextStyle(color: blueWhaleColor)),
            ),
            SizedBox(
              height: 20,
            ),
            ElevatedButton(
              style: ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    side: BorderSide(color: Colors.black, width: 1),
                  ),
                ),
                backgroundColor:
                    MaterialStateProperty.all<Color>(lightRoyalBlueColor),
                maximumSize: MaterialStateProperty.all<Size>(Size.infinite),
                minimumSize:
                    MaterialStateProperty.all<Size>(const Size.fromHeight(40)),
              ),
              onPressed: _editBio,
              child: const Text('Change Bio',
                  style: TextStyle(color: blueWhaleColor)),
            ),
            SizedBox(
              height: 20,
            ),
            ElevatedButton(
              style: ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    side: BorderSide(color: Colors.black, width: 1),
                  ),
                ),
                backgroundColor:
                    MaterialStateProperty.all<Color>(lightRoyalBlueColor),
                maximumSize: MaterialStateProperty.all<Size>(Size.infinite),
                minimumSize:
                    MaterialStateProperty.all<Size>(const Size.fromHeight(40)),
              ),
              onPressed: () {
                _firstName = widget.user.firstname;
                _lastName = widget.user.lastname;
                _editName();
              },
              child: const Text('Change Name',
                  style: TextStyle(color: blueWhaleColor)),
            ),
            SizedBox(
              height: 20,
            ),
            ElevatedButton(
              style: ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    side: BorderSide(color: Colors.black, width: 1),
                  ),
                ),
                backgroundColor:
                    MaterialStateProperty.all<Color>(lightRoyalBlueColor),
                maximumSize: MaterialStateProperty.all<Size>(Size.infinite),
                minimumSize:
                    MaterialStateProperty.all<Size>(const Size.fromHeight(40)),
              ),
              onPressed: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChangePasswordScreen(
                      Email: widget.user.email as String,
                    ),
                  ),
                );
              },
              child: const Text('Change Password',
                  style: TextStyle(color: blueWhaleColor)),
            ),
            SizedBox(
              height: 20,
            ),
            ElevatedButton(
              style: ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    side: BorderSide(color: Colors.black, width: 1),
                  ),
                ),
                backgroundColor:
                    MaterialStateProperty.all<Color>(lightRoyalBlueColor),
                maximumSize: MaterialStateProperty.all<Size>(Size.infinite),
                minimumSize:
                    MaterialStateProperty.all<Size>(const Size.fromHeight(40)),
              ),
              onPressed: () {
                deleteProfile();
              },
              child: const Text('Delete Profile',
                  style: TextStyle(color: blueWhaleColor)),
            ),
            SizedBox(
              height: 20,
            ),
            SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}
