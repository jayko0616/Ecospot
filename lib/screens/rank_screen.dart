// import 'package:flutter/material.dart';
// import 'package:ecospot/screens/rank_get.dart';
// import 'package:get/get_state_manager/get_state_manager.dart';
// import 'package:url_launcher/url_launcher_string.dart';

import 'package:ecospot/mainPage.dart';
import 'package:flutter/material.dart';
import 'package:ecospot/screens/rank_get.dart';

import 'home_screen.dart';

class RankScreen extends StatelessWidget {
  final storephotos = Storephotos();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Ranking'),
          backgroundColor: Colors.lightGreen,
        ),
        body: FutureBuilder<void>(
          future: storephotos.fetchPhotos(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // 데이터가 로딩 중일 때 표시할 내용
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              // 에러 발생 시 표시할 내용
              return Text('Error: ${snapshot.error}');
            } else {
              print("성공");
              // 데이터를 성공적으로 불러왔을 때 표시할 내용
              return ListView.builder(
                controller: storephotos.scrollController,
                itemCount: storephotos.photos.length,
                itemBuilder: (context, index) {
                  final photo = storephotos.photos[index];
                  return ListTile(
                    title: Text(photo.username),
                    subtitle: Text('Rank: ${photo.ranknum}'),
                  );
                },
              );
            }
          },
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
                      MyAppState.accountName,
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      MyAppState.accountEmail,
                      style: const TextStyle(
                        fontSize: 14.0,
                      ),
                    ),
                    Text(
                      '점수: ${MyAppState.ranknum ?? 0}',
                      style: const TextStyle(
                        fontSize: 14.0,
                      ),
                    ),
                    Text(
                      '소개: ${MyAppState.message ?? ''}',
                      style: const TextStyle(
                        fontSize: 14.0,
                      ),
                    ),
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
                        builder: (context) => const HomeScreen()), // 지도 페이지로 이동
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
                  MyAppState().logout();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}