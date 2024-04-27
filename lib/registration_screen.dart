import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:money_tracker/login_screen.dart';
class RegistrationScreen extends StatefulWidget {
const RegistrationScreen({super.key});
@override
State<RegistrationScreen> createState() => _RegistrationScreenState();
}
class _RegistrationScreenState extends State<RegistrationScreen> {
bool _obscureText = true;
TextEditingController emailController = TextEditingController();
TextEditingController passwordController = TextEditingController();
TextEditingController firstNameController = TextEditingController();
TextEditingController lastNameController = TextEditingController();
registerUser({
required String firstName,
required String lastName,
required String email,
required String password,
}) {
try {
final credential = FirebaseAuth.instance
.createUserWithEmailAndPassword(
email: email,
password: password,
)
.then((value) {
print(value.user?.uid.toString());
addUserData(
firstName: firstName,
lastName: lastName,
email: email,
userId: value.user?.uid ?? "",
);
Fluttertoast.showToast(msg: "User Registered");
});
} on FirebaseAuthException catch (e) {
Fluttertoast.showToast(msg: e.toString());
} catch (e) {
Fluttertoast.showToast(msg: e.toString());
}
}
addUserData({
required String firstName,
required String lastName,
required String email,
required String userId,
}) {
FirebaseFirestore firestore = FirebaseFirestore.instance;
firestore.collection("users").doc(userId).set(
{
"first_name": firstName,
"last_name": lastName,
"created_name": DateTime.now(),
"updated_at": DateTime.now(),
"email": email,
"user_id": userId,
"photo": "",
},
).then((value) async {
// final SharedPreferences prefs = await SharedPreferences.getInstance();
// await prefs.setBool('isLoggedIn', true);
Navigator.pushAndRemoveUntil(
context,
MaterialPageRoute(
builder: (context) => LoginScreen(),
),
(route) => false,
);
});
}
@override
Widget build(BuildContext context) {
return Scaffold(
body: Column(
mainAxisAlignment: MainAxisAlignment.spaceAround,
children: [
const SizedBox(),
Padding(
padding: EdgeInsets.symmetric(
horizontal: MediaQuery.of(context).size.width * 0.2,
),
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
crossAxisAlignment: CrossAxisAlignment.center,
children: [
TextField(
controller: firstNameController,
decoration: InputDecoration(
labelText: "First Name",
hintText: "Enter First Name",
labelStyle: TextStyle(fontSize: 10),
border: OutlineInputBorder(
borderRadius: BorderRadius.circular(10),
),
),
),
const SizedBox(
height: 20,
),
TextField(
controller: lastNameController,
decoration: InputDecoration(
labelText: "Second Name",
hintText: "Enter Second Name",
labelStyle: TextStyle(fontSize: 10),
border: OutlineInputBorder(
borderRadius: BorderRadius.circular(10),
),
),
),
const SizedBox(
height: 20,
),
TextField(
controller: emailController,
decoration: InputDecoration(
labelText: "Email",
hintText: "Enter Email",
labelStyle: TextStyle(fontSize: 10),
border: OutlineInputBorder(
borderRadius: BorderRadius.circular(10),
),
),
),
const SizedBox(
height: 20,
),
TextField(
controller: passwordController,
decoration: InputDecoration(
labelText: "Password",
hintText: "Enter Password",
labelStyle: TextStyle(fontSize: 10),
border: OutlineInputBorder(
borderRadius: BorderRadius.circular(10),
),
suffixIcon: IconButton(
icon: Icon(
_obscureText ? Icons.visibility_off : Icons.visibility,
),
onPressed: () {
setState(() {
_obscureText = !_obscureText;
});
},
),
),
obscureText: _obscureText,
),
const SizedBox(
height: 20,
),
ElevatedButton(
onPressed: () {
registerUser(
firstName: firstNameController.text,
lastName: lastNameController.text,
email: emailController.text,
password: passwordController.text);
},
child: const Text(
"Register",
),
),
],
),
),
Row(
mainAxisAlignment: MainAxisAlignment.center,
children: [
Text("Already have an account?"),
SizedBox(
width: 5,
),
GestureDetector(
onTap: () {
Navigator.pushAndRemoveUntil(
context,
MaterialPageRoute(
builder: (context) => LoginScreen(),
),
(Route<dynamic> route) => false,
);
},
child: MouseRegion(
cursor: SystemMouseCursors.click,
child: Text(
"Login",
style: TextStyle(
color: Colors.purple,
decoration: TextDecoration.underline,
),
),
),
),
],
),
],
),
);
}
}
