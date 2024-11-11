import 'package:flutter/material.dart';

class ScrollViewPage extends StatefulWidget {
  @override
  _ScrollViewPageState createState() => _ScrollViewPageState();
}

class _ScrollViewPageState extends State<ScrollViewPage> {
  List<Map<String, String>> _items = [];
  bool _isLoading = false;
  ScrollController _scrollController = ScrollController();
  int cnt = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
    _scrollController.addListener(_scrollListener);
  }

  void _loadData() {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    // 예시로 1초 후 데이터 추가
    Future.delayed(Duration(seconds: 1), () {
      cnt += 1;
      debugPrint('${cnt}');
      List<Map<String, String>> newItems = List.generate(
        20,
        (index) => {
          'Name': 'Item ${_items.length + index + 1}',
          'Description': 'Description for Item ${_items.length + index + 1}',
          'Distance': '${(index + 1) * 1.5} km',
          'Lat': '${(index)}',
          'Lng': '${(index)}',
        },
      );
      setState(() {
        _items.addAll(newItems);
        _isLoading = false;
      });
    });
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
              name: _items[index]['Name'] ?? 'No Name',
              description: _items[index]['Description'] ?? 'No Description',
              distance: _items[index]['Distance'] ?? 'No Distance',
              lat: _items[index]['Lat'] ?? 'No Lat',
              lng: _items[index]['Lng'] ?? 'No Lng',
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
  final String name;
  final String description;
  final String distance;
  final String lat;
  final String lng;
  final VoidCallback onTap;

  CustomListItem({
    required this.name,
    required this.description,
    required this.distance,
    required this.lat,
    required this.lng,
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
