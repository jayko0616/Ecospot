// ignore_for_file: use_build_context_synchronously, file_names

import 'package:flutter/material.dart';
import 'package:ecospot/loginPage/loginMainPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecospot/screens/home_screen.dart';
import 'package:ecospot/screens/rank_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// 기본 홈
class MyAppPage extends StatefulWidget {
  const MyAppPage({super.key});

  @override
  State<MyAppPage> createState() => MyAppState();
}

class MyAppState extends State<MyAppPage> {
  static String accountName = ''; // 사용자 이름을 저장할 변수
  static String accountEmail = ''; // 사용자 이메일을 저장할 변수
  int? ranknum;
  String message = '';

  @override
  void initState() {
    super.initState();
    // 앱이 시작될 때 사용자 정보를 가져오는 작업을 수행
    loadUserData();
  }

  // 사용자 정보를 가져오고 ranknum을 가져오는 함수
  void loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');
    String? email = prefs.getString('email');

    setState(() {
      accountName = username ?? '';
      accountEmail = email ?? '';
    });

    if (username != null) {
      List<dynamic>? userRank = await getUserRanknum(username);
      if (userRank != null) {
        setState(() {
          ranknum = userRank[0];
          message = userRank[1] ?? '';
        });
      }
    }
  }

  Future<List<dynamic>?> getUserRanknum(String? username) async {
    final apiUrl = 'http://10.0.2.2:8080/spot/pick?username=$username'; // 실제 API 엔드포인트 URL로 변경해야 함

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final List<dynamic> dataList = json.decode(response.body);
        if (dataList.isNotEmpty) {
          print(dataList);
          final Map<String, dynamic> data = dataList[0];
          final int? ranknum = data['ranknum'];
          final String? message = data['message'];
          return [ranknum,message];
        } else {
          print('Empty data list received.');
          return null;
        }
      } else {
        print('Failed to fetch user ranknum.');
        return null;
      }
    } catch (error) {
      print('Error: $error');
      return null;
    }
  }


  Future<void> logout() async {
    final apiUrl =
        'http://10.0.2.2:8080/api/auth/signout'; // 실제 로그아웃 API 엔드포인트 URL로 변경해야 함

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Authorization': 'Bearer $token', // 토큰을 헤더에 추가
      },
    );

    if (response.statusCode == 200) {
      await prefs.remove('token'); // 토큰 삭제
      await prefs.remove('username'); // 토큰 삭제
      await prefs.remove('email'); // 토큰 삭제
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginMainPage()),
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('오류'),
            content: const Text('로그아웃 중에 문제가 발생했습니다.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('확인'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFC9C8C2),
      appBar: AppBar(
        title: const Text('Eco Spot'),
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: Colors.lightGreen,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),
              );
            },
            icon: const Icon(Icons.search),
          ),
          IconButton(
            onPressed: () {
              // 내정보 가져오기
            },
            icon: const Icon(Icons.person),
          )
        ],
      ),
      body: const Center(),
      drawer: Drawer(
        backgroundColor: Color(0xFFC9C8C2),
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              currentAccountPicture: const CircleAvatar(
                backgroundImage: AssetImage('assets/images/ecospotNewLogo.png'),
              ),
              accountName: Text('Account Name: $accountName'),
              accountEmail: Text('Account Email: $accountEmail'),
              decoration: const BoxDecoration(
                color: Colors.green,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundImage:
                        AssetImage('assets/images/ecospotNewLogo.png'),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    '$accountName',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '$accountEmail',
                    style: TextStyle(
                      fontSize: 14.0,
                    ),
                  ),
                  Text(
                    '점수: ${ranknum ?? 0}',
                    style: TextStyle(
                      fontSize: 14.0,
                    ),
                  ),
                  Text(
                    '소개: ${message ?? ''}',
                    style: TextStyle(
                      fontSize: 14.0,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              iconColor: Colors.teal,
              focusColor: Color(0xFF327035),
              title: const Text('홈'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MyAppPage()), // 두 번째 페이지로 이동
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.home_filled),
              iconColor: Colors.teal,
              focusColor: const Color(0xFF327035),
              title: const Text('홈'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MyAppPage()), // 지도 페이지로 이동
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.map_outlined),
              iconColor: Colors.teal,
              focusColor: const Color(0xFF327035),
              title: const Text('지도'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => HomeScreen()), // 지도 페이지로 이동
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_cart_rounded),
              iconColor: Colors.teal,
              focusColor: const Color(0xFF327035),
              title: const Text('랭킹'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          RankScreen()), // 랭킹 페이지로 이동
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              iconColor: Colors.teal,
              focusColor: const Color(0xFF327035),
              title: const Text('로그아웃'),
              onTap: () {
                logout();
              },
            ),
          ],
        ),
      ),
    );
  }
}
