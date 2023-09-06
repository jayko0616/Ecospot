import 'package:flutter/material.dart';
import 'package:ecospot/loginPage/loginMainPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecospot/screens/home_screen.dart';
import 'package:ecospot/screens/rank_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MyAppPage extends StatefulWidget {
  const MyAppPage({super.key});

  @override
  State<MyAppPage> createState() => MyAppState();
}

class MyAppState extends State<MyAppPage> {
  static String accountName = '';
  static String accountEmail = '';
  static int? ranknum;
  static String message = '';
  static String _selectedProfileImage = 'assets/images/panda.png';

  final TextEditingController messageController = TextEditingController();
  String? userIntroduction = '';
  final TextEditingController introductionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

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

    String? introduction = prefs.getString('introduction');
    if (introduction != null) {
      setState(() {
        userIntroduction = introduction;
      });
    }
  }

  Future<List<dynamic>?> getUserRanknum(String? username) async {
    final apiUrl = 'http://10.0.2.2:8080/spot/pick?username=$username';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final List<dynamic> dataList = json.decode(response.body);
        if (dataList.isNotEmpty) {
          final Map<String, dynamic> data = dataList[0];
          final int? ranknum = data['ranknum'];
          final String? message = data['message'];
          return [ranknum, message];
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
    final apiUrl = 'http://10.0.2.2:8080/api/auth/signout';

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      await prefs.remove('token');
      await prefs.remove('username');
      await prefs.remove('email');
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
          // Add other app bar actions here if needed
        ],
      ),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage(_selectedProfileImage),
                  backgroundColor: Colors.lightGreenAccent,
                ),
                const SizedBox(height: 16.0),
                DropdownButton<String>(
                  value: _selectedProfileImage,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedProfileImage = newValue!;
                    });
                  },
                  items: <String>[
                    'assets/images/panda.png',
                    'assets/images/penguin.png',
                    'assets/images/bear.png',
                    'assets/images/polarbear.png',
                    'assets/images/wolf.png',
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: Image.asset(value),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${accountName}'),
                Text('${accountEmail}'),
                Text('점수: ${ranknum}'),
                Text('소개: ${message}'),
                // Add other user-related information here
              ],
            ),
          ],
        ),
      ),
      drawer: Drawer(
        backgroundColor: const Color(0xFFC9C8C2),
        child: ListView(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.green,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    backgroundImage:
                    AssetImage('assets/images/ecospotNewLogo.png'),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    '${accountName}',
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${accountEmail}',
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
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          final TextEditingController tempIntroductionController =
                          TextEditingController(text: userIntroduction);

                          return AlertDialog(
                            title: const Text('소개 편집'),
                            content: TextField(
                              controller: tempIntroductionController,
                              maxLength: 30,
                              decoration: const InputDecoration(
                                labelText: '30자 이내의 소개를 입력하세요',
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  String introduction = tempIntroductionController.text;
                                  setState(() {
                                    userIntroduction = introduction;
                                  });
                                  Navigator.of(context).pop();
                                },
                                child: const Text('확인'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('취소'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Text('소개: ${userIntroduction ?? ''}'),
                  )

                ],
              ),
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
                      builder: (context) => MyAppPage()), // 메인 페이지로 이동
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
                      builder: (context) => RankScreen()), // 랭킹 페이지로 이동
                );
              },
            ),
            // Add more drawer menu items here
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

void main() {
  runApp(MaterialApp(
    home: MyAppPage(),
  ));
}
