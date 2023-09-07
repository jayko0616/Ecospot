// ignore_for_file: file_names, avoid_print

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthenticatedUser {
  final String username;
  final String email;

  AuthenticatedUser(this.username, this.email);
}

// 로그인
Future<AuthenticatedUser?> login(String username, String password) async {
  final apiUrl = 'http://172.20.10.2:8080';
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
    final responseData = jsonDecode(response.body);
    final username = responseData['username'];
    final email = responseData['email'];
    return AuthenticatedUser(username, email);
  } else {
    return null;
  }
}
