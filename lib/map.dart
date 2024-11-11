import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'marker.dart';
import 'scrollViewPage.dart';
import 'debounce_timer.dart';
import 'rectangle_drawer.dart';
import 'bottom_sheet.dart';
import 'package:dio/dio.dart'; // Dio 패키지 import

class MapSample extends StatefulWidget {
  const MapSample({super.key});

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  GoogleMapController? _mapController;
  final MarkerController _markerController = MarkerController();
  final DebounceTimer _debounceTimer = DebounceTimer();
  final RectangleDrawer _rectangleDrawer = RectangleDrawer();
  final Dio _dio = Dio(); // Dio 인스턴스 생성

  LatLng _currentPosition = LatLng(37.7749, -122.4194);

  @override
  void initState() {
    super.initState();
    _checkPermissionAndSetInitialLocation();
    _fetchData(); // API 호출
    _debounceTimer.startDebounce((LatLngBounds bounds) {
      debugPrint('현재 화면 범위 좌표:');
      debugPrint('Southwest: ${bounds.southwest}');
      debugPrint('Northeast: ${bounds.northeast}');
      // 나머지 두 꼭짓점 계산
      LatLng northwest =
          LatLng(bounds.northeast.latitude, bounds.southwest.longitude);
      LatLng southeast =
          LatLng(bounds.southwest.latitude, bounds.northeast.longitude);

      // 4 꼭짓점 모두 출력
      debugPrint('Northwest: $northwest');
      debugPrint('Southeast: $southeast');

      // 앱바 및 기타 요소의 높이를 고려한 유효한 화면 크기 계산
      double topPadding = MediaQuery.of(context).padding.top; // 상태바 높이
      double appBarHeight = kToolbarHeight; // AppBar 높이
      double effectiveHeight =
          MediaQuery.of(context).size.height - topPadding - appBarHeight;
      Size screenSize =
          Size(MediaQuery.of(context).size.width, effectiveHeight);

      // 예시 배열로 사각형 생성
      _rectangleDrawer.generateRectangles([
        [
          'user123', // 사용자 ID
          '', // 이미지 데이터 (base64 문자열, 예시에서는 빈 문자열로 설정)
          15, // 좋아요 개수
          bounds.southwest.longitude + 0.001,
          bounds.southwest.latitude + 0.001
        ],
        [
          'user456',
          '',
          23,
          bounds.northeast.longitude - 0.001,
          bounds.northeast.latitude - 0.001
        ],
        [
          'user789',
          '',
          10,
          (bounds.northeast.longitude + bounds.southwest.longitude) / 2,
          (bounds.northeast.latitude + bounds.southwest.latitude) / 2
        ]
      ], bounds, screenSize);

      setState(() {});
    });
    _markerController.addListener(() {
      setState(() {});
    });
  }

  // FastAPI에서 데이터를 받아오는 메서드
  Future<void> _fetchData() async {
    try {
      final response = await _dio.get(
          "https://6f765f4d-58a1-466a-b2d3-c6d7c5e74184-00-3s88uoim6pgq9.pike.replit.dev/");
      if (response.statusCode == 200) {
        debugPrint("API 응답: ${response.data}");
      } else {
        debugPrint("API 호출 실패: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("API 호출 중 오류 발생: $e");
    }
  }

  Future<void> _checkPermissionAndSetInitialLocation() async {
    if (await _requestPermission()) {
      _setCurrentLocation();
    } else {
      debugPrint('위치 권한이 거부되었습니다.');
    }
  }

  Future<void> _setCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition();
      _currentPosition = LatLng(position.latitude, position.longitude);
      _mapController?.animateCamera(
        CameraUpdate.newLatLng(_currentPosition),
      );
    } catch (e) {
      debugPrint('현재 위치를 가져오는 중 오류 발생: $e');
    }
  }

  Future<bool> _requestPermission() async {
    PermissionStatus status = await Permission.location.request();
    return status.isGranted;
  }

  Future<void> _navigateAndGetItems(BuildContext context) async {
    Map<String, String> item = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScrollViewPage(),
      ),
    );

    print('Received items: $item');
    // bottomsheet 띄우기
    showCustomBottomSheet(context, item);
    print(item['Lat']);
    try {
      _currentPosition =
          LatLng(double.parse(item['Lat']!), double.parse(item['Lng']!));
      _mapController?.animateCamera(
        CameraUpdate.newLatLng(_currentPosition),
      );
    } catch (e) {
      debugPrint('위치를 가져오는 중 오류 발생: $e');
    }
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
              _navigateAndGetItems(context);
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
                _rectangleDrawer.clearRectangles();
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
          ..._rectangleDrawer.displayRectangles(() {
            setState(() {}); // 클릭 시 상태 변경을 위해 setState 호출
          }), // 사각형 표시 위젯 리스트
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
