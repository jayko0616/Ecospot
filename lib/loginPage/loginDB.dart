// ignore_for_file: file_names, avoid_print

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// 로그인
Future<String> login(String username, String password) async {
  final apiUrl = 'http://10.0.2.2:8080';
  final response = await http.post(
    Uri.parse(apiUrl + '/api/auth/signin'),
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
