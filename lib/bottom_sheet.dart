import 'package:flutter/material.dart';

void showCustomBottomSheet(BuildContext context, Map<String, String> item) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(0.0),
    builder: (BuildContext context) {
      return DraggableScrollableSheet(
        initialChildSize: 0.5, // BottomSheet가 시작될 때 화면의 50% 크기
        minChildSize: 0.3, // 최소 크기 (30%)
        maxChildSize: 1.0, // 최대 크기 (100%)
        builder: (BuildContext context, ScrollController scrollController) {
          return Container(
            width: double.infinity, // 화면의 너비를 꽉 채움
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white, // BottomSheet의 배경색
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.0),
                topRight: Radius.circular(16.0),
              ),
            ),
            child: ListView(
              controller: scrollController,
              children: [
                Text(
                  item['Name'] ?? 'No Name',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  item['Description'] ?? 'No Description',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 8),
                Text(
                  item['Distance'] ?? 'No Distance',
                  style: TextStyle(fontSize: 14, color: Colors.blueGrey),
                ),
                SizedBox(height: 16),
                // 가로 이미지 스크롤뷰 추가
                SizedBox(
                  height: 100, // 이미지의 높이
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 5, // 예시 이미지 개수
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.only(right: 8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.network(
                            'https://picsum.photos/100', // 예시 이미지 URL
                            width: 100, // 이미지의 너비
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
