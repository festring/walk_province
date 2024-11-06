import 'dart:io';
import 'dart:convert';
import 'dart:typed_data'; // Uint8List를 사용하기 위해 추가
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image/image.dart' as img;

class PhotoUploader {
  final ImagePicker _picker = ImagePicker();

  Future<void> uploadPhoto() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      final imageFile = File(photo.path);
      final bytes = await imageFile.readAsBytes();

      // 이미지 압축 및 리사이즈
      final resizedImage =
          _compressAndResizeImage(Uint8List.fromList(bytes), maxWidth: 800);

      // Base64 인코딩
      final base64Image = base64Encode(resizedImage);

      // Firestore에 Base64 문자열 저장
      await FirebaseFirestore.instance.collection('photos').add({
        'image_base64': base64Image,
        'uploader': '사용자 이름',
        'timestamp': FieldValue.serverTimestamp(),
        'location': GeoPoint(37.7749, -122.4194),
      });
    }
  }

  List<int> _compressAndResizeImage(Uint8List imageBytes,
      {int maxWidth = 800}) {
    img.Image? image = img.decodeImage(imageBytes);
    if (image == null) {
      throw Exception("이미지를 디코딩할 수 없습니다.");
    }

    image = img.copyResize(image, width: maxWidth);
    return img.encodeJpg(image, quality: 70);
  }
}
