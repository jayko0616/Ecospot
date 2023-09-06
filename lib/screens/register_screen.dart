import 'package:flutter/material.dart';

import '../cameraPage/camera_screen.dart';

class RegisterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightGreen,
        title: Text('등록'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('새로운 장소 등록'),
            SizedBox(
                height:
                    20), // Adding some space between the text and the button
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.teal),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CameraPage()), // 두 번째 페이지로 이동
                );
              },
              child: Text('촬영'),
            ),
          ],
        ),
      ),
    );
  }
}
