import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:money_tracker/transaction_model.dart';

class TransactionsPage extends StatefulWidget {
  @override
  _TransactionsPageState createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transaction History'),
        actions: [
          IconButton(
            icon: Icon(Icons.calculate),
            onPressed: () {
              showTotalAmountDialog();
            },
          ),
        ],
      ),
      body: StreamBuilder(
        stream:
            FirebaseFirestore.instance.collection('transactions').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          }

          List<TransactionModel> transactions = [];

          for (var doc in snapshot.data!.docs) {
            var data = doc.data() as Map<String, dynamic>;
            transactions.add(TransactionModel.fromDocumentSnapshot(doc));
          }

          return ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(transactions[index].description ?? ''),
                subtitle: Text(
                  '${transactions[index].amount} ${transactions[index].category}',
                ),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    deleteTransaction(transactions[index].transactionId!);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  void deleteTransaction(String transactionId) {
    FirebaseFirestore.instance
        .collection('transactions')
        .doc(transactionId)
        .delete();
  }

  void showTotalAmountDialog() {
    FirebaseFirestore.instance
        .collection('transactions')
        .get()
        .then((querySnapshot) {
      double totalAmount = 0.0;

      for (var doc in querySnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        totalAmount += data['amount']?.toDouble() ?? 0.0;
      }

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Total Amount Spent'),
            content: Text('Total: $totalAmount'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    });
  }
}
