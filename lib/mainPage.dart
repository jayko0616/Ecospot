// ignore_for_file: use_build_context_synchronously, file_names

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ecospot/loginPage/loginMainPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'communityPage/communityMainPage.dart';
import 'memoPage/memoMainPage.dart';
import 'myInfoPage/myInfoMainPage.dart';
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
            onPressed: () {},
            icon: Icon(Icons.search),
          ),
          IconButton(
            onPressed: () {},
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
              accountName: Text('내이름'),
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
                      builder: (context) => RankPage()), // 두 번째 페이지로 이동
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
