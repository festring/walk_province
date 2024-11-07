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

  @override
  void initState() {
    super.initState();
    _checkPermissionAndSetInitialLocation(); // 권한 체크 및 초기 위치 설정 메서드 호출
    // 지도 화면 범위가 고정되었을 때 실행할 콜백 설정
    _debounceTimer.startDebounce((LatLngBounds bounds) {
      debugPrint('현재 화면 범위 좌표:');
      debugPrint('Southwest: ${bounds.southwest}');
      debugPrint('Northeast: ${bounds.northeast}');
    });
    // 마커 상태가 변경될 때 UI 업데이트
    _markerController.addListener(() {
      setState(() {});
    });
  }

  // 위치 권한 체크 및 초기 위치 설정 메서드
  Future<void> _checkPermissionAndSetInitialLocation() async {
    if (await _requestPermission()) {
      // 권한이 허용된 경우
      _setCurrentLocation(); // 현재 위치 설정
    } else {
      debugPrint('위치 권한이 거부되었습니다.'); // 권한이 거부된 경우 콘솔 출력
    }
  }

  // 위치 버튼 클릭 시 현재 위치로 설정하는 메서드
  Future<void> _setCurrentLocation() async {
    try {
      Position position =
          await Geolocator.getCurrentPosition(); // 현재 위치 정보 가져오기
      _currentPosition =
          LatLng(position.latitude, position.longitude); // 위치 정보 기반으로 좌표 설정
      print(position); // 콘솔에 위치 출력

      // 지도 카메라를 현재 위치로 이동
      _mapController?.animateCamera(
        CameraUpdate.newLatLng(_currentPosition),
      );
    } catch (e) {
      debugPrint('현재 위치를 가져오는 중 오류 발생: $e'); // 위치 가져오기 실패 시 오류 출력
    }
  }

  // 위치 권한 요청 메서드
  Future<bool> _requestPermission() async {
    PermissionStatus status = await Permission.location.request(); // 위치 권한 요청
    return status.isGranted; // 권한이 허용된 경우 true 반환
  }

  @override
  void dispose() {
    _markerController.dispose(); // 마커 컨트롤러 리소스 해제
    _debounceTimer.dispose(); // 타이머 리소스 해제
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('주변의 산책로를 확인하세요'), // 앱바 제목
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // 검색 버튼 클릭 시 실행되는 동작
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ScrollViewPage(), // ScrollViewPage로 화면 전환
                ),
              );
            },
          ),
        ],
        backgroundColor: const Color.fromRGBO(201, 239, 203, 1), // 앱바 배경 색상 설정
      ),
      body: Stack(
        children: [
          // 구글 지도 위젯
          GoogleMap(
            onMapCreated: (controller) =>
                _mapController = controller, // 지도 생성 시 컨트롤러 초기화
            onCameraMove: (_) {
              if (_mapController != null) {
                _debounceTimer
                    .resetDebounce(_mapController!); // 카메라 이동 시 디바운스 타이머 초기화
              }
            },
            initialCameraPosition: CameraPosition(
              target: _currentPosition, // 초기 지도 위치 설정
              zoom: 14.0, // 초기 줌 레벨 설정
            ),
            markers: _markerController.singleMarker != null
                ? {_markerController.singleMarker!} // 단일 마커가 존재할 경우 마커 표시
                : {},
            onLongPress: _markerController.addMarker, // 지도 길게 누를 시 마커 추가
            onTap: (LatLng position) {
              _markerController.removeMarker(); // 지도 터치 시 마커 제거
            },
            myLocationEnabled: true, // 현재 위치 표시 설정
            myLocationButtonEnabled: false, // 기본 위치 버튼 비활성화
            zoomControlsEnabled: false, // 줌 버튼 비활성화
          ),
          // 애니메이션 버튼
          AnimatedSlide(
            duration: const Duration(milliseconds: 300), // 애니메이션 지속 시간
            offset: _markerController.isMarkerVisible
                ? Offset(0, 0) // 마커가 보일 때 버튼 위치
                : Offset(0, 1), // 마커가 없을 때 버튼 위치
            curve: Curves.easeInOut, // 애니메이션 커브 설정
            child: Align(
              alignment: Alignment.bottomCenter, // 버튼을 화면 하단에 배치
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
                            onPressed: () => Navigator.of(context)
                                .pop(), // 취소 버튼 클릭 시 다이얼로그 닫기
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
                  child: const Text("사진 업로드"), // 버튼 텍스트
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _setCurrentLocation, // 위치 설정 버튼 클릭 시 동작
        child: Icon(Icons.my_location), // 버튼 아이콘
      ),
    );
  }
}
