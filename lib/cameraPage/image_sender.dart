// 카메라로 찍은 사진을 mysql db에 업로드하기 위해 스프링 부트 서버로 전달하는 파일
import 'package:http/http.dart' as http;
import 'dart:io';


Future<void> uploadImage(File imageFile, double latitude, double longitude) async {
  final url = Uri.parse('http://172.20.10.2:8080/api/images'); // 업로드할 서버의 URL로 변경

  try {
    final imageBytes = await imageFile.readAsBytes();
    final response = await http.post(
      url,
      body: imageBytes,
      headers: {
        'Content-Type': 'image/jpg', // 이미지 유형에 따라 변경 (예: image/jpeg, image/png 등)
        'latitude': latitude.toString(), 'longitude': longitude.toString(),
      },
    );
    print(imageBytes);
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

