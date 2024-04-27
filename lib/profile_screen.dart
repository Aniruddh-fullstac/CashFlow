import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:money_tracker/home_screen.dart';
import 'package:money_tracker/login_screen.dart';
import 'package:money_tracker/user_Model.dart';
import 'package:shared_preferences/shared_preferences.dart';
class ProfileScreen extends StatefulWidget {
const ProfileScreen({super.key});
@override
State<ProfileScreen> createState() => _ProfileScreenState();
}
class _ProfileScreenState extends State<ProfileScreen> {
signoutUser() async {
await FirebaseAuth.instance.signOut().then((value) async {
final SharedPreferences prefs = await SharedPreferences.getInstance();
await prefs.setBool('isLoggedIn', false);
Navigator.pushAndRemoveUntil(
context,
MaterialPageRoute(
builder: (context) => LoginScreen(),
),
(route) => false,
);
});
}
Future<UserModel> getUserDetails() async {
final SharedPreferences preferences = await SharedPreferences.getInstance();
String userId = preferences.getString("userId") ?? "";
var userResponse =
await FirebaseFirestore.instance.collection("users").doc(userId).get();
UserModel userModel = UserModel.fromDocumentSnapShot(userResponse);
print(userModel.firstName);
return userModel;
}
@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
leading: null,
backgroundColor: Colors.indigo,
automaticallyImplyLeading: kIsWeb ? false : true,
title: Center(
child: Text("PROFILE SCREEN",
style: TextStyle(
fontSize: 25,
fontWeight: FontWeight.bold,
),),
),
actions: [
IconButton(
onPressed: ()async {
Navigator.push(
context,
MaterialPageRoute(
builder: (context) => HomeScreen(),
),
);
},
icon: Icon(Icons.home),
)
],
),
floatingActionButton: FloatingActionButton(
foregroundColor: Colors.black,
onPressed: () {
signoutUser();
},
child: Icon(Icons.logout_rounded),
),
body: FutureBuilder<UserModel>(
future: getUserDetails(),
builder: (context, snapshot) {
if (snapshot.hasData) {
return ProfileWidget(
userData: snapshot.data!,
);
} else {
return CircularProgressIndicator();
}
}
),
);
}
}
class ProfileWidget extends StatelessWidget {
const ProfileWidget({
super.key,
required this.userData,
});
final UserModel userData;
@override
Widget build(BuildContext context) {
return SizedBox(
height: MediaQuery.of(context).size.height,
width: MediaQuery.of(context).size.width,
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
crossAxisAlignment: CrossAxisAlignment.center,
children: [
CircleAvatar(
radius: 50,
child: Center(
child: Text(
userData.firstName![0] + userData.lastName![0],
style: TextStyle(
fontSize: 35,
fontWeight: FontWeight.bold,
color: const Color.fromARGB(255, 8, 48, 81),
),
),
),
),
SizedBox(
height: 15,
),
Text(
userData.firstName! + " " + userData.lastName!,
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.bold,
color: Colors.deepPurple,
),
),
Text(
userData.email!,
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.bold,
color: Colors.deepPurple,
),
),
],
),
);
}
}
