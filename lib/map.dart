import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class MapSample extends StatefulWidget {
  const MapSample({super.key});

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  GoogleMapController? _mapController;

  LatLng _currentPosition = LatLng(37.7749, -122.4194); // 샌프란시스코

  @override
  void initState() {
    super.initState();
    _checkPermissionAndSetInitialLocation();
  }

  // 초기 권한 체크 및 위치 설정
  Future<void> _checkPermissionAndSetInitialLocation() async {
    if (await _requestPermission()) {
      _setCurrentLocation();
    } else {
      print('위치 권한이 거부되었습니다.');
    }
  }

  // 버튼 클릭 시 위치 설정
  Future<void> _setCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition();
      _currentPosition = LatLng(position.latitude, position.longitude);
      print(position);

      // 지도 카메라 이동
      _mapController?.animateCamera(
        CameraUpdate.newLatLng(_currentPosition),
      );
    } catch (e) {
      print('현재 위치를 가져오는 중 오류 발생: $e');
    }
  }

  Future<bool> _requestPermission() async {
    PermissionStatus status = await Permission.location.request();
    return status.isGranted;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Google Maps')),
      body: GoogleMap(
        onMapCreated: (controller) => _mapController = controller,
        initialCameraPosition: CameraPosition(
          target: _currentPosition,
          zoom: 14.0,
        ),
        myLocationEnabled: true,
        myLocationButtonEnabled: false, // 기본 위치 버튼 비활성화
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _setCurrentLocation,
        child: Icon(Icons.my_location),
      ),
    );
  }
}
