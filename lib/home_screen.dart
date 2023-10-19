import 'package:app/falldetection.dart';
import 'package:app/login_screen.dart';
import 'package:app/rounded_button.dart';
import 'package:app/utils/color_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:permission_handler/permission_handler.dart';

late User loggedinUser;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _auth = FirebaseAuth.instance;

  late String number = "";
  String message1 =
      "This is an emergency signal from the position of langitude";
  String message2 = "and longitude";
  String message3 = "and also the actual address is";
  List<String> recipient = ["+60176594610"];

  String? _currentAddress;
  Position? _currentPosition;

  CollectionReference users = FirebaseFirestore.instance.collection('Users');

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }

  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();

    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      setState(() => _currentPosition = position);
      _getAddressFromLatLng(_currentPosition!);
    }).catchError((e) {
      debugPrint(e);
    });
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    await placemarkFromCoordinates(
            _currentPosition!.latitude, _currentPosition!.longitude)
        .then((List<Placemark> placemarks) {
      Placemark place = placemarks[0];
      setState(() {
        _currentAddress =
            '${place.street}, ${place.subLocality}, ${place.subAdministrativeArea}, ${place.postalCode}';
      });
      _fetch2(position, _currentAddress!);
    }).catchError((e) {
      debugPrint(e);
    });
  }

  void initState() {
    super.initState();
    getCurrentUser();
  }

  //using this function you can use the credentials of the user
  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser;
      if (user != null) {
        loggedinUser = user;
      }
    } catch (e) {
      print(e);
    }
  }

  void _sendSMS(String message1, String message2, String message3,
      List<String> number, String address, Position position) async {
    var status = await Permission.sms.status;
    String longitude = position.longitude.toString();
    String latitude = position.latitude.toString();
    //if (status.isGranted) {
    String _result = await sendSMS(
            message:
                '$message1 $longitude $message2 $latitude $message3 $address',
            recipients: number,
            sendDirect: true)
        .catchError((onError) {
      print(onError);
    });
    print(_result);
    //}
  }

  _fetch1() async {
    final firebaseUser = await FirebaseAuth.instance.currentUser!;
    if(firebaseUser !=null){
      await FirebaseFirestore.instance.collection('Users').doc(firebaseUser.uid)
          .get().then((ds) {
        number = ds.data()!["phoneNumber"];
      });
      await FlutterPhoneDirectCaller.callNumber(number);
    }
  }

  _fetch2(Position position, String _currentaddress) async {
    final firebaseUser = await FirebaseAuth.instance.currentUser!;
    if(firebaseUser !=null){
      await FirebaseFirestore.instance.collection('Users').doc(firebaseUser.uid)
          .get().then((ds) {
        number = ds.data()!["phoneNumber"];
      });
      recipient[0] = number;
      _sendSMS(message1, message2, message3, recipient, _currentAddress ?? "a",
          position);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset : false,
        appBar: AppBar(
          leading: null,
          automaticallyImplyLeading: false,
          actions: <Widget>[
            IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () {
                  _auth.signOut();
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => LoginScreen()));

                  //Implement logout functionality
                }),
          ],
          title: const Text('Home Page'),
          backgroundColor: Colors.redAccent,
        ),
        body: Container(
          decoration: const BoxDecoration(
              //change the gradient color by color hrtml code
              //in hexStringColor
              color: Colors.white
              ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(70, 0, 70, 40),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Text(
                "Welcome User",
                style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold), textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 80.0,
              ),
              const Icon(Icons.phone_android_rounded,
                  size: 40,
                  color: Colors.red
              ),
              RoundedButton(colour: Colors.red, title: "Call Emergency Contact", onPressed: () async {
                _fetch1();
              }),
              const SizedBox(
                height: 40.0,
              ),
              Text('LAT: ${_currentPosition?.latitude ?? ""}', style: const TextStyle(fontSize: 15)),
              Text('LNG: ${_currentPosition?.longitude ?? ""}', style: const TextStyle(fontSize: 15)),
              Text('ADDRESS: ${_currentAddress ?? ""}', style: const TextStyle(fontSize: 15)),
              const SizedBox(height: 12),
              const Icon(Icons.location_on,
                  size: 40,
                  color: Colors.deepOrangeAccent,
              ),
              RoundedButton(
                colour: Colors.deepOrangeAccent,
                title: 'Send Current Location',
                onPressed: () {
                  _getCurrentPosition();
                },
              ),
              const SizedBox(
                height: 20.0,
              ),
              const Icon(Icons.sensors,
                  size: 40,
                  color: Colors.orange
              ),
              RoundedButton(
                  colour: Colors.orange,
                  title: 'Fall Detection',
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => const MyHomePage()));

                    //Implement logout functionality
                  }),
            ],
          ),
          ),
        ));
  }
}
