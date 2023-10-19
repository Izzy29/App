import 'package:app/net/firebase.dart';
import 'package:app/utils/color_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'rounded_button.dart';

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _auth = FirebaseAuth.instance;
  final username = TextEditingController();
  final email = TextEditingController();
  final password =TextEditingController();
  final emergencyContact = TextEditingController();
  bool showSpinner = false;

  Future addUserDetails(String username, String phoneNumber, String email) async {
    await FirebaseFirestore.instance.collection('Users').add({
      'username': username,
      'phone_number': phoneNumber,
      'email': email
    });
  }

  Future signUp() async {
      try {
        final newUser = await _auth.createUserWithEmailAndPassword(
            email: email.text.trim(), password: password.text.trim());
        //addUserDetails(username.text.trim(), emergencyContact.text.trim(), email.text.trim());
        userSetup(username.text.trim(), emergencyContact.text.trim());
        if (newUser != null) {
          Navigator.pushNamed(context, 'home_screen');
        }
      } catch (e) {
        print(e);
      }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset : false,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Sign Up",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          //change the gradient color by color html code
          //in hexStringColor
            gradient: LinearGradient(colors: [
              hexStringColor("ff0000"),
              hexStringColor("ff9933"),
              hexStringColor("ffcc00")
            ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        child: ModalProgressHUD(
          inAsyncCall: showSpinner,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TextField(
              controller: username,
                  cursorColor: Colors.white,
                  style: TextStyle(color: Colors.white.withOpacity(0.9)),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.people_outlined,
                      color: Colors.white70,
                    ),
                    labelText: "Enter username",
                    labelStyle: TextStyle(color: Colors.white.withOpacity(0.9)),
                    filled: true,
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    fillColor: Colors.white.withOpacity(0.3),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: const BorderSide(width: 0, style: BorderStyle.none)),
                  ),),
                const SizedBox(
                  height: 30.0,
                ),
                TextField(
                  controller: email,
                  style: TextStyle(color: Colors.white.withOpacity(0.9)),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.email_outlined,
                      color: Colors.white70,
                    ),
                    labelText: "Enter email",
                    labelStyle: TextStyle(color: Colors.white.withOpacity(0.9)),
                    filled: true,
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    fillColor: Colors.white.withOpacity(0.3),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: const BorderSide(width: 0, style: BorderStyle.none)),
                  ),),
                const SizedBox(
                  height: 30.0,
                ),
                TextField(
                  controller: password,
                  style: TextStyle(color: Colors.white.withOpacity(0.9)),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.lock_outlined,
                      color: Colors.white70,
                    ),
                    labelText: "Enter password",
                    labelStyle: TextStyle(color: Colors.white.withOpacity(0.9)),
                    filled: true,
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    fillColor: Colors.white.withOpacity(0.3),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: const BorderSide(width: 0, style: BorderStyle.none)),
                  ),),
                const SizedBox(
                  height: 30.0,
                ),
                TextField(
                  controller: emergencyContact,
                    style: TextStyle(color: Colors.white.withOpacity(0.9)),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.contact_phone_outlined,
                      color: Colors.white70,
                    ),
                    labelText: "Enter emergency contact number",
                    labelStyle: TextStyle(color: Colors.white.withOpacity(0.9)),
                    filled: true,
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    fillColor: Colors.white.withOpacity(0.3),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: const BorderSide(width: 0, style: BorderStyle.none)),
                  ),),

                const SizedBox(
                  height: 30.0,
                ),
                RoundedButton(
                  colour: Colors.blueGrey,
                  title: 'Register',
                  onPressed: () async {
                    setState(() {
                      showSpinner = true;
                    });
                    signUp();
                    setState(() {
                      showSpinner = false;
                    });
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}