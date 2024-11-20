import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:dio/dio.dart';

class CustomBottomSheetContent extends StatefulWidget {
  final Map<String, String>? info; // nullable로 변경
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
  bool hasFetchedImages = false; // API 호출 여부 플래그
  String? previousTrailId; // 이전 trail_id를 저장하는 변수

  Future<void> fetchImages() async {
    if (isLoading || widget.info == null) return; // 로딩 중이거나 info가 null이면 중지

    setState(() {
      isLoading = true;
    });

    try {
      debugPrint("API 요청 중... trail_id: ${widget.info?["trail_id"]}");
      final response = await _dio.get(
        "http://211.170.135.177:8000/track/image",
        queryParameters: {
          'trail_id': widget.info?["trail_id"],
        },
      );

      if (response.statusCode == 200) {
        debugPrint("API 응답 성공: ${response.data}");
        List<dynamic> imagesList = response.data['images'];

        setState(() {
          imageBytesList = imagesList.map((imageData) {
            String base64String = imageData['image'];
            return base64Decode(base64String);
          }).toList();
          hasFetchedImages = true;
        });
      } else {
        debugPrint("API 호출 실패: ${response.statusCode}");
        setState(() {
          hasFetchedImages = true;
        });
      }
    } catch (e) {
      debugPrint("API 호출 중 오류 발생: $e");
      setState(() {
        hasFetchedImages = true;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void didUpdateWidget(covariant CustomBottomSheetContent oldWidget) {
    super.didUpdateWidget(oldWidget);

    // widget.info가 null인지 확인 후 처리
    if (widget.info != null && widget.info!["trail_id"] != previousTrailId) {
      debugPrint("Trail ID가 변경됨: ${widget.info!["trail_id"]}");
      setState(() {
        previousTrailId = widget.info!["trail_id"];
        imageBytesList = []; // 기존 이미지 초기화
        hasFetchedImages = false; // 다시 API 호출 가능하도록 플래그 리셋
      });
      fetchImages();
    }
  }

  @override
  Widget build(BuildContext context) {
    // API 호출 조건: 아직 호출하지 않았고 로딩 중이 아닐 때
    if (!hasFetchedImages && !isLoading && widget.info != null) {
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
          child: widget.info == null
              ? const Center(
                  child: CircularProgressIndicator()) // info가 null일 경우 로딩 표시
              : ListView(
                  controller: scrollController,
                  children: [
                    Text(
                      widget.info?['name'] ?? 'No Name',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.info?['description'] ?? 'No Description',
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
                    ..._buildAdditionalInfo(), // 기타 정보 빌드 함수 호출
                  ],
                ),
        );
      },
    );
  }

  List<Widget> _buildAdditionalInfo() {
    return [
      _buildInfoSection("소요 시간", widget.info?['time'] ?? 'No time'),
      _buildInfoSection("식수 여부", widget.info?['water'] ?? 'No water'),
      _buildInfoSection("화장실 여부", widget.info?['toilet'] ?? 'No toilet'),
      _buildInfoSection("주변 매점", widget.info?['market'] ?? 'No market'),
      _buildInfoSection("주소", widget.info?['position'] ?? 'No position'),
    ];
  }

  Widget _buildInfoSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          content,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
