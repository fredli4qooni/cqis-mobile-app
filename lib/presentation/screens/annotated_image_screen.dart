import 'dart:io';
import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import '../../services/api_service.dart';
import '../widgets/bounding_box_painter.dart';

class AnnotatedImageScreen extends StatefulWidget {
  final List<ScanRecord> scanRecords;

  const AnnotatedImageScreen({super.key, required this.scanRecords});

  @override
  State<AnnotatedImageScreen> createState() => _AnnotatedImageScreenState();
}

class _AnnotatedImageScreenState extends State<AnnotatedImageScreen> {
  final PageController _pageController = PageController();
  int _currentPageIndex = 0;

  List<DetectionResult> _parseDetections(List<dynamic>? raw) {
    if (raw == null) return [];
    return raw.map((d) {
      if (d is! Map<String, dynamic>) return null;
      final bbox = d['bbox'] as Map<String, dynamic>?;
      final polygonRaw = d['polygon'] as List<dynamic>?;

      List<Offset> polygon = [];
      if (polygonRaw != null) {
        for (var pt in polygonRaw) {
          if (pt is List && pt.length >= 2) {
            polygon.add(Offset((pt[0] as num).toDouble(), (pt[1] as num).toDouble()));
          }
        }
      }

      return DetectionResult(
        classIndex: (d['class_index'] as num?)?.toInt() ?? 0,
        label: d['label'] as String? ?? 'normal',
        confidence: (d['confidence'] as num?)?.toDouble() ?? 0.0,
        sizeCategory: 'normal',
        boundingBox: Rect.fromLTRB(
          (bbox?['left'] as num?)?.toDouble() ?? 0.0,
          (bbox?['top'] as num?)?.toDouble() ?? 0.0,
          (bbox?['right'] as num?)?.toDouble() ?? 0.0,
          (bbox?['bottom'] as num?)?.toDouble() ?? 0.0,
        ),
        polygon: polygon,
      );
    }).whereType<DetectionResult>().toList();
  }

  Widget _buildImage(String imagePath) {
    if (imagePath.startsWith('http')) {
      return Image.network(imagePath, fit: BoxFit.contain);
    } else {
      final file = File(imagePath);
      if (file.existsSync()) {
        return Image.file(file, fit: BoxFit.contain);
      } else {
        return const Center(child: Text('Gambar tidak ditemukan di perangkat', style: TextStyle(color: Colors.white)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Gambar Beranotasi', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPageIndex = index;
                });
              },
              itemCount: widget.scanRecords.length,
              itemBuilder: (context, index) {
                final record = widget.scanRecords[index];
                final detections = _parseDetections(record.rawDetections);

                return Stack(
                  fit: StackFit.expand,
                  children: [
                    _buildImage(record.imagePath),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return CustomPaint(
                          painter: BoundingBoxPainter(
                            detections,
                            record.imageWidth ?? 1,
                            record.imageHeight ?? 1,
                          ),
                          child: Container(),
                        );
                      }
                    ),
                  ],
                );
              },
            ),
          ),
          if (widget.scanRecords.length > 1)
            Container(
              color: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Gambar ${_currentPageIndex + 1} dari ${widget.scanRecords.length}  •  Geser untuk melihat semua',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
