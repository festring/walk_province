import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:dio/dio.dart';

class CustomBottomSheetContent extends StatefulWidget {
  final Map<String, String> info;
  final DraggableScrollableController controller;
  final ScrollController scrollController;

  const CustomBottomSheetContent({
    Key? key,
    required this.info,
    required this.controller,
    required this.scrollController,
  }) : super(key: key);

  @override
  _CustomBottomSheetContentState createState() =>
      _CustomBottomSheetContentState();
}

class _CustomBottomSheetContentState extends State<CustomBottomSheetContent> {
  final Dio _dio = Dio();
  List<Uint8List> imageBytesList = [];
  bool isLoading = false;

  Future<void> fetchImages() async {
    setState(() {
      isLoading = true;
    });

    try {
      debugPrint("API 요청 중... trail_id: ${widget.info["trail_id"]}");
      final response = await _dio.get(
        "http://211.170.135.177:8000/track/image",
        queryParameters: {
          'trail_id': widget.info["trail_id"],
        },
      );

      if (response.statusCode == 200) {
        debugPrint("API 응답 성공: ${response.data}");
        List<dynamic> imagesList = response.data['images'];
        setState(() {
          imageBytesList = imagesList.map((imageData) {
            String base64String = imageData['image']; // "image" 필드에서 base64 추출
            return base64Decode(base64String);
          }).toList();
        });
      } else {
        debugPrint("API 호출 실패: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("API 호출 중 오류 발생: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (imageBytesList.isEmpty &&
        !isLoading &&
        widget.info["trail_id"] != null) {
      fetchImages();
    }
    return DraggableScrollableSheet(
      controller: widget.controller,
      initialChildSize: 0.08,
      minChildSize: 0.08,
      maxChildSize: 0.8,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.0),
              topRight: Radius.circular(16.0),
            ),
          ),
          child: ListView(
            controller: scrollController,
            children: [
              Text(
                widget.info['name'] ?? 'No Name',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                widget.info['description'] ?? 'No Description',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
              const SizedBox(height: 16),
              if (isLoading)
                const Center(child: CircularProgressIndicator())
              else if (imageBytesList.isEmpty)
                const Center(child: Text("이미지가 없습니다"))
              else
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: imageBytesList.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.memory(
                            imageBytesList[index],
                            width: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 24),
              Text(
                widget.info['explanation'] ?? 'No Explanation',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              Text(
                "소요 시간",
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                widget.info['time'] ?? 'No time',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              Text(
                "식수 여부",
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                widget.info['water'] ?? 'No water',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              Text(
                "화장실 여부",
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                widget.info['toilet'] ?? 'No toilet',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              Text(
                "주변 매점",
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                widget.info['market'] ?? 'No market',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              Text(
                "주소",
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                widget.info['position'] ?? 'No position',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        );
      },
    );
  }
}
