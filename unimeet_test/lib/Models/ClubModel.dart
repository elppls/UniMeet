import 'package:cloud_firestore/cloud_firestore.dart';

class ClubModel {
  String? id;
  String? name;
  bool? verfied;
  String? profilePicture;
  String? specificYear;
  String? uniName;
  String? nameHelper;
  bool? open;
  bool? private;
  String? coverPicture;
  String? bio;
  bool? uniOnly;

  ClubModel(
      {this.id,
      this.uniName,
      this.name,
      this.verfied,
      this.nameHelper,
      this.private,
      this.profilePicture,
      this.coverPicture,
      this.specificYear,
      this.open,
      this.bio,
      this.uniOnly});

  factory ClubModel.fromDoc(DocumentSnapshot doc) {
    return ClubModel(
        id: doc.id,
        name: doc.data().toString().contains('name') ? doc.get('name') : '',
        private: doc.data().toString().contains('private')
            ? doc.get('private')
            : false,
        verfied:
            doc.data().toString().contains('verfied') ? doc.get('verfied') : '',
        profilePicture: doc.data().toString().contains('profilePicture')
            ? doc.get('profilePicture')
            : '',
        specificYear: doc.data().toString().contains('specificYear')
            ? doc.get('specificYear')
            : '',
        open: doc.data().toString().contains('open') ? doc.get('open') : true,
        nameHelper: doc.data().toString().contains('nameHelper')
            ? doc.get('nameHelper')
            : '',
        uniOnly: doc.data().toString().contains('uniOnly')
            ? doc.get('uniOnly')
            : false,
        coverPicture: doc.data().toString().contains('coverPicture')
            ? doc.get('coverPicture')
            : '',
        bio: doc.data().toString().contains('bio') ? doc.get('bio') : '',
        uniName: doc.data().toString().contains('uniName')
            ? doc.get('uniName')
            : '');
  }
}
