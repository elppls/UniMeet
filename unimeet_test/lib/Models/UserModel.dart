import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String? id;
  String? firstname;
  String? lastname;
  String? profilePicture;
  String? email;
  String? bio;
  String? coverImage;
  String? major;
  String? type;
  String? token;
  String? nameHelper;

  UserModel(
      {this.id,
      this.firstname,
      this.lastname,
      this.profilePicture,
      this.email,
      this.bio,
      this.token,
      this.major,
      this.coverImage,
      this.type,
      this.nameHelper});

  factory UserModel.fromDoc(DocumentSnapshot doc) {
    return UserModel(
      id: doc.id, //String
      firstname: doc.data().toString().contains('firstname')
          ? doc.get('firstname')
          : '', //String
      lastname: doc.data().toString().contains('lastname')
          ? doc.get('lastname')
          : '', //String
      email: doc.data().toString().contains('email')
          ? doc.get('email')
          : '', //String
      profilePicture: doc.data().toString().contains('profilePicture')
          ? doc.get('profilePicture')
          : '', //String
      bio: doc.data().toString().contains('bio') ? doc.get('bio') : '', //String
      major: doc.data().toString().contains('major')
          ? doc.get('major')
          : '', //String
      coverImage: doc.data().toString().contains('coverImage')
          ? doc.get('coverImage')
          : '',
      type: doc.data().toString().contains('type') ? doc.get('type') : '',
      token: doc.data().toString().contains('token') ? doc.get('token') : '',
      nameHelper: doc.data().toString().contains('nameHelper')
          ? doc.get('nameHelper')
          : '',
    );
  }
}
