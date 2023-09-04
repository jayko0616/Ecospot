// 카메라로 찍은 사진을 mysql db에 업로드하기 위해 스프링 부트 서버로 전달하는 파일
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:io';

Future<void> uploadImage(XFile imageFile) async {
  final url = Uri.parse('http://your-server-url/upload'); // 스프링 부트 서버 엔드포인트 URL

  List<int> imageBytes = await imageFile.readAsBytes();

  var request = http.MultipartRequest('POST', url);
  request.files.add(
    http.MultipartFile(
      'image',
      imageFile.readAsBytes().asStream(),
      imageBytes.length,
      filename: 'image.jpg',
    ),
  );

  var response = await request.send();

  if (response.statusCode == 200) {
    // 업로드 성공
    print('Image uploaded successfully');
  } else {
    // 업로드 실패
    print('Image upload failed');
  }
}