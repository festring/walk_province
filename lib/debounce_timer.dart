// debounce_timer.dart

import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DebounceTimer {
  Timer? _debounce;
  Function(LatLngBounds bounds)? onStablePosition;

  // 타이머 시작
  void startDebounce(Function(LatLngBounds bounds) onStablePositionCallback) {
    onStablePosition = onStablePositionCallback;
  }

  // 화면이 이동할 때마다 호출할 메서드
  void resetDebounce(GoogleMapController controller) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(seconds: 2), () async {
      final bounds = await controller.getVisibleRegion();
      if (onStablePosition != null) onStablePosition!(bounds);
    });
  }

  // 리소스 정리
  void dispose() {
    _debounce?.cancel();
  }
}
