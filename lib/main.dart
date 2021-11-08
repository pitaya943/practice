// ignore_for_file: prefer_const_constructors, import_of_legacy_library_into_null_safe, prefer_final_fields, use_key_in_widget_constructors

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:practice/home_page.dart';
import 'package:practice/screens/login/edit_number.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Set default `_initialized` and `_error` state to false
  bool _initialized = false;
  bool _error = false;
  bool isLogin = false;
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  // Define an async function to initialize FlutterFire
  Future<void> initializeFlutterFire() async {
    try {
      // Wait for Firebase to initialize and set `_initialized` state to true
      await Firebase.initializeApp();
      setState(() {
        _initialized = true;
      });
      final SharedPreferences prefs = await _prefs;
      isLogin = prefs.getBool("login_state") ?? false;
      print("User login state is $isLogin");
    } catch (e) {
      print(e);
      // Set `_error` state to true if Firebase initialization fails
      setState(() {
        _error = true;
      });
    }
  }

  @override
  void initState() {
    initializeFlutterFire();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Show error message if initialization failed
    if (_error) {
      return CupertinoApp(
        home: Text("Something go wrong!!!"),
      );
    }

    // Show a loader until FlutterFire is initialized
    if (!_initialized) {
      return CupertinoApp(
        home: Text("I'm Loading!!!"),
      );
    }

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: CupertinoApp(
        // home: BulletinView(),
        home: isLogin ? HomePage() : EditNumber(),
        theme: CupertinoThemeData(
            brightness: Brightness.light, primaryColor: Colors.blue),
      ),
    );
  }
}
