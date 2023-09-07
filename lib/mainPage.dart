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
  static int ranknum = 0;
  static String userRankName = '새싹';
  static String userRankImage = 'assets/images/sprout.png';

  static String message = '';
  static String _selectedProfileImage = 'assets/images/panda.png';
  String? userIntroduction = '';


  final TextEditingController messageController = TextEditingController();
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
          ranknum = userRank[0] ?? 0;
          message = userRank[1] ?? '';
          _selectedProfileImage = userRank[2] ?? '';
        });
      }
    }
  }

  Future<List<dynamic>?> getUserRanknum(String? username) async {
    final apiUrl =
        'http://172.20.10.2:8080/spot/pick?username=$username'; // 실제 API 엔드포인트 URL로 변경해야 함

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final dataList = json.decode(response.body);
        if (dataList.isNotEmpty) {
          print(dataList);
          final Map<String, dynamic> data = dataList;
          final int? ranknum = data['ranknum'];
          final String? message = data['message'];
          final String? _selectedProfileImage = data['image'];
          return [ranknum, message, _selectedProfileImage];
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

  String? getRankImage(int rankNum) {
    if (rankNum < 100) {
      userRankName = '새싹';
      return 'assets/images/sprout.png';
    } else if (rankNum < 200) {
      userRankName = '묘목';
      return 'assets/images/willow.png';
    } else if (rankNum < 300) {
      userRankName = '나무';
      return 'assets/images/tree.png';
    } else if (rankNum < 400) {
      userRankName = '꽃나무';
      return 'assets/images/sakura.png';
    } else {
      userRankName = '숲';
      return 'assets/images/forest.png';
    }
  }

  Future<void> NewMessage(String username, int ranknum, String message) async {
    final Map<String, dynamic> requestBody = {
      'username': username,
      'ranknum': ranknum,
      'message': message,
    };
    final response = await http.post(
      Uri.parse('http://172.20.10.2:8080/spot/updateMessage'),
      // Spring Boot API 엔드포인트 주소로 변경
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      setState(() {
        message = message;
      });
      print('Message updated successfully');
    } else {
      print('Failed to update message');
    }
  }

  Future<void> imagechange(String username, String image) async {
    final Map<String, dynamic> requestBody = {
      'username': username,
      'image': image,
    };
    final response = await http.post(
      Uri.parse('http://172.20.10.2:8080/spot/updateimage'),
      // Spring Boot API 엔드포인트 주소로 변경
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      setState(() {
        _selectedProfileImage = image;
      });
      print('Message updated successfully');
    } else {
      print('Failed to update message');
    }
  }

  Future<void> logout() async {
    final apiUrl = 'http://172.20.10.2:8080/api/auth/signout';

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

  String? stringConverter(String imgPath) {
    if (imgPath == 'assets/images/panda.png') {
      return 'panda';
    } else if (imgPath == 'assets/images/penguin.png') {
      return 'penquin';
    } else if (imgPath == 'assets/images/bear.png') {
      return 'bear';
    } else if (imgPath == 'assets/images/polarbear.png') {
      return 'polar bear';
    } else if (imgPath == 'assets/images/wolf.png') {
      return 'wolf';
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
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: [
          Container(
              margin: const EdgeInsets.all(10),
              width: 30,
              height: 25,
              child: const Text('나의 프로필 카드',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
          Card(
            margin: const EdgeInsets.all(10),
            shape: RoundedRectangleBorder(
              // 경계는 네모 모양
              borderRadius: BorderRadius.circular(16.0), // Radius는 16정도로.
            ),
            elevation: 4.0, // 그림자 깊이
            color: const Color(0xA5E5E1D4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.only(left: 15),
                child: DropdownButton<String>(
                  value: _selectedProfileImage,
                  onChanged: (String? newValue) {
                    setState(() {
                      imagechange(accountName, newValue!);
                    });
                  },
                  items: <String>[
                    'assets/images/panda.png',
                    'assets/images/penguin.png',
                    'assets/images/bear.png',
                    'assets/images/polarbear.png',
                    'assets/images/wolf.png',
                  ].map<DropdownMenuItem<String>>((String value) {
                    String imageText = stringConverter(value) ?? ' ';
                    return DropdownMenuItem<String>(
                      value: value,
                      child: SizedBox(
                        width: 50,
                        height: 15,
                        child: Text(imageText,
                          style: const TextStyle(fontSize: 14),
                          overflow: TextOverflow.visible),
                      ),
                    );
                  }).toList(),
                ),

                ),
                Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(15.0),
                  child: CircleAvatar(
                      radius: 120,
                      backgroundColor: const Color(0xFFC6FF89),
                      child: ClipOval(
                          child: Image.asset(_selectedProfileImage,
                              width: 150, height: 150, fit: BoxFit.contain))),
                ),
                const SizedBox(height: 16.0),
                Container(

                  alignment: Alignment.center,
                  padding: EdgeInsets.only(left: 20),
                  child: Column(
                    children: [
                    Text('${accountName}', style: const TextStyle(
                        color: Colors.teal,
                        fontSize: 30,
                        fontWeight: FontWeight.bold),),
                      const SizedBox(height: 10),
                    Text('${accountEmail}', style: const TextStyle(
                        color: Colors.black,
                        fontSize: 15),),
                      const SizedBox(height: 10),
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
                                    onPressed: () async {
                                      String introduction = tempIntroductionController.text;

                                      String name = accountName;
                                      int rank = ranknum;

                                      await NewMessage(name,rank, introduction);
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
                        child: Text('소개: ${message ?? ''}',
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.bold),
                        ),


                      ),
                    ],
                  )
                )
              ],
            ),
          ),
          Container(
              margin: const EdgeInsets.all(10),
              width: 30,
              height: 25,
              child: const Text('랭킹', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))
          ),
            Card(
              margin: const EdgeInsets.all(10), 
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              elevation: 4.0,
              color: const Color(0xA5E5E1D4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Image.asset('${getRankImage(ranknum)}',
                            width: 50,
                            height: 50),
                        Text('${userRankName}', style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold))
                      ]
                    ),
                  ),
                  const SizedBox(width: 50),
                  Container(
                      padding: const EdgeInsets.all(20),
                        child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${ranknum ?? 0}',
                            style: const TextStyle(fontSize: 30, color:Colors.black, fontWeight: FontWeight.bold),
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 5),
                            child: const Text('점수',
                              style: TextStyle(fontSize: 16, color: Colors.blueGrey, fontWeight: FontWeight.w400),
                            ),
                          )
                        ],
                        ),
                  ),
                ],
              )),
        ],
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
                  CircleAvatar(
                    backgroundColor: const Color(0xFFC6FF89),
                    child: ClipOval(
                      child: Image.asset(_selectedProfileImage,
                      width: 30,
                      height: 30,
                      fit: BoxFit.contain)
                    )
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
                    style: const TextStyle(
                      fontSize: 14.0,
                    ),
                  ),
                  Text(
                    '점수: ${ranknum ?? 0}',
                    style: const TextStyle(
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
                            final TextEditingController
                                tempIntroductionController =
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
                                  onPressed: () async {
                                    String introduction =
                                        tempIntroductionController.text;

                                    String name = accountName;
                                    int rank = ranknum;
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
                    child: Text('소개: ${message ?? ''}',
                      style: const TextStyle(
                      fontSize: 14.0,),)
                    ),
                  ],
                )),
            ListTile(
              leading: const Icon(Icons.home_filled),
              iconColor: Colors.teal,
              focusColor: const Color(0xFF327035),
              title: const Text('홈'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const MyAppPage()), // 메인 페이지로 이동
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
              leading: const Icon(Icons.bar_chart),
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
