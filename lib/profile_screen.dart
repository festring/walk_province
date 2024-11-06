import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatelessWidget {
  final User user = FirebaseAuth.instance.currentUser!;

  Future<int> _getUserPhotoCount() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('photos')
        .where('uploader', isEqualTo: user.displayName)
        .get();
    return snapshot.docs.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('프로필')),
      body: FutureBuilder<int>(
        future: _getUserPhotoCount(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData) {
            return Column(
              children: [
                Text('사용자 이름: ${user.displayName}'),
                Text('업로드한 사진 수: ${snapshot.data}'),
                Text('점수: ${(snapshot.data ?? 0) * 10}점'),
              ],
            );
          }
          return Text('프로필을 불러올 수 없습니다.');
        },
      ),
    );
  }
}
