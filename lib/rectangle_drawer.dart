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
  final double height;

  Rectangle(this.userId, this.base64Image, this.heartCount, this.left, this.top,
      this.width, this.height);
}

class RectangleDrawer {
  final List<Rectangle> _rectangles = [];

  List<Rectangle> get rectangles => _rectangles;

  bool isTapped = false;

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
  List<Widget> displayRectangles() {
    return _rectangles.map((rect) {
      return Positioned(
        left: rect.left,
        top: rect.top,
        width: rect.width,
        height: rect.height,
        child: GestureDetector(
          onTap: () {
            isTapped = !isTapped;
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 상자의 ID와 좋아요 수를 나타내는 애니메이션 위젯
              AnimatedPositioned(
                duration: Duration(milliseconds: 300),
                top: isTapped ? -20 : 0,
                child: Opacity(
                  opacity: isTapped ? 1 : 0,
                  child: Text(
                    "ID: ${rect.userId}",
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              AnimatedPositioned(
                duration: Duration(milliseconds: 300),
                bottom: isTapped ? -20 : 0,
                child: Opacity(
                  opacity: isTapped ? 1 : 0,
                  child: Text(
                    "❤️ ${rect.heartCount}",
                    style: TextStyle(fontSize: 10, color: Colors.red),
                  ),
                ),
              ),
              // 이미지 상자
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: rect.base64Image.isNotEmpty
                    ? Image.memory(
                        base64Decode(rect.base64Image),
                        fit: BoxFit.cover,
                        width: rect.width,
                        height: rect.height,
                      )
                    : Container(
                        width: rect.width,
                        height: rect.height,
                        color: Colors.grey[200],
                        child: Icon(Icons.image, color: Colors.grey, size: 40),
                      ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }
}
