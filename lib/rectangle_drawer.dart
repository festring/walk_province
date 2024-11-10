import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';

class Rectangle {
  final String userId;
  final String base64Image;
  final int heartCount;
  final double left;
  final double top;
  final double width;
  double height;
  bool isExpanded; // 사각형 확장 상태 관리

  Rectangle(this.userId, this.base64Image, this.heartCount, this.left, this.top,
      this.width, this.height,
      {this.isExpanded = false});
}

class RectangleDrawer {
  final List<Rectangle> _rectangles = [];

  List<Rectangle> get rectangles => _rectangles;

  // 배열을 기반으로 사각형 생성 메서드
  void generateRectangles(
      List<List<dynamic>> array, LatLngBounds bounds, Size screenSize) {
    _rectangles.clear();

    double latRange = bounds.northeast.latitude - bounds.southwest.latitude;
    double lngRange = bounds.northeast.longitude - bounds.southwest.longitude;

    for (var item in array) {
      String userId = item[0].toString();
      String base64Image = item[1].toString();
      int heartCount = int.tryParse(item[2].toString()) ?? 0;
      double xpos = double.tryParse(item[3].toString()) ?? 0.0;
      double ypos = double.tryParse(item[4].toString()) ?? 0.0;

      // 위도와 경도를 화면 좌표로 변환하여 중앙에 배치
      double left =
          ((xpos - bounds.southwest.longitude) / lngRange) * screenSize.width -
              50;
      double top =
          ((bounds.northeast.latitude - ypos) / latRange) * screenSize.height -
              50;

      // 100x100 크기의 사각형 생성
      Rectangle rect =
          Rectangle(userId, base64Image, heartCount, left, top, 100, 100);
      _rectangles.add(rect);
    }
  }

  // 사각형 리스트 초기화
  void clearRectangles() {
    _rectangles.clear();
  }

  // 생성된 사각형을 화면에 표시할 위젯 리스트 생성 메서드
  List<Widget> displayRectangles(VoidCallback onRectangleTapped) {
    return _rectangles.map((rect) {
      return Positioned(
        left: rect.left,
        top: rect.isExpanded ? rect.top - 30 : rect.top, // 위쪽으로 이동
        width: rect.width,
        height: rect.isExpanded ? rect.height + 60 : rect.height, // 위아래로 공간 증가
        child: GestureDetector(
          onTap: () {
            rect.isExpanded = !rect.isExpanded; // 상태 토글
            onRectangleTapped(); // 상태 변경 후 재렌더링 콜백 호출
          },
          child: Container(
            color: Colors.transparent, // 배경색을 투명하게 설정
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 사용자 ID 슬라이드 애니메이션
                AnimatedPositioned(
                  duration: Duration(milliseconds: 300),
                  top: rect.isExpanded ? 10 : -20, // 아래에서 위로 슬라이드
                  child: AnimatedOpacity(
                    opacity: rect.isExpanded ? 1.0 : 0.0,
                    duration: Duration(milliseconds: 300),
                    child: Text(
                      rect.userId,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                // 이미지 상자
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: rect.base64Image.isNotEmpty
                      ? Image.memory(
                          base64Decode(rect.base64Image),
                          width: rect.width,
                          height: rect.width, // 정사각형 형태로 고정
                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: rect.width,
                          height: rect.width,
                          color: Colors.grey[200],
                          child:
                              Icon(Icons.image, color: Colors.grey, size: 40),
                        ),
                ),
                // 좋아요 개수 슬라이드 애니메이션
                AnimatedPositioned(
                  duration: Duration(milliseconds: 300),
                  bottom: rect.isExpanded ? 10 : -20, // 위에서 아래로 슬라이드
                  child: AnimatedOpacity(
                    opacity: rect.isExpanded ? 1.0 : 0.0,
                    duration: Duration(milliseconds: 300),
                    child: Text(
                      "❤️ ${rect.heartCount}",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }
}
