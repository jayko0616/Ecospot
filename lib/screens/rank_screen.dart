import 'package:flutter/material.dart';
import 'package:ecospot/screens/rank_get.dart';

import '../mainPage.dart';
import 'home_screen.dart';

class RankScreen extends StatelessWidget {
  final storephotos = Storephotos();

  @override
  Widget build(BuildContext context) {
    // 랭킹 순위를 계산하여 리스트에 추가
    storephotos.photos.sort((a, b) => b.ranknum.compareTo(a.ranknum));

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
              // 데이터를 성공적으로 불러왔을 때 표시할 내용
              return ListView.builder(
                controller: storephotos.scrollController,
                itemCount: storephotos.photos.length,
                itemBuilder: (context, index) {
                  final photo = storephotos.photos[index];
                  final rank = index + 1;
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[300], // 흰색과 회색 중간색
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: ListTile(
                        title: Row(
                          children: [
                            Container(
                              width: 30.0,
                              height: 30.0,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.lightGreen,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                rank.toString(),
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            SizedBox(width: 10.0), // 간격 조절
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    photo.username,
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.0,
                                    ),
                                  ),
                                  Text(
                                    'ID: ${photo.username}',
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      color: Colors.black,
                                    ),
                                  ),
                                  if (photo.message != null && photo.message.isNotEmpty)
                                    Container(
                                      margin: EdgeInsets.symmetric(vertical: 8.0),
                                      padding: EdgeInsets.all(10.0),
                                      decoration: BoxDecoration(
                                        color: Colors.white38,
                                        borderRadius: BorderRadius.circular(10.0),
                                      ),
                                      child: Text(
                                        'Message: ${photo.message}',
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                          fontSize: 14.0,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Text(
                                'Score: ${photo.ranknum}',
                                textAlign: TextAlign.end,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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
                      builder: (context) => const MyAppPage(),
                    ),
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
                      builder: (context) => const HomeScreen(),
                    ),
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
                      builder: (context) => RankScreen(),
                    ),
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
