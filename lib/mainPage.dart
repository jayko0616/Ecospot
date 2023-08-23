// ignore_for_file: use_build_context_synchronously, file_names

import 'package:ecospot/config/dbInfo.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ecospot/loginPage/loginMainPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecospot/config/mySqlConnector.dart';
import 'package:ecospot/screens/home_screen.dart';
import 'package:ecospot/screens/register_screen.dart';
import 'package:ecospot/screens/rank_screen.dart';

// 기본 홈
class MyAppPage extends StatefulWidget {
  const MyAppPage({super.key});

  @override
  State<MyAppPage> createState() => MyAppState();
}

class MyAppState extends State<MyAppPage> {
  String accountName = ''; // 사용자 이름을 저장할 변수
  //String accountEmail = ''; // 사용자 이메일을 저장할 변수
  @override
  void initState() {
    super.initState();
    // 앱이 시작될 때 사용자 정보를 가져오는 작업을 수행
    loadUserData();
  }

  // 사용자 정보를 가져오는 함수
  void loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String name =
        prefs.getString('name') ?? ''; // 'name'은 데이터베이스에서 사용자 이름을 저장한 키
    //String email = prefs.getString('email') ?? ''; // 'email'은 데이터베이스에서 사용자 이메일을 저장한 키

    setState(() {
      accountName = name;
      //accountEmail = email;
    });
  }

  void showAlertDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('알림'),
          content: Text('로그아웃하시겠습니까?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('아니오'),
            ),
            TextButton(
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.remove('token');
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginMainPage(),
                  ),
                );
              },
              child: Text('예'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Eco Spot'),
        centerTitle: true,
        elevation: 0.0,
        actions: [
          IconButton(
            onPressed: () {
              //지도 위치 검색
            },
            icon: Icon(Icons.search),
          ),
          IconButton(
            onPressed: () {
              //내정보 가져오기
            },
            icon: Icon(Icons.person),
          )
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              currentAccountPicture: CircleAvatar(
                backgroundImage: AssetImage('assets/images/ecospotlogo.jpg'),
              ),
              accountName: Text(DbInfo.userName),
              accountEmail: Text('내계정'),
            ),
            ListTile(
              leading: Icon(Icons.home),
              iconColor: Colors.purple,
              focusColor: Colors.purple,
              title: Text('홈'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => HomePage()), // 두 번째 페이지로 이동
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.shopping_cart_rounded),
              iconColor: Colors.purple,
              focusColor: Colors.purple,
              title: Text('랭킹'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          HttpWithDioScreen()), // 두 번째 페이지로 이동
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.restore_from_trash),
              iconColor: Colors.purple,
              focusColor: Colors.purple,
              title: Text('새로운 장소 등록'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => RegisterPage()), // 두 번째 페이지로 이동
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              iconColor: Colors.purple,
              focusColor: Colors.purple,
              title: Text('로그아웃'),
              onTap: () {
                showAlertDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
