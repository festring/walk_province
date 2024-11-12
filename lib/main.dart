import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'map.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeUserId(); // 사용자 ID 초기화
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MapSample(),
    );
  }
}

Future<void> _initializeUserId() async {
  final prefs = await SharedPreferences.getInstance();
  String? userId = prefs.getString('user_id');

  if (userId == null) {
    // 저장된 ID가 없으면 새로 생성
    userId = await _createUserId();
    if (userId != null) {
      await prefs.setString('user_id', userId);
      debugPrint("새로 생성된 사용자 ID: $userId");
    } else {
      debugPrint("사용자 ID 생성에 실패했습니다.");
    }
  } else {
    debugPrint("기존 저장된 사용자 ID: $userId");
  }
}

Future<String?> _createUserId() async {
  final dio = Dio();
  try {
    final response = await dio.get(
      "https://6f765f4d-58a1-466a-b2d3-c6d7c5e74184-00-3s88uoim6pgq9.pike.replit.dev/user/create",
    );

    if (response.statusCode == 200 && response.data != null) {
      return response.data['user_id'] as String;
    } else {
      debugPrint("사용자 ID 생성 요청 실패: ${response.statusCode}");
    }
  } catch (e) {
    debugPrint("사용자 ID 생성 중 오류 발생: $e");
  }
  return null;
}
