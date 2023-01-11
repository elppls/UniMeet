import 'package:cloud_firestore/cloud_firestore.dart';

class ItemModel {
  String? id;
  String? name;
  double? price;
  String? image;
  String? sellerName;
  String? sellerId;

  ItemModel(
      {this.id,
      this.name,
      this.price,
      this.image,
      this.sellerName,
      this.sellerId});

  factory ItemModel.fromDoc(DocumentSnapshot doc) {
    return ItemModel(
        id: doc.id,
        name: doc.data().toString().contains('name') ? doc.get('name') : '',
        image: doc.data().toString().contains('image') ? doc.get('image') : '',
        sellerName: doc.data().toString().contains('sellerName')
            ? doc.get('sellerName')
            : '',
        sellerId: doc.data().toString().contains('sellerId')
            ? doc.get('sellerId')
            : '',
        price: doc.data().toString().contains('price') ? doc.get('price') : '');
  }
}
