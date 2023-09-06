// 카메라로 찍은 사진을 mysql db에 업로드하기 위해 스프링 부트 서버로 전달하는 파일
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path/path.dart';

Future<void> uploadImage(File imageFile) async {
  final url = Uri.parse(
      'http://10.0.2.2:8080/api/images'); //('http://172.20.10.2:8080/api/images'); // 업로드할 서버의 URL로 변경

  // 이미지 파일을 읽어 MultipartFile로 변환
  final imageStream = http.ByteStream(imageFile.openRead());
  final imageLength = await imageFile.length();
  final imageUploadRequest = http.MultipartRequest('POST', url)
    ..files.add(http.MultipartFile(
      'image', // 서버에서 사용할 필드 이름 (이름을 서버에 맞게 변경)
      imageStream,
      imageLength,
      filename: basename(imageFile.path),
    ));
  print("d");
  print(imageStream);
  print(imageLength);
  print(imageUploadRequest);
  print("ww");
  try {
    final streamedResponse = await imageUploadRequest.send();
    final response = await http.Response.fromStream(streamedResponse);
    print(imageFile);
    print("gg");
    if (response.statusCode == 200) {
      // 이미지 업로드 성공
      print('Image uploaded successfully');
    } else {
      // 이미지 업로드 실패
      print('Image upload failed with status code ${response.statusCode}');
    }
  } catch (e) {
    print('Error uploading image: $e');
  }
}
