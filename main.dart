import 'package:flutter/material.dart';
import 'package:ecospot/config/mySqlConnector.dart';
import 'package:ecospot/loginPage/loginMainPage.dart';

void main() {
  dbConnector();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ecospot',
      home: TokenCheck(),
    );
  }
}