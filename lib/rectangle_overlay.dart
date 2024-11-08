import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RectangleOverlay extends StatefulWidget {
  final LatLngBounds bounds;
  final List<LatLng> points;

  const RectangleOverlay({
    Key? key,
    required this.bounds,
    required this.points,
  }) : super(key: key);

  @override
  _RectangleOverlayState createState() => _RectangleOverlayState();
}

class _RectangleOverlayState extends State<RectangleOverlay> {
  List<Rect> _rectangles = [];

  @override
  void initState() {
    super.initState();
    _calculateRectangles();
  }

  void _calculateRectangles() {
    setState(() {
      _rectangles.clear();
      for (LatLng point in widget.points) {
        // 화면 크기와 겹침 여부를 고려하여 사각형 위치와 크기를 설정
        Rect newRect = Rect.fromLTWH(point.longitude, point.latitude, 50, 50);
        _rectangles.add(newRect);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: _rectangles.map((rect) {
        return Positioned(
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
        );
      }).toList(),
    );
  }
}
