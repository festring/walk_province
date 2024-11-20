import 'dart:io';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';

class ImageHandler {
  final ImagePicker _picker = ImagePicker();

  // 갤러리에서 이미지 선택
  Future<Map<String, dynamic>?> pickImageFromGallery() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final imageFile = File(pickedFile.path);
        final base64String = await _imageToBase64(imageFile);
        return {
          'file': imageFile,
          'base64': base64String,
        };
      }
    } catch (e) {
      print('이미지 선택 오류: $e');
    }
    return null;
  }

  // 이미지 파일을 Base64로 변환
  Future<String> _imageToBase64(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    return base64Encode(bytes);
  }
}
