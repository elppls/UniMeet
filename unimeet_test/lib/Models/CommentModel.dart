import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  String? id;
  String? creatorId;
  String? commentText;
  Timestamp? datePosted;

  CommentModel({
    this.id,
    this.commentText,
    this.datePosted,
    this.creatorId,
  });

  factory CommentModel.fromDoc(DocumentSnapshot doc) {
    return CommentModel(
        id: doc.id,
        commentText: doc.data().toString().contains('commentText')
            ? doc.get('commentText')
            : '',
        datePosted: doc.data().toString().contains('datePosted')
            ? doc.get('datePosted')
            : '',
        creatorId: doc.data().toString().contains('messagecreatorIdText')
            ? doc.get('creatorId')
            : '');
  }
}
