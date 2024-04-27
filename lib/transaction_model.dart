import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  String? userId;
  double? amount;
  String? category;
  String? description;
  DateTime? date;
  String? transactionId;

  TransactionModel({
    this.userId,
    this.amount,
    this.category,
    this.description,
    this.date,
    this.transactionId,
  });

  // Constructor to create a TransactionModel from a DocumentSnapshot
  TransactionModel.fromDocumentSnapshot(DocumentSnapshot doc) {
    var data = doc.data() as Map<String, dynamic>;
    userId = data['user_id'];
    amount = data['amount']?.toDouble();
    category = data['category'];
    description = data['description'];
    date = (data['date'] as Timestamp?)?.toDate();
    transactionId = doc.id;
  }

  // Convert TransactionModel to a map for storing in Firestore
  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'amount': amount,
      'category': category,
      'description': description,
      'date': date,
    };
  }
}
