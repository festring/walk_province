import 'package:flutter/material.dart';

void showCustomBottomSheet(BuildContext context, Map<String, String> item) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
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
              ],
            ),
          );
        },
      );
    },
  );
}
