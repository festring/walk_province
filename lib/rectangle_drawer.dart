import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Rectangle {
  final int imageId;
  final double left;
  final double top;
  final double width;
  final double height;

  Rectangle(this.imageId, this.left, this.top, this.width, this.height);
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
      int imageId = item[0];
      double xpos = item[1];
      double ypos = item[2];

      // 위도와 경도를 화면 좌표로 변환하여 중앙에 배치
      double left =
          ((xpos - bounds.southwest.longitude) / lngRange) * screenSize.width -
              25;
      double top =
          ((bounds.northeast.latitude - ypos) / latRange) * screenSize.height -
              25;

      // 50x50 크기의 사각형 생성
      Rectangle rect = Rectangle(imageId, left, top, 50, 50);
      _rectangles.add(rect);
    }
  }

  // 사각형 리스트 초기화
  void clearRectangles() {
    _rectangles.clear();
  }

  // 생성된 사각형을 화면에 표시할 위젯 리스트 생성 메서드
  List<Widget> displayRectangles() {
    return _rectangles
        .map((rect) => Positioned(
              left: rect.left,
              top: rect.top,
              width: rect.width,
              height: rect.height,
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.red),
                  color: Colors.red.withOpacity(0.3),
                ),
                child: Text(rect.imageId.toString()), // image_id 표시
              ),
            ))
        .toList();
  }
}
