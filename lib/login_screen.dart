import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:money_tracker/home_screen.dart';
import 'package:money_tracker/registration_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
const LoginScreen({super.key});
@override
State<LoginScreen> createState() => _LoginScreenState();
}
class _LoginScreenState extends State<LoginScreen> {
TextEditingController emailController = TextEditingController();
TextEditingController passwordController = TextEditingController();
loginUser({
required String email,
required String password,
}) {
try {
final credential = FirebaseAuth.instance
.signInWithEmailAndPassword(
email: email,
password: password,
)
.then((value) async {
Fluttertoast.showToast(msg: "Login Successful");
final SharedPreferences prefs = await SharedPreferences.getInstance();
await prefs.setBool('isLoggedIn', true);
await prefs.setString("userId", value.user?.uid ?? "");
print(value.user?.uid);
Navigator.pushAndRemoveUntil(
context,
MaterialPageRoute(
builder: (context) => HomeScreen(),
),
(Route<dynamic> route) => false,
);
});
} on FirebaseAuthException catch (e) {
Fluttertoast.showToast(msg: e.toString());
} catch (e) {
Fluttertoast.showToast(msg: e.toString());
}
}
@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
title: Padding(
padding: const EdgeInsets.only(top: 15.0),
child: Center(
child: Text("LOGIN",
style: TextStyle(
fontSize: 55,
fontWeight: FontWeight.bold,
),
),
),
),
),
body: Column(
mainAxisAlignment: MainAxisAlignment.spaceAround,
children: [
SizedBox(),
SizedBox(
width: MediaQuery.of(context).size.width * 0.7,
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
TextField(
controller: emailController,
decoration: InputDecoration(
labelText: "Enter Username",
hintText: "Enter Username",
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
labelText: "Enter Password",
hintText: "Enter Password",
labelStyle: TextStyle(fontSize: 10),
border: OutlineInputBorder(
borderRadius: BorderRadius.circular(10),
),
),
),
const SizedBox(
height: 20,
),
ElevatedButton(
onPressed: () {
loginUser(
email: emailController.text,
password: passwordController.text,
);
},
child: const Text(
"Login",
),
),
],
),
),
Row(
mainAxisAlignment: MainAxisAlignment.center,
children: [
Text("Don't have an account?"),
SizedBox(
width: 5,
),
GestureDetector(
onTap: () {
Navigator.pushAndRemoveUntil(
context,
MaterialPageRoute(
builder: (context) => RegistrationScreen(),
),
(Route<dynamic> route) => false,
);
},
child: MouseRegion(
cursor: SystemMouseCursors.click,
child: Text(
"Sign up",
style: TextStyle(
decoration: TextDecoration.underline,
color: Colors.purple,
),
),
),
),
],
)
],
),
);
}
}