import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Completer<GoogleMapController> _controller = Completer();

  static final CameraPosition _kGoogle = const CameraPosition(
    target: LatLng(37.583389, 127.058450),
    zoom: 16,
  );

  final List<Marker> _markers = <Marker>[];
  final List<Place> _selectedPlaces = [];

  LatLng? _selectedLocation;
  PlaceCategory _selectedCategory = PlaceCategory.TrashCan;

  Future<Position> getUserCurrentLocation() async {
    await Geolocator.requestPermission().then((value) {}).onError((error, stackTrace) async {
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

  void _addPlace(String name, LatLng location, PlaceCategory category) {
    final Place place = Place(name, location, category);
    _selectedPlaces.add(place);
    setState(() {});
  }

  void _onMapTapped(LatLng location) {
    _selectedLocation = location;
    _markers.clear();
    _markers.add(
      Marker(
        markerId: MarkerId(location.toString()),
        position: location,
      ),
    );
    setState(() {});
  }

  void _showPlaceMarkers() {
    _markers.clear();
    for (final place in _selectedPlaces) {
      if (place.category == _selectedCategory) {
        _markers.add(
          Marker(
            markerId: MarkerId(place.coordinates.toString()),
            position: place.coordinates,
            infoWindow: InfoWindow(
              title: place.name,
            ),
          ),
        );
      }
    }
    setState(() {});
  }

  void _showPlaceList() {
    final List<Place> categoryPlaces = _selectedPlaces
        .where((place) => place.category == _selectedCategory)
        .toList();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              title: Text("${_selectedCategory.toString().split('.').last} List"),
            ),
            body: ListView.builder(
              itemCount: categoryPlaces.length,
              itemBuilder: (context, index) {
                final place = categoryPlaces[index];
                return ListTile(
                  title: Text(place.name),
                );
              },
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF0F9D58),
        title: Text("Map"),
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
                onTap: _onMapTapped,
              ),
            ),
          ),
          Positioned(
            top: 16.0,
            right: 16.0,
            left: 16.0, // Added left spacing
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // Distribute buttons evenly
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedCategory = PlaceCategory.TrashCan;
                    });
                    _showPlaceMarkers();
                  },
                  child: Text("TrashCan"),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedCategory = PlaceCategory.Toilet;
                    });
                    _showPlaceMarkers();
                  },
                  child: Text("Toilet"),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedCategory = PlaceCategory.Smoke;
                    });
                    _showPlaceMarkers();
                  },
                  child: Text("Smoke"),
                ),
              ],
            ),
          ),
        ],
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
                  zoom: 17,
                );

                final GoogleMapController controller = await _controller.future;
                controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

                print("현재 위도: ${value.latitude}, 현재 경도: ${value.longitude}");

                setState(() {});
              });
            },
            child: Icon(Icons.location_searching),
          ),
          SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () {
              _showAddPlaceDialog();
            },
            child: Icon(Icons.add),
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
