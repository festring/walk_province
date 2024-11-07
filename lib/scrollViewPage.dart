import 'package:flutter/material.dart';

class ScrollViewPage extends StatefulWidget {
  @override
  _ScrollViewPageState createState() => _ScrollViewPageState();
}

class _ScrollViewPageState extends State<ScrollViewPage> {
  List<Map<String, String>> _items = [];
  bool _isLoading = false;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadData();
    _scrollController.addListener(_scrollListener);
  }

  // 데이터를 로드하는 함수
  void _loadData() {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    // 일단 딜레이가 1초있는데 나중에 벗깁시다
    Future.delayed(Duration(seconds: 1), () {
      List<Map<String, String>> newItems = List.generate(
          20,
          (index) => {
                'Name': 'Item ${_items.length + index + 1}',
                'Description':
                    'This is the description for Item ${_items.length + index + 1}',
                'Distance': '${(index + 1) * 1.5} km', // 예시 거리 값
              });
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
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('${_items[index]['Name']} clicked')));
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

// CustomListItem 위젯에 Distance 추가
class CustomListItem extends StatelessWidget {
  final String name;
  final String description;
  final String distance;
  final VoidCallback onTap;

  CustomListItem({
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
