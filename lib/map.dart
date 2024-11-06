import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'marker.dart';
import 'scrollViewPage.dart';

class MapSample extends StatefulWidget {
  const MapSample({super.key});

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  GoogleMapController? _mapController;
  final MarkerController _markerController = MarkerController();

  LatLng _currentPosition = LatLng(37.7749, -122.4194); // 샌프란시스코

  @override
  void initState() {
    super.initState();
    _checkPermissionAndSetInitialLocation();
    _markerController.addListener(() {
      setState(() {}); // MarkerController의 상태 변경 시 UI 업데이트
    });
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
  void dispose() {
    _markerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('주변의 산책로를 확인하세요'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // 버튼 클릭 시 실행되는 동작
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ScrollViewPage(),
                ),
              );
            },
          ),
        ],
        backgroundColor: const Color.fromRGBO(201, 239, 203, 1),
      ),
      body: Stack(
        children: [
          // Google Map 위젯
          GoogleMap(
            onMapCreated: (controller) => _mapController = controller,
            initialCameraPosition: CameraPosition(
              target: _currentPosition,
              zoom: 14.0,
            ),
            markers: _markerController.singleMarker != null
                ? {_markerController.singleMarker!}
                : {},
            onLongPress: _markerController.addMarker, // 지도를 길게 누르면 마커 갱신
            onTap: (LatLng position) {
              _markerController.removeMarker(); // 지도를 터치하면 마커 제거
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: false, // 기본 위치 버튼 비활성화
            zoomControlsEnabled: false,
          ),
          // 애니메이션 버튼
          AnimatedSlide(
            duration: const Duration(milliseconds: 300),
            offset: _markerController.isMarkerVisible
                ? Offset(0, 0)
                : Offset(0, 1), // 버튼의 위치 조정
            curve: Curves.easeInOut,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    // 사진 업로드 버튼 클릭 시 동작
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        content: const Text("Upload photo for this location?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () {
                              // 실제 업로드 동작을 여기에 추가
                              Navigator.of(context).pop();
                            },
                            child: const Text("Upload"),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text("사진 업로드"),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _setCurrentLocation,
        child: Icon(Icons.my_location),
      ),
    );
  }
}
