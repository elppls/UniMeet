import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';

const Color blueWhaleColor = Color.fromARGB(255, 29, 55, 68);
const Color berryColor = Color(0xff7F5283);
const Color verifyColor = Color.fromARGB(255, 29, 161, 242);

const Color lolaColor = Color.fromARGB(255, 193, 169, 195);

const Color lightRoyalBlueColor = Color.fromARGB(245, 88, 126, 138);

final _firestore = FirebaseFirestore.instance;
final usersRef = _firestore.collection('users');
final ClubsRef = _firestore.collection('clubs');
final ClubsJoinedRef = _firestore.collection('clubsJoined');
final StoreRef = _firestore.collection('storeItems');
final followersRef = _firestore.collection('followers');
final followingRef = _firestore.collection('following');
final postsRef = _firestore.collection('posts');
final messageRef = _firestore.collection('messages');
final storageRef = FirebaseStorage.instance.ref();
