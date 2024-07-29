import 'package:flutter/material.dart';
import '../../resources/assets_manager.dart';
import '../../controllers/route_manager.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EntryScreen extends StatefulWidget {
  const EntryScreen({super.key});

  @override
  State<EntryScreen> createState() => _EntryScreenState();
}

class _EntryScreenState extends State<EntryScreen> {
  // check if authenticated
  void checkIfAuthenticated() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          RouteManager.mainScreen,
          (route) => false,
        );
      } else {
        Navigator.of(context).pushNamedAndRemoveUntil(
          RouteManager.authScreen,
          (route) => false,
        );
      }
    });
  }

  @override
  void initState() {
    super.initState();
    checkIfAuthenticated();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(AssetManager.logoTransparent, width: 100),
      ),
    );
  }
}
