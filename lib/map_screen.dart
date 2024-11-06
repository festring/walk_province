import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  Set<Marker> markers = {};

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _loadPhotos();
  }

  void _loadPhotos() async {
    FirebaseFirestore.instance.collection('photos').get().then((snapshot) {
      setState(() {
        markers.clear();
        for (var doc in snapshot.docs) {
          var data = doc.data();
          markers.add(
            Marker(
              markerId: MarkerId(doc.id),
              position:
                  LatLng(data['location'].latitude, data['location'].longitude),
              infoWindow: InfoWindow(
                title: "${data['uploader']}님이 찍은 사진입니다",
                snippet: '사진이 업로드된 위치',
              ),
            ),
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('산책로 사진 지도')),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: LatLng(37.7749, -122.4194),
          zoom: 10.0,
        ),
        markers: markers,
      ),
    );
  }
}
