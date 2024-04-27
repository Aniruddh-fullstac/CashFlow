import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:money_tracker/login_screen.dart';
import 'package:money_tracker/transaction_model.dart';
import 'package:money_tracker/profile_screen.dart';
import 'package:money_tracker/transactions_page.dart'; // Add this import

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String userId = "";

  @override
  void initState() {
    super.initState();
    getUserId();
  }

  getUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString("userId") ?? "";
  }

  signOutUser() async {
    await FirebaseAuth.instance.signOut().then((value) async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', false);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
        (route) => false,
      );
    });
  }

  addTransactionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController amountController = TextEditingController();
        TextEditingController categoryController = TextEditingController();
        TextEditingController descriptionController = TextEditingController();

        return AlertDialog(
          title: Text("Add Transaction"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(hintText: "Amount"),
              ),
              TextField(
                controller: categoryController,
                decoration: InputDecoration(hintText: "Category"),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(hintText: "Description"),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                double amount = double.tryParse(amountController.text) ?? 0.0;
                String category = categoryController.text;
                String description = descriptionController.text;

                uploadTransaction(
                  amount: amount,
                  category: category,
                  description: description,
                );
              },
              child: Text("Add"),
            ),
          ],
        );
      },
    );
  }

  uploadTransaction({
    required double amount,
    required String category,
    required String description,
  }) async {
    try {
      await FirebaseFirestore.instance.collection("transactions").add(
        {
          "user_id": userId,
          "amount": amount,
          "category": category,
          "description": description,
          "date": DateTime.now(),
        },
      );
      Navigator.pop(context);
    } catch (e) {
      print("Error uploading transaction: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to add transaction. Please try again."),
        ),
      );
    }
  }

  Stream<QuerySnapshot> getTransactions() {
    print("Calling getTransactions");
    return FirebaseFirestore.instance
        .collection("transactions")
        .where("user_id", isEqualTo: userId)
        .snapshots()
        .handleError((error) {
      print("Error fetching transactions: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.indigo,
        title: Center(
          child: Text(
            "Money Tracker",
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(),
                ),
              );
            },
            icon: Icon(Icons.person),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      TransactionsPage(), // Navigate to TransactionsPage
                ),
              );
            },
            icon: Icon(Icons
                .history), // Add a history icon to navigate to TransactionsPage
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          addTransactionDialog();
        },
        child: Icon(Icons.add),
      ),
      body: StreamBuilder(
        stream: getTransactions(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!.docs.isNotEmpty) {
              List<TransactionModel> transactionsList = [];

              for (var element in snapshot.data!.docs) {
                Map<String, dynamic> data =
                    element.data() as Map<String, dynamic>;
                data["transaction_id"] = element.id;

                transactionsList
                    .add(TransactionModel.fromDocumentSnapshot(element));
              }

              return TransactionWidget(
                transactions: transactionsList,
              );
            } else {
              return Center(
                child: Text(""),
              );
            }
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}

class TransactionWidget extends StatelessWidget {
  const TransactionWidget({
    Key? key,
    required this.transactions,
  }) : super(key: key);

  final List<TransactionModel> transactions;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(
            transactions[index].description ?? "",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            "${transactions[index].amount} ${transactions[index].category}",
          ),
          trailing: IconButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection("transactions")
                  .doc(transactions[index].transactionId)
                  .delete();
            },
            icon: Icon(Icons.delete),
          ),
        );
      },
    );
  }
}
