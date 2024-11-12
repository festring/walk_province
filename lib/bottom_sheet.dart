import 'package:flutter/material.dart';

class CustomBottomSheetContent extends StatefulWidget {
  final Map<String, String> info;
  final DraggableScrollableController controller; // Controller를 외부에서 전달받음
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
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      controller: widget.controller, // 전달받은 Controller를 사용
      initialChildSize: 0.08,
      minChildSize: 0.08,
      maxChildSize: 0.8,
      builder: (context, scrollController) {
        return Container(
          padding: EdgeInsets.all(16.0),
          decoration: BoxDecoration(
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
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                widget.info['description'] ?? 'No Description',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
              SizedBox(height: 16),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(right: 8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(
                          'https://picsum.photos/100',
                          width: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 24),
              Text(
                widget.info['explanation'] ?? 'No Explanation',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 24),
              Text(
                "걸리는 시간",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                widget.info['time'] ?? 'No time',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 24),
              Text(
                "식수 여부",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                widget.info['water'] ?? 'No water',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 24),
              Text(
                "화장실 여부",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                widget.info['toilet'] ?? 'No toilet',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 24),
              Text(
                "주변 매점",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                widget.info['market'] ?? 'No market',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 24),
              Text(
                "주소",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                widget.info['position'] ?? 'No position',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        );
      },
    );
  }
}
