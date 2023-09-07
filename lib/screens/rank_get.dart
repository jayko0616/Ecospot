import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PiscumPhotoModel {
  final String username;
  final int ranknum;
  final String message;

  PiscumPhotoModel(this.username, this.ranknum, this.message);
}

class Storephotos {
  ScrollController scrollController = ScrollController();
  List<PiscumPhotoModel> photos = [];

  Future<void> fetchPhotos() async {
    final apiUrl = 'http://172.20.10.2:8080/spot/load'; // API 엔드포인트를 여기에 입력하세요.

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final List<PiscumPhotoModel> fetchedPhotos = data
            .map((item) => PiscumPhotoModel(
          item['username'],
          item['ranknum'],
          item['message']?? '',
        ))
            .toList();

        // ranknum을 기준으로 내림차순 정렬
        fetchedPhotos.sort((a, b) => b.ranknum.compareTo(a.ranknum));

        // photos 리스트에 저장
        photos = fetchedPhotos;

        // 데이터가 업데이트되었음을 알려줌
        scrollController.notifyListeners();
      } else {
        // 에러 처리
        throw Exception('Failed to load photos');
      }
    } catch (error) {
      // 예외 처리
      print('Error: $error');
    }
  }
}

