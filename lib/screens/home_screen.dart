import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ecospot/mainPage.dart';
import '../cameraPage/camera_screen.dart';
import 'dart:typed_data';
import 'dart:ui' as ui; // ByteData와 ImageByteFormat를 사용하기 위한 import
import 'package:flutter/services.dart' show rootBundle;

enum PlaceCategory {
  TrashCan,
  Toilet,
  Smoke,
}

class Place {
  final String name;
  final LatLng coordinates;
  final PlaceCategory category;

  Place(this.name, this.coordinates, this.category);
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    Key? key,
  }) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String accountName = ''; // 사용자 이름을 저장할 변수
  //String accountEmail = ''; // 사용자 이메일을 저장할 변수

  Completer<GoogleMapController> _controller = Completer();

  static final CameraPosition _kGoogle = const CameraPosition(
    target: LatLng(37.583389, 127.058450),
    zoom: 16,
  );

  final List<Marker> _markers = <Marker>[];
  final List<Place> _selectedPlaces = [];

  LatLng? _selectedLocation;
  PlaceCategory _selectedCategory = PlaceCategory.TrashCan;

  Future<BitmapDescriptor> _createCustomMarkerFromAsset(String assetName,
      {double width = 8.0, double height = 8.0}) async {
    final AssetImage assetImage = AssetImage(assetName);
    final ImageConfiguration config = ImageConfiguration(
      size: Size(width, height),
    );

    final Completer<BitmapDescriptor> completer = Completer<BitmapDescriptor>();
    assetImage.resolve(config).addListener(
        ImageStreamListener((ImageInfo imageInfo, bool synchronousCall) async {
      final ByteData byteData = await imageInfo.image.toByteData(
        format: ui.ImageByteFormat.png,
      ) as ByteData;

      final Uint8List uint8List = byteData.buffer.asUint8List();
      final BitmapDescriptor bitmapDescriptor =
          BitmapDescriptor.fromBytes(uint8List);
      completer.complete(bitmapDescriptor);
    }));

    return completer.future;
  }

  Future<Position> getUserCurrentLocation() async {
    await Geolocator.requestPermission()
        .then((value) {})
        .onError((error, stackTrace) async {
      await Geolocator.requestPermission();
      print("ERROR" + error.toString());
    });
    return await Geolocator.getCurrentPosition();
  }

  void _showAddPlaceDialog() {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController nameController = TextEditingController();
        cameraInit();
        return AlertDialog(
          title: Text("Add Place"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<PlaceCategory>(
                value: _selectedCategory,
                items: PlaceCategory.values.map((category) {
                  return DropdownMenuItem<PlaceCategory>(
                    value: category,
                    child: Text(category.toString().split('.').last),
                  );
                }).toList(),
                onChanged: (category) {
                  setState(() {
                    _selectedCategory = category!;
                  });
                },
              ),
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: "Place Name"),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  String name = nameController.text;
                  if (name.isNotEmpty && _selectedLocation != null) {
                    _addPlace(name, _selectedLocation!, _selectedCategory);
                    Navigator.of(context).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CameraPage()), // 두 번째 페이지로 이동
                    );
                  }
                },
                child: Text("Add"),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _sendPlaceToServer(
      String name, LatLng location, PlaceCategory category) async {
    final apiUrl = 'http://10.0.2.2:8080'; // 실제 API 엔드포인트 URL로 변경
    final response = await http.post(
      Uri.parse(apiUrl + '/spot/addplace'), // 장소 등록 엔드포인트로 변경
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'name': name,
        'latitude': location.latitude,
        'longitude': location.longitude,
        'category': category.toString().split('.').last, // Enum 값을 문자열로 변환
      }),
    );

    if (response.statusCode == 200) {
      print('장소 등록 성공');
    } else {
      print('장소 등록 실패: ${response.statusCode}');
    }
  }

  void _addPlace(String name, LatLng location, PlaceCategory category) {
    final Place place = Place(name, location, category);
    _selectedPlaces.add(place);
    // API 통신을 통한 장소 등록
    _sendPlaceToServer(name, location, category);
    setState(() {});
  }

  void _onMapTapped(LatLng location) {
    _selectedLocation = location;
    _markers.clear();
    _markers.add(
      Marker(
        markerId: MarkerId(location.toString()),
        position: location,
        icon: BitmapDescriptor.defaultMarker,
      ),
    );
    setState(() {});
  }

  void _showPlaceMarkers() async {
    if (_selectedCategory == null) {
      return; // 카테고리가 선택되지 않았을 때는 아무 작업도 하지 않음
    }

    final apiUrl = 'http://10.0.2.2:8080'; // 실제 API 엔드포인트 URL로 변경

    // 장소 목록을 가져오는 API 호출
    final response = await http.get(
      Uri.parse(apiUrl + '/spot/places'), // 장소 목록을 가져오는 엔드포인트로 변경
    );
    if (response.statusCode == 200) {
      print('hello');
      final List<dynamic> placeList = jsonDecode(response.body);

      _markers.clear();
      _selectedPlaces.clear();

      for (final placeData in placeList) {
        final String name = placeData['name'];
        final double latitude = placeData['latitude'];
        final double longitude = placeData['longitude'];
        final PlaceCategory category =
            _getPlaceCategoryFromString(placeData['category']);

        final Place place = Place(name, LatLng(latitude, longitude), category);
        _selectedPlaces.add(place);

        if (place.category == _selectedCategory &&
            place.category == PlaceCategory.TrashCan) {
          _markers.add(
            Marker(
              markerId: MarkerId(place.coordinates.toString()),
              position: place.coordinates,
              infoWindow: InfoWindow(
                title: place.name,
              ),
              icon: await _createCustomMarkerFromAsset(
                'assets/images/trashcanIcon.png',
              ),
            ),
          );
        } else if (place.category == _selectedCategory &&
            place.category == PlaceCategory.Toilet) {
          _markers.add(
            Marker(
              markerId: MarkerId(place.coordinates.toString()),
              position: place.coordinates,
              infoWindow: InfoWindow(
                title: place.name,
              ),
              icon: await _createCustomMarkerFromAsset(
                  'assets/images/toiletIcon.png',
              )
            ),
          );
        } else if (place.category == _selectedCategory &&
            place.category == PlaceCategory.Smoke) {
          _markers.add(
            Marker(
              markerId: MarkerId(place.coordinates.toString()),
              position: place.coordinates,
              infoWindow: InfoWindow(
                title: place.name,
              ),
              icon: await _createCustomMarkerFromAsset(
                  'assets/images/smokeIcon.png',
              )
            ),
          );
        }
      }

      setState(() {});
    } else {
      print('장소 목록 가져오기 실패: ${response.statusCode}');
    }
  }

  PlaceCategory _getPlaceCategoryFromString(String categoryString) {
    if (categoryString == 'TrashCan') {
      return PlaceCategory.TrashCan;
    } else if (categoryString == 'Toilet') {
      return PlaceCategory.Toilet;
    } else if (categoryString == 'Smoke') {
      return PlaceCategory.Smoke;
    }
    return PlaceCategory.TrashCan; // 기본값
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightGreen,
        title: Text("Map"),
        actions: [],
      ),
      body: Stack(
        children: [
          Container(
            child: SafeArea(
              child: GoogleMap(
                initialCameraPosition: _kGoogle,
                markers: Set<Marker>.of(_markers),
                mapType: MapType.normal,
                myLocationEnabled: true,
                compassEnabled: true,
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                },
                onTap: (LatLng location) {
                  // 화면을 터치할 때마다 선택된 위치에 마커 표시
                  _onMapTapped(location);
                },
              ),
            ),
          ),
          Positioned(
            top: 16.0,
            right: 16.0,
            left: 16.0, // Added left spacing
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween, // Distribute buttons evenly
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedCategory = PlaceCategory.TrashCan;
                    });
                    _showPlaceMarkers();
                  },
                  child: Text("TrashCan"),
                  style: ElevatedButton.styleFrom(
                    primary: _selectedCategory == PlaceCategory.TrashCan
                        ? Colors.green // 선택된 카테고리인 경우 배경색을 초록색으로 설정
                        : Colors.grey, // 선택되지 않은 카테고리인 경우 배경색을 회색으로 설정
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    minimumSize: Size(120, 40),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedCategory = PlaceCategory.Toilet;
                    });
                    _showPlaceMarkers();
                  },
                  child: Text("Toilet"),
                  style: ElevatedButton.styleFrom(
                    primary: _selectedCategory == PlaceCategory.Toilet
                        ? Colors.green
                        : Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    minimumSize: Size(120, 40),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedCategory = PlaceCategory.Smoke;
                    });
                    _showPlaceMarkers();
                  },
                  child: Text("Smoke"),
                  style: ElevatedButton.styleFrom(
                    primary: _selectedCategory == PlaceCategory.Smoke
                        ? Colors.green
                        : Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    minimumSize: Size(120, 40),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: Color(0xFFC9C8C2),
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              currentAccountPicture: CircleAvatar(
                backgroundImage: AssetImage('assets/images/ecospotNewLogo.png'),
              ),
              accountName: Text(accountName),
              accountEmail: Text('내계정'),
              decoration: BoxDecoration(
                color: Colors.green,
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
                      builder: (context) => HomeScreen()), // 두 번째 페이지로 이동
                );
              },
            ),
            // ListTile(
            //   leading: const Icon(Icons.shopping_cart_rounded),
            //   iconColor: Colors.teal,
            //   focusColor: Color(0xFF327035),
            //   title: const Text('랭킹'),
            //   onTap: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //           builder: (context) =>
            //               HttpWithDioScreen()), // 두 번째 페이지로 이동
            //     );
            //   },
            // ),
            ListTile(
              leading: const Icon(Icons.settings),
              iconColor: Colors.teal,
              focusColor: Color(0xFF327035),
              title: const Text('로그아웃'),
              onTap: () {
                MyAppState().logout();
              },
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () async {
              getUserCurrentLocation().then((value) async {
                _markers.add(
                  Marker(
                    markerId: MarkerId("2"),
                    position: LatLng(value.latitude, value.longitude),
                    infoWindow: InfoWindow(
                      title: 'My Current Location',
                    ),
                  ),
                );

                CameraPosition cameraPosition = new CameraPosition(
                  target: LatLng(value.latitude, value.longitude),
                  zoom: 16,
                );

                final GoogleMapController controller = await _controller.future;
                controller.animateCamera(
                    CameraUpdate.newCameraPosition(cameraPosition));

                print("현재 위도: ${value.latitude}, 현재 경도: ${value.longitude}");

                setState(() {});
              });
            },
            child: Icon(Icons.location_searching),
            backgroundColor: Colors.teal,
          ),
          SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () {
              _showAddPlaceDialog();
            },
            child: Icon(Icons.add),
            backgroundColor: Colors.teal,
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: HomeScreen(),
  ));
}
