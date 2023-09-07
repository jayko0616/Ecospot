import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:ecospot/cameraPage/image_sender.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../screens/home_screen.dart';

late List<CameraDescription> _cameras;

Future<void> cameraInit() async {
  // 카메라 초기화 함수
  WidgetsFlutterBinding.ensureInitialized();
  _cameras = await availableCameras(); // 사용 가능한 카메라 확인
}

class CameraPage extends StatefulWidget {
  const CameraPage({Key? key}) : super(key: key);

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController controller;
  bool _isShowingConfirmationDialog = false;

  @override
  void initState() {
    super.initState();
    cameraInit();

    controller = CameraController(_cameras[0], ResolutionPreset.max);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  Future<void> _takePicture() async {
    if (!controller.value.isInitialized || _isShowingConfirmationDialog) {
      return;
    }

    try {
      final XFile file = await controller.takePicture();

      _showConfirmationDialog(file);

    } catch (e) {
      print('Error taking picture: $e');
    }
  }

  Future<void> _showConfirmationDialog(XFile imageFile) async {
    setState(() {
      _isShowingConfirmationDialog = true;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text('장소 등록'),
          content: Text('장소를 등록하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () async {

                SharedPreferences prefs = await SharedPreferences.getInstance();
                double latitude = prefs.getDouble('latitude')!;
                double longitude = prefs.getDouble('longitude')!;
                await uploadImage(File(imageFile.path),latitude,longitude);
                Navigator.of(context).pop(); // 다이얼로그 닫기

                setState(() {
                  _isShowingConfirmationDialog = false;
                });
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                  builder: (context) => HomeScreen(),
                  ),
                );

              },
              child: Text('등록'),

            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
                setState(() {
                  _isShowingConfirmationDialog = false;
                });
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                  builder: (context) => HomeScreen(),
                  ),
                );
              },
              child: Text('취소'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return Container();
    }

    return Stack(
      children: [
        Positioned.fill(
          child: CameraPreview(controller),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: GestureDetector(
              onTap: () {
                _takePicture();
              },
              child: const Icon(
                Icons.camera_enhance,
                size: 70,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
