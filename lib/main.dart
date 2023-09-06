import 'package:ecospot/screens/home_screen.dart';
import 'package:ecospot/screens/rank_screen.dart';
import 'package:flutter/material.dart';
import 'package:ecospot/loginPage/loginMainPage.dart';
import 'package:dio/dio.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EcoSpot',
      home: TokenCheck(),
    );
  }
}

/*

 */
