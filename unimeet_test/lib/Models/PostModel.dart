import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  String? id;
  String? creatorId;
  String? postText;
  String? fileType;
  String? clubId;
  Timestamp? datePosted;

  PostModel(
      {this.id,
      this.fileType,
      this.creatorId,
      this.datePosted,
      this.postText,
      this.clubId});

  factory PostModel.fromDoc(DocumentSnapshot doc) {
    return PostModel(
      id: doc.id, //String
      creatorId: doc.data().toString().contains('creatorId')
          ? doc.get('creatorId')
          : '',
      postText:
          doc.data().toString().contains('postText') ? doc.get('postText') : '',
      fileType:
          doc.data().toString().contains('fileType') ? doc.get('fileType') : '',
      clubId: doc.data().toString().contains('clubId') ? doc.get('clubId') : '',
      datePosted: doc.data().toString().contains('datePosted')
          ? doc.get('datePosted')
          : '', //String
    );
  }
}
