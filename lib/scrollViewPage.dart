import 'package:flutter/material.dart';

class ScrollViewPage extends StatefulWidget {
  @override
  _ScrollViewPageState createState() => _ScrollViewPageState();
}

class _ScrollViewPageState extends State<ScrollViewPage> {
  List<String> _items = [];
  bool _isLoading = false;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadData(); // 페이지가 처음 열릴 때 데이터 로드
    _scrollController.addListener(_scrollListener);
  }

  // 5개씩 데이터를 로드하는 함수
  void _loadData() {
    if (_isLoading) return; // 이미 로딩 중이면 중복 로드 방지

    setState(() {
      _isLoading = true;
    });

    Future.delayed(Duration(seconds: 2), () {
      List<String> newItems =
          List.generate(5, (index) => 'Item ${_items.length + index + 1}');
      setState(() {
        _items.addAll(newItems);
        _isLoading = false;
      });
    });
  }

  // 스크롤이 끝에 도달했을 때 데이터 추가 로드
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
        title: Text('무한 스크롤 리스트'),
      ),
      body: ListView.builder(
        controller: _scrollController,
        itemCount: _items.length + 1, // 마지막 로딩 표시를 위한 아이템 추가
        itemBuilder: (context, index) {
          if (index == _items.length) {
            return _isLoading
                ? Center(child: CircularProgressIndicator())
                : SizedBox();
          } else {
            return ListTile(
              title: Text(_items[index]),
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
