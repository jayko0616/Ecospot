// // import 'package:flutter/material.dart';

// // class RankPage extends StatelessWidget {
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: Text('랭킹'),
// //       ),
// //       body: Center(
// //         child: Text('랭크페이지'),
// //       ),
// //     );
// //   }
// // }
// import 'package:flutter/material.dart';
// import 'package:ecospot/screens/rank_get.dart';
// import 'package:get/get_state_manager/get_state_manager.dart';
// import 'package:url_launcher/url_launcher_string.dart';

// class HttpWithDioScreen extends StatelessWidget {
//   const HttpWithDioScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<HttpWithDioGetx>(
//         init: HttpWithDioGetx()..started(),
//         builder: (controller) {
//           return Scaffold(
//             appBar: AppBar(
//               title: Text('Ranking'),
//               backgroundColor: Color(0xFF8BC34A),
//             ),
//             body: ListView.builder(
//                 controller: controller.scrollController,
//                 itemCount: controller.photos.length,
//                 itemBuilder: ((context, index) {
//                   return Padding(
//                     padding:
//                         const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
//                     child: Column(
//                       children: [
//                         SizedBox(
//                           child: Row(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               SizedBox(
//                                 width: MediaQuery.of(context).size.width * 0.2,
//                                 height: MediaQuery.of(context).size.width * 0.2,
//                                 child: ClipRRect(
//                                   borderRadius: BorderRadius.circular(12),
//                                   child: Image.network(
//                                     controller.photos[index].downloadUrl,
//                                     fit: BoxFit.cover,
//                                     frameBuilder: (BuildContext context,
//                                         Widget child,
//                                         int? frame,
//                                         bool wasSynchronouslyLoaded) {
//                                       return Container(
//                                         decoration: BoxDecoration(
//                                           borderRadius:
//                                               BorderRadius.circular(12),
//                                           color: const Color.fromRGBO(
//                                               91, 91, 91, 1),
//                                         ),
//                                         child: child,
//                                       );
//                                     },
//                                     loadingBuilder: (BuildContext context,
//                                         Widget child,
//                                         ImageChunkEvent? loadingProgress) {
//                                       if (loadingProgress == null) {
//                                         return child;
//                                       }
//                                       return Container(
//                                         decoration: BoxDecoration(
//                                           borderRadius:
//                                               BorderRadius.circular(12),
//                                           color: const Color.fromRGBO(
//                                               91, 91, 91, 1),
//                                         ),
//                                         child: const Center(
//                                           child: CircularProgressIndicator(
//                                             color: Colors.amber,
//                                           ),
//                                         ),
//                                       );
//                                     },
//                                   ),
//                                 ),
//                               ),
//                               const SizedBox(width: 12),
//                               Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   _content(
//                                       url: controller.photos[index].url,
//                                       title: "ID : ",
//                                       content: controller.photos[index].id),
//                                   _content(
//                                       url: controller.photos[index].url,
//                                       title: "Author : ",
//                                       content: controller.photos[index].author),
//                                   _content(
//                                       url: controller.photos[index].url,
//                                       title: "Width : ",
//                                       content:
//                                           "${controller.photos[index].width}"),
//                                   _content(
//                                       url: controller.photos[index].url,
//                                       title: "Height : ",
//                                       content:
//                                           "${controller.photos[index].height}"),
//                                 ],
//                               )
//                             ],
//                           ),
//                         ),
//                         if (controller.photos.length - 1 == index &&
//                             controller.isAdd) ...[
//                           const SizedBox(
//                             height: 100,
//                             child: Center(
//                                 child: CircularProgressIndicator(
//                               color: Colors.deepOrange,
//                             )),
//                           ),
//                         ],
//                       ],
//                     ),
//                   );
//                 })),
//           );
//         });
//   }

//   GestureDetector _content({
//     required String title,
//     required String content,
//     required String url,
//   }) {
//     return GestureDetector(
//       onTap: () async {
//         if (await canLaunchUrlString(url)) {
//           await launchUrlString(url, mode: LaunchMode.externalApplication);
//         }
//       },
//       child: Row(
//         children: [
//           Text(
//             title,
//             style: const TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           Text(
//             content,
//             style: const TextStyle(
//                 fontSize: 14, color: Color.fromRGBO(215, 215, 215, 1)),
//           ),
//         ],
//       ),
//     );
//   }
// }
