import 'dart:developer';
import 'dart:io';

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
import 'image_handler.dart';

class MapSample extends StatefulWidget {
  const MapSample({super.key, required this.userID});
  final String userID;

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  GoogleMapController? _mapController;
  final MarkerController _markerController = MarkerController();
  final DebounceTimer _debounceTimer = DebounceTimer();
  final RectangleDrawer _rectangleDrawer = RectangleDrawer();

  final DraggableScrollableController _controller =
      DraggableScrollableController();
  final ScrollController _scrollController = ScrollController();
  final ImageHandler _imageHandler = ImageHandler();

  final Dio _dio = Dio(); // Dio 인스턴스 생성
  LatLng _selectedPosition = LatLng(37.42796133580664, -122.085749655962);

  File? _selectedImage;
  String? _base64Image;

  Set<Circle> _circles = {};

  Map<String, String> info = {
    'trail_id': "temp",
    'name': "temp",
    'description': "temp",
    'course_level': "temp",
    'length': "temp",
    'explanation': "temp",
    'time': "temp",
    'water': "temp",
    'toilet': "temp",
    'market': "temp",
    'position': "temp",
    'lat': "temp",
    'lng': "temp",
  };

  LatLng _currentPosition = LatLng(37.7749, -122.4194);
  LatLng _center = LatLng(1, 1);

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
      // GET 요청
      final response = await _dio.get("http://211.170.135.177:8000/get",
          queryParameters: {'q': 'example query'}); // GET 요청에 'q' 파라미터 추가
      if (response.statusCode == 200) {
        debugPrint("GET API 응답: ${response.data}");
      } else {
        debugPrint("GET API 호출 실패: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("GET API 호출 중 오류 발생: $e");
    }

    try {
      // POST 요청
      final postResponse = await _dio.post("http://211.170.135.177:8000/post",
          data: {'item': 'example item'}); // POST 요청에 'item' 데이터를 포함
      if (postResponse.statusCode == 200) {
        debugPrint("POST API 응답: ${postResponse.data}");
      } else {
        debugPrint("POST API 호출 실패: ${postResponse.statusCode}");
      }
    } catch (e) {
      debugPrint("POST API 호출 중 오류 발생: $e");
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

  //스크롤바 구현부분
  Future<void> _navigateAndGetItems(BuildContext context) async {
    try {
      _circles.removeWhere((circle) => circle.circleId.value == 'circle_1');

      print(_center);
      Map<String, String> item = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ScrollViewPage(centerPosition: _center),
        ),
      );

      print('Received items: $item');

      // 바텀시트의 초기화를 담당스
      // <<legacy>>
      // _controller.animateTo(
      //   0.08,
      //   duration: Duration(microseconds: 1),
      //   curve: Curves.linear,
      // );
      _controller.reset();

      debugPrint('${item['trailid']} 바텀쉣!!!!!트');

      try {
        // GET 요청
        final response = await _dio.get(
            "http://211.170.135.177:8000/track/detail",
            queryParameters: {'trail_id': int.parse(item['trailid']!)});
        if (response.statusCode == 200) {
          debugPrint("GET API 응답: ${response.data}");
        } else {
          debugPrint("GET API 호출 실패: ${response.statusCode}");
        }

        _circles.add(
          Circle(
            circleId: CircleId('circle_1'),
            center: LatLng(
                response.data['xpos'], response.data['ypos']), // 원의 중심 위치
            radius: 80, // 반경 (미터 단위)
            fillColor: Colors.blue.withOpacity(0.7), // 원의 채우기 색
            strokeColor: Colors.blue, // 원의 테두리 색
            strokeWidth: 2, // 테두리 두께
          ),
        );

        info = {
          'trail_id': response.data['trail_id'].toString(),
          'name': response.data['name'],
          'description': response.data['path'],
          'course_level': response.data['course_level'].toString(),
          'length': response.data['length'].toString(),
          'explanation': response.data['explanation'],
          'time': response.data['time'],
          'water': response.data['water'],
          'toilet': response.data['toilet'],
          'market': response.data['market'],
          'position': response.data['position'],
          'lat': response.data['xpos'].toString(),
          'lng': response.data['ypos'].toString(),
        };

        //showCustomBottomSheet(context, info);

        try {
          _currentPosition =
              LatLng(double.parse(info['lat']!), double.parse(info['lng']!));
          _mapController?.animateCamera(
            CameraUpdate.newLatLng(_currentPosition),
          );
        } catch (e) {
          debugPrint('위치를 가져오는 중 오류 발생: $e');
        }

        //지도에 마커 표시 포기
      } catch (e) {
        debugPrint("GET API 호출 중 오류 발생: $e");
      }

      // bottomsheet 띄우기
    } catch (e) {
      debugPrint('현재 위치를 가져오는 중 오류 발생: $e');
    }
  }

  // 이미지 받아오기
  Future<void> _handleImagePick(LatLng pos) async {
    final result = await _imageHandler.pickImageFromGallery();
    if (result != null) {
      setState(() {
        _selectedImage = result['file'];
        _base64Image = result['base64'];
      });

      if (_base64Image != null) {
        try {
          print(_base64Image);
          print(widget.userID);
          print(_selectedPosition.latitude);
          final response = await _dio
              .post("http://211.170.135.177:8000/image/create", data: {
            "ID": widget.userID,
            "image": _base64Image,
            "xpos": _selectedPosition.latitude,
            "ypos": _selectedPosition.longitude,
            "tag": "temp"
          });
          if (response.statusCode == 200) {
            debugPrint("POST API 응답: ${response.data}");
          } else {
            debugPrint("POST API 호출 실패: ${response.statusCode}");
          }
        } catch (e) {
          debugPrint("POST API 호출 중 오류 발생: $e");
        }
      }
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
            circles: _circles,
            onCameraMove: (CameraPosition position) {
              _debounceTimer.resetDebounce(_mapController!);
              setState(() {
                _rectangleDrawer.clearRectangles();
                _center = position.target;
                debugPrint("${position.target}");
              });
            },
            initialCameraPosition: CameraPosition(
              target: _currentPosition,
              zoom: 14.0,
            ),
            markers: _markerController.singleMarker != null
                ? {_markerController.singleMarker!}
                : {},
            onLongPress: (LatLng position) {
              setState(() {
                _selectedPosition = position; // 길게 누른 위치로 업데이트
                print(_selectedPosition);
              });
              _markerController.addMarker(position);
            },
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

          CustomBottomSheetContent(
            info: info,
            controller: _controller,
            scrollController: _scrollController,
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
                              print(_selectedPosition);
                              Navigator.of(context).pop();
                              _handleImagePick(_selectedPosition);
                              print("좀돼라");
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
