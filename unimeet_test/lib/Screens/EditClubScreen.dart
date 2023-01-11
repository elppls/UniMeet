import 'dart:io';

import 'package:easy_dialog/easy_dialog.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:image_picker/image_picker.dart';
import 'package:unimeet_test/Models/ClubModel.dart';
import 'package:unimeet_test/Screens/ClubsScreen.dart';

import '../Services/FirebaseServices.dart';
import '../UniMeetColors/UniMeetConstants.dart';

class EditClubScreen extends StatefulWidget {
  final ClubModel club;
  const EditClubScreen({super.key, required this.club});

  @override
  State<EditClubScreen> createState() => _EditClubScreenState();
}

class _EditClubScreenState extends State<EditClubScreen> {
  String? _name;
  String _image = '';
  late String _bio;
  late File _coverPic;
  void saveName() {
    ClubModel club = ClubModel(id: widget.club.id, name: _name);
    FirebaseServices.updateClubName(club);
  }

  void savebio() {
    ClubModel club = ClubModel(id: widget.club.id, bio: _bio);
    FirebaseServices.updateClubBio(club);
  }

  void saveProfilePic() {
    ClubModel club = ClubModel(id: widget.club.id, profilePicture: _image);
    FirebaseServices.updateClubProfilePic(club);
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
      ..child('Clubs').child(widget.club.id as String).child('ProfilePics');
    Reference refImagetoupload = referenceDirImages.child(uniqueFileName);

    try {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        duration: Duration(milliseconds: 1250),
        content: Text("Uploading Picture"),
      ));
      await refImagetoupload.putFile(File(file!.path));
      _image = await refImagetoupload.getDownloadURL();

      ClubModel club = ClubModel(id: widget.club.id, profilePicture: _image);

      FirebaseServices.updateClubProfilePic(club);
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
        .child('Clubs')
        .child(widget.club.id as String)
        .child('CoverPics');
    Reference refImagetoupload = referenceDirImages.child(uniqueFileName);

    try {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        duration: Duration(milliseconds: 1250),
        content: Text("Uploading Picture"),
      ));
      await refImagetoupload.putFile(File(file!.path));
      _image = await refImagetoupload.getDownloadURL();

      ClubModel club = ClubModel(id: widget.club.id, coverPicture: _image);
      FirebaseServices.updateClubCoverPic(club);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
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
          initialValue: widget.club.name,
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
            _name = value.trim();
          },
        ),
        const SizedBox(height: 20),
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
          initialValue: widget.club.bio,
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
      backgroundColor: Colors.white,
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
                _name = widget.club.name;
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
                await FirebaseServices.deleteClub(widget.club.id as String);
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Delete Club',
                  style: TextStyle(color: blueWhaleColor)),
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
