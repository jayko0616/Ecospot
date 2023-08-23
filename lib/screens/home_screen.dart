import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('메인 홈'),
      ),
      body: Center(
        child: Text('This is the second page.'),
      ),
    );
  }
}
