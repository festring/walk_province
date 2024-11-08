import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'marker.dart';
import 'scrollViewPage.dart';
import 'debounce_timer.dart';

// 지도 화면을 구성하는 위젯 클래스 정의
class MapSample extends StatefulWidget {
  const MapSample({super.key});

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  GoogleMapController? _mapController; // 지도 컨트롤러를 관리하는 변수
  final MarkerController _markerController =
      MarkerController(); // 마커를 관리하는 컨트롤러 인스턴스
  final DebounceTimer _debounceTimer =
      DebounceTimer(); // 일정 시간 동안 이벤트를 제어하기 위한 디바운스 타이머 인스턴스 생성

  LatLng _currentPosition = LatLng(37.7749, -122.4194); // 초기 위치는 샌프란시스코로 설정
  List<Rect> _rectangles = []; // 사각형 리스트

  @override
  void initState() {
    super.initState();
    _checkPermissionAndSetInitialLocation(); // 권한 체크 및 초기 위치 설정 메서드 호출
    _debounceTimer.startDebounce((LatLngBounds bounds) {
      debugPrint('현재 화면 범위 좌표:');
      debugPrint('Southwest: ${bounds.southwest}');
      debugPrint('Northeast: ${bounds.northeast}');
      _drawRectangles(bounds);
    });
    _markerController.addListener(() {
      setState(() {});
    });
  }

  // 위치 권한 체크 및 초기 위치 설정 메서드
  Future<void> _checkPermissionAndSetInitialLocation() async {
    if (await _requestPermission()) {
      _setCurrentLocation();
    } else {
      debugPrint('위치 권한이 거부되었습니다.');
    }
  }

  // 위치 버튼 클릭 시 현재 위치로 설정하는 메서드
  Future<void> _setCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition();
      _currentPosition = LatLng(position.latitude, position.longitude);
      print(position);
      _mapController?.animateCamera(
        CameraUpdate.newLatLng(_currentPosition),
      );
    } catch (e) {
      debugPrint('현재 위치를 가져오는 중 오류 발생: $e');
    }
  }

  // 위치 권한 요청 메서드
  Future<bool> _requestPermission() async {
    PermissionStatus status = await Permission.location.request();
    return status.isGranted;
  }

  // 화면 범위에 따라 사각형 좌표 생성 및 배치
  void _drawRectangles(LatLngBounds bounds) {
    setState(() {
      _rectangles.clear(); // 기존 사각형 제거
      List<LatLng> points = [
        LatLng(bounds.southwest.latitude, bounds.southwest.longitude),
        LatLng(bounds.northeast.latitude, bounds.northeast.longitude),
        // 다른 좌표 추가 필요 시 추가
      ];
      for (LatLng point in points) {
        // 화면 크기와 겹침 여부 계산 로직 추가 필요
        // 예시: 사각형 위치, 크기 설정 (겹치지 않게 계산)
        Rect newRect = Rect.fromLTWH(point.longitude, point.latitude, 50, 50);
        _rectangles.add(newRect);
      }
    });
  }

  @override
  void dispose() {
    _markerController.dispose();
    _debounceTimer.dispose();
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
          GoogleMap(
            onMapCreated: (controller) => _mapController = controller,
            onCameraMove: (_) {
              _debounceTimer.resetDebounce(_mapController!);
              setState(() {
                _rectangles.clear(); // 화면 움직임 시 사각형 제거
              });
            },
            initialCameraPosition: CameraPosition(
              target: _currentPosition,
              zoom: 14.0,
            ),
            markers: _markerController.singleMarker != null
                ? {_markerController.singleMarker!}
                : {},
            onLongPress: _markerController.addMarker,
            onTap: (LatLng position) {
              _markerController.removeMarker();
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
          ),
          // 사각형 위치 표시
          for (var rect in _rectangles)
            Positioned(
              left: rect.left,
              top: rect.top,
              width: rect.width,
              height: rect.height,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.red),
                  color: Colors.red.withOpacity(0.3),
                ),
              ),
            ),
          AnimatedSlide(
            duration: const Duration(milliseconds: 300),
            offset:
                _markerController.isMarkerVisible ? Offset(0, 0) : Offset(0, 1),
            curve: Curves.easeInOut,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
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
