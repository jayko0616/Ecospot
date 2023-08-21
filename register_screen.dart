import 'package:flutter/material.dart';

import '../cameraPage/camera_screen.dart';

class RegisterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('새로운 장소 등록'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('카메라 기능 추가하고 이것저것 하는곳 뺑이 ㄱ'),
            SizedBox(height: 20),  // Adding some space between the text and the button
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CameraPage()),
                );
              },
              child: Text('버튼'),
            ),
          ],
        ),
      ),
    );
  }
}
