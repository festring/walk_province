import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:dio/dio.dart'; // Dio 패키지 import

class ScrollViewPage extends StatefulWidget {
  LatLng centerPosition;

  ScrollViewPage({required this.centerPosition});

  @override
  _ScrollViewPageState createState() => _ScrollViewPageState();
}

class _ScrollViewPageState extends State<ScrollViewPage> {
  List<Map<String, String>> _items = [];
  bool _isLoading = false;
  double _centerLat = 1;
  double _centerLng = 1;
  ScrollController _scrollController = ScrollController();
  int cnt = 1;
  final Dio _dio = Dio();

  @override
  void initState() {
    super.initState();
    _centerLat = widget.centerPosition.latitude;
    _centerLng = widget.centerPosition.longitude;
    print("${_centerLat} 제발 아!!!!!!!!");
    _loadData();
    _scrollController.addListener(_scrollListener);
  }

  Future<void> _loadData() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // GET 요청
      final response = await _dio.get(
          "https://6f765f4d-58a1-466a-b2d3-c6d7c5e74184-00-3s88uoim6pgq9.pike.replit.dev/search/default",
          queryParameters: {
            'xpos': _centerLat,
            'ypos': _centerLng,
            'page': cnt,
          });
      if (response.statusCode == 200) {
        debugPrint("GET API 응답: ${response.data}");
      } else {
        debugPrint("GET API 호출 실패: ${response.statusCode}");
      }

      // 받아온 데이터로 스크롤뷰 출력
      debugPrint('${cnt}');
      List<Map<String, String>> newItems = List.generate(
        20,
        (index) => {
          'trailid': response.data['trail'][index]['trail_id'].toString(),
          'Name': response.data['trail'][index]['trail_name'],
          'Description': response.data['trail'][index]['path'],
          'Distance':
              response.data['trail'][index]['distance'].toStringAsFixed(2) +
                  'km',
        },
      );
      setState(() {
        _items.addAll(newItems);
        _isLoading = false;
      });
      cnt += 1;
    } catch (e) {
      debugPrint("GET API 호출 중 오류 발생: $e");
    }
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadData();
    }
  }

  // _items 리턴하는 함수 추가
  List<Map<String, String>> getItems() {
    return _items;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('주변 산책로'),
      ),
      body: ListView.builder(
        controller: _scrollController,
        itemCount: _items.length + 1,
        itemBuilder: (context, index) {
          if (index == _items.length) {
            return _isLoading
                ? Center(child: CircularProgressIndicator())
                : SizedBox();
          } else {
            return CustomListItem(
              trailid: int.parse(_items[index]['trailid']!),
              name: _items[index]['Name'] ?? 'No Name',
              description: _items[index]['Description'] ?? 'No Description',
              distance: _items[index]['Distance'] ?? 'No Distance',
              onTap: () {
                Navigator.pop(context, _items[index]);
              },
            );
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

class CustomListItem extends StatelessWidget {
  final int trailid;
  final String name;
  final String description;
  final String distance;
  final VoidCallback onTap;

  CustomListItem({
    required this.trailid,
    required this.name,
    required this.description,
    required this.distance,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.0),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 4.0),
                  Text(
                    distance,
                    style: TextStyle(
                      fontSize: 12.0,
                      color: Colors.blueGrey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
