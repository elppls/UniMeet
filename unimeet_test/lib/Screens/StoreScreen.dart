import 'dart:ffi';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:unimeet_test/Models/ItemModel.dart';
import 'package:unimeet_test/Screens/AddItemScreen.dart';
import 'package:unimeet_test/Screens/MessageScreen.dart';
import 'package:unimeet_test/Services/FirebaseServices.dart';

import '../UniMeetColors/UniMeetConstants.dart';

class StoreScreen extends StatefulWidget {
  final String CurrentUUID;
  const StoreScreen({Key? key, required this.CurrentUUID}) : super(key: key);

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

deleteAlert(BuildContext context, ItemModel item) {
  Widget noBtn = TextButton(
    child: const Text("No"),
    onPressed: () {
      Navigator.pop(context);
    },
  );
  Widget yesBtn = TextButton(
    child: const Text("Yes"),
    onPressed: () async {
      await FirebaseServices.deleteStoreItem(item.id as String);
      Navigator.pop(context);
    },
  );

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Delete?"),
        content: const Text("Do you really want to delete this item?"),
        actions: [
          noBtn,
          yesBtn,
        ],
      );
    },
  );
}

buildItem(ItemModel item, BuildContext context, String CurrrentUser) {
  return Container(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.topRight,
          children: [
            Container(
              height: 250,
              decoration: BoxDecoration(
                borderRadius: (BorderRadius.circular(10)),
                color: Colors.white,
                border: Border.all(color: Colors.pink),
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: CachedNetworkImageProvider(item.image as String),
                ),
              ),
            ),
            if (CurrrentUser == item.sellerId as String)
              IconButton(
                iconSize: 40,
                onPressed: () {
                  deleteAlert(context, item);
                },
                icon: FaIcon(
                  FontAwesomeIcons.xmark,
                  color: lightRoyalBlueColor,
                ),
                style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100.0),
                    ),
                  ),
                  backgroundColor:
                      MaterialStateProperty.all<Color>(blueWhaleColor),
                ),
              )
            else
              SizedBox.shrink(),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              item.name as String,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(
              width: 5,
            ),
            Text(
              item.price.toString() + '\$',
              style: const TextStyle(fontSize: 15),
            ),
          ],
        ),
        Text(
          item.sellerName as String,
          style: const TextStyle(fontSize: 12),
        ),
        if (CurrrentUser != item.sellerId as String)
          IconButton(
            iconSize: 40,
            onPressed: () {
              if (CurrrentUser != item.sellerId as String) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MessageScreen(
                              CurrentUUID: CurrrentUser,
                              VisitedUId: item.sellerId as String,
                            )));
              }
            },
            icon: FaIcon(
              FontAwesomeIcons.message,
              color: lightRoyalBlueColor,
            ),
            style: ButtonStyle(
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100.0),
                ),
              ),
              backgroundColor: MaterialStateProperty.all<Color>(blueWhaleColor),
            ),
          )
        else
          SizedBox.shrink()
      ],
    ),
  );
}

class _StoreScreenState extends State<StoreScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: lightRoyalBlueColor,
        centerTitle: true,
        title: Text('Store'),
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
                  builder: (context) => AddItemScreen(
                        CurrentUUID: widget.CurrentUUID,
                      )));
        },
      ),
      body: Container(
        child: StreamBuilder(
          stream:
              FirebaseFirestore.instance.collection('storeItems').snapshots(),
          builder: (context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data!.docs.length < 1) {
                return SizedBox.shrink();
              }
              return GridView.builder(
                physics: AlwaysScrollableScrollPhysics(),
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  ItemModel item = ItemModel.fromDoc(snapshot.data.docs[index]);

                  return Column(
                    children: [
                      buildItem(item, context, widget.CurrentUUID as String),
                    ],
                  );
                },
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 0,
                  childAspectRatio: MediaQuery.of(context).size.width /
                      (MediaQuery.of(context).size.height),
                ),
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
}
