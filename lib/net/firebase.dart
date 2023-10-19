import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> userSetup(String username, String phoneNumber) async{
  var firebaseUser = await FirebaseAuth.instance.currentUser!;
  CollectionReference users = FirebaseFirestore.instance.collection('Users');
  FirebaseFirestore.instance.collection('Users').doc(firebaseUser.uid). set({
    'username': username,
    'phoneNumber': phoneNumber
  });
  return;
}