import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shoes_shop_admin/resources/theme_manager.dart';
import 'package:shoes_shop_admin/views/splash/entry.dart';
import 'constants/color.dart';
import 'controllers/route_manager.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // ErrorWidget.builder = (FlutterErrorDetails details) => Container();

  await Firebase.initializeApp(
    options: kIsWeb || Platform.isAndroid
        ? const FirebaseOptions(
            apiKey: "AIzaSyB6NEISSUt3ExpD7E0V2OSD9Y1mA9MMQpg",
            authDomain: "shoe-shop-3ef3a.firebaseapp.com",
            projectId: "shoe-shop-3ef3a",
            storageBucket: "shoe-shop-3ef3a.appspot.com",
            messagingSenderId: "44906539150",
            appId: "1:44906539150:web:7425e0b24b12c17d9c01df",
            measurementId: "G-60RX9TK6XN")
        : null,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
      ),
    );

    EasyLoading.instance
      ..backgroundColor = primaryColor
      ..progressColor = Colors.white
      ..loadingStyle = EasyLoadingStyle.light;

    return MaterialApp(
      theme: getLightTheme(),
      title: 'Shoes Shop',
      debugShowCheckedModeBanner: false,
      home: const EntryScreen(),
      routes: routes,
      builder: EasyLoading.init(),
    );
  }
}
