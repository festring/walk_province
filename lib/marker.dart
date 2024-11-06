// marker.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MarkerController extends ChangeNotifier {
  Marker? _singleMarker;
  bool _isMarkerVisible = false;

  Marker? get singleMarker => _singleMarker;
  bool get isMarkerVisible => _isMarkerVisible;

  // 마커를 추가하는 함수
  void addMarker(LatLng position) {
    _singleMarker = Marker(
      markerId: const MarkerId('single_marker'), // 하나의 고유 ID 사용
      position: position,
      infoWindow: const InfoWindow(
        title: 'Pinned Location',
        snippet: 'You pinned this location',
      ),
      icon: BitmapDescriptor.defaultMarker,
    );
    _isMarkerVisible = true;
    notifyListeners();
  }

  // 마커를 제거하는 함수
  void removeMarker() {
    _singleMarker = null;
    _isMarkerVisible = false;
    notifyListeners();
  }
}
