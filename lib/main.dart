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

  Future<String?> _getUserID() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FutureBuilder<String?>(
        future: _getUserID(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // 로딩 중
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else if (snapshot.hasError || snapshot.data == null) {
            // 에러 처리 또는 유저 ID가 없는 경우
            return const Scaffold(
              body: Center(
                child: Text('사용자 ID를 불러오지 못했습니다.'),
              ),
            );
          } else {
            // 정상적으로 userID 전달
            return MapSample(userID: snapshot.data!);
          }
        },
      ),
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
      "http://211.170.135.177:8000/user/create",
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
