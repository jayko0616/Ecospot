// ignore_for_file: file_names, avoid_print

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// 로그인
Future<String> login(String username, String password) async {
  final apiUrl = 'http://localhost:8080'; // 실제 API 엔드포인트 URL로 변경해야 함
  final response = await http.post(
    Uri.parse(apiUrl + '/api/auth/signin'), // 로그인 엔드포인트로 변경
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'username': username,
      'password': password,
    }),
  );

  if (response.statusCode == 200) {
    return '1';
  } else {
    return '-1';
  }
}
