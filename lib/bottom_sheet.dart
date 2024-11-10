import 'package:flutter/material.dart';

void showCustomBottomSheet(BuildContext context, Map<String, String> item) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // BottomSheet 크기 조정 가능하도록
    backgroundColor: Colors.transparent, // 배경을 투명하게 설정
    builder: (BuildContext context) {
      return Container(
        width: double.infinity, // 화면의 너비를 꽉 채움
        height: MediaQuery.of(context).size.height * 0.5,
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white, // BottomSheet의 배경색
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.0),
            topRight: Radius.circular(16.0),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
}
