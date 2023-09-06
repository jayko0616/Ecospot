// import 'package:flutter/material.dart';
// import 'package:ecospot/screens/rank_get.dart';
// import 'package:get/get_state_manager/get_state_manager.dart';
// import 'package:url_launcher/url_launcher_string.dart';

import 'package:flutter/material.dart';
import 'package:ecospot/screens/rank_get.dart';

class RankScreen extends StatelessWidget {
  final storephotos = Storephotos();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Ranking'),
        ),
        body: FutureBuilder<void>(
          future: storephotos.fetchPhotos(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // 데이터가 로딩 중일 때 표시할 내용
              return CircularProgressIndicator();
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
      ),
    );
  }
}