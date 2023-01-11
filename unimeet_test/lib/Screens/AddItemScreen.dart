import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:unimeet_test/Models/ItemModel.dart';
import 'package:unimeet_test/Services/FirebaseServices.dart';

import '../UniMeetColors/UniMeetConstants.dart';

class AddItemScreen extends StatefulWidget {
  final String CurrentUUID;

  const AddItemScreen({super.key, required this.CurrentUUID});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  String _itemName = '';
  double _itemPrice = 0;
  String _itemImage = '';
  String _sellerName = '';
  bool _imageUploaded = false;
  Future<void> uploadPicture() async {
    ImagePicker picker = ImagePicker();

    XFile? file = await picker.pickImage(source: ImageSource.gallery);

    String uniqueFileName = DateTime.now().microsecondsSinceEpoch.toString();
    Reference referenceDirImages = FirebaseStorage.instance
        .ref()
        .child('storeImages')
        .child(widget.CurrentUUID);
    Reference refImagetoupload = referenceDirImages.child(uniqueFileName);

    try {
      await refImagetoupload.putFile(File(file!.path));
      _itemImage = await refImagetoupload.getDownloadURL();
      _imageUploaded = true;
      if (mounted) {
        setState(() {});
      }
    } catch (error) {}
  }

  getSellerName() async {
    var docSnapshot = await usersRef.doc(widget.CurrentUUID).get();
    if (docSnapshot.exists) {
      Map<String, dynamic>? data = docSnapshot.data();
      String firstname = data?['firstname'];
      String lastname = data?['lastname'];
      String value = firstname + ' ' + lastname;
      _sellerName = value;
    }
  }

  @override
  void initState() {
    getSellerName();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: lightRoyalBlueColor,
        title: Text('Add an Item'),
        actions: [
          IconButton(
            onPressed: () async {
              ItemModel item = ItemModel(
                  image: _itemImage,
                  name: _itemName,
                  price: _itemPrice,
                  sellerId: widget.CurrentUUID,
                  sellerName: _sellerName);
              if (_imageUploaded && _itemName != '' && _itemPrice != 0) {
                await FirebaseServices.addItem(item);

                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  duration: Duration(milliseconds: 1250),
                  content: Text("Please fill all the fields and the Image"),
                ));
              }
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 10,
            ),
            Container(
              height: 50,
              decoration: BoxDecoration(
                  borderRadius: (BorderRadius.circular(10)),
                  color: Colors.white,
                  border: Border.all(color: Colors.green)),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: TextField(
                  textInputAction: TextInputAction.next,
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'What are you Selling?',
                    hintStyle: TextStyle(
                      color: lolaColor,
                    ),
                  ),
                  onChanged: (value) {
                    _itemName = value.trim();
                  },
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              height: 60,
              decoration: BoxDecoration(
                  borderRadius: (BorderRadius.circular(10)),
                  color: Colors.white,
                  border: Border.all(color: Colors.green)),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: TextField(
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Price?',
                    hintStyle: TextStyle(
                      color: lolaColor,
                    ),
                  ),
                  onChanged: (value) {
                    if (value == '')
                      _itemPrice = 0;
                    else
                      _itemPrice = double.parse(value).toDouble();
                  },
                ),
              ),
            ),
            SizedBox(
              height: 10,
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
                uploadPicture();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                // ignore: prefer_const_literals_to_create_immutables
                children: [
                  const Text('Image', style: TextStyle(color: blueWhaleColor)),
                  const Icon(
                    Icons.image,
                    color: Colors.black,
                  )
                ],
              ),
            ),
            Visibility(
              visible: _imageUploaded,
              child: Container(
                transform: Matrix4.translationValues(0, 60, 0),
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(_itemImage as String),
                  )),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
