import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/api_service.dart';
import '../../providers/history_provider.dart';
import '../../services/database_service.dart';
import '../../services/sni_calculator.dart';
import 'dart:ui' as _ui;
import 'grade_result_screen.dart';

class ResultScreen extends ConsumerStatefulWidget {
  final List<String> imagePaths;
  final ApiService apiService;

  const ResultScreen({
    Key? key,
    required this.imagePaths,
    required this.apiService,
  }) : super(key: key);

  @override
  _ResultScreenState createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen> {
  bool _isProcessing = true;
  List<DetectionResult> _results = [];
  String? _errorMessage;
  File? _imageFile;
  int _imageWidth = 0;
  int _imageHeight = 0;
  int _totalBeansAllImages = 0;
  int _totalDefectCountAllImages = 0;
  double _defectScore = 0;
  int _processedCount = 0;
  ScanRecord? _currentRecord;

  @override
  void initState() {
    super.initState();
    _imageFile = File(widget.imagePaths.first);
    _processImage();
  }

  Future<void> _processImage() async {
    try {
      Map<String, int> aggregatedDetails = {};
      int totalDefectCount = 0;
      int totalBeans = 0;
      List<DetectionResult> lastImageDetections = [];
      int lastImageWidth = 0;
      int lastImageHeight = 0;

      for (int i = 0; i < widget.imagePaths.length; i++) {
        final path = widget.imagePaths[i];
        final output = await widget.apiService.runInferenceOnImage(path);

        lastImageDetections = output.detections;
        lastImageWidth = output.imageWidth;
        lastImageHeight = output.imageHeight;
        totalBeans += output.detections.length;

        for (var d in output.detections) {
          aggregatedDetails[d.label] = (aggregatedDetails[d.label] ?? 0) + 1;
          if (d.label != 'normal' && d.label != 'benda_lain') {
            totalDefectCount++;
          }
        }

        if (mounted) {
          setState(() {
            _processedCount = i + 1;
          });
        }
      }


      final sniResult = SniCalculator.evaluate(aggregatedDetails);

      if (mounted) {
        final record = ScanRecord(
          timestamp: DateTime.now(),
          imagePath: widget.imagePaths.first,
          defectCount: totalDefectCount,
          defectScore: sniResult.totalScore,
          totalBeans: totalBeans,
          grade: sniResult.grade,
          defectDetails: aggregatedDetails,
        );


        ref.read(historyProvider.notifier).addScan(record);

        setState(() {
          _imageWidth = lastImageWidth;
          _imageHeight = lastImageHeight;
          _results = lastImageDetections;
          _totalBeansAllImages = totalBeans;
          _totalDefectCountAllImages = totalDefectCount;
          _defectScore = sniResult.totalScore;
          _currentRecord = record;
          _isProcessing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Hasil Deteksi', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isProcessing
          ? _buildLoadingState()
          : _errorMessage != null
              ? _buildErrorState()
              : _buildResultState(),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Colors.green),
          const SizedBox(height: 16),
          Text(
            widget.imagePaths.length > 1
                ? 'Menganalisis Batch: $_processedCount / ${widget.imagePaths.length}'
                : 'Sedang menganalisis biji kopi...',
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text(
            'Terjadi Kesalahan:\n$_errorMessage',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kembali'),
          )
        ],
      ),
    );
  }

  Widget _buildResultState() {
    return Column(
      children: [
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (_imageFile != null)
                ColorFiltered(
                  colorFilter: const ColorFilter.matrix([
                    1.2, 0, 0, 0, 30,
                    0, 1.2, 0, 0, 30,
                    0, 0, 1.2, 0, 30,
                    0, 0, 0, 1, 0,
                  ]),
                  child: Image.file(
                    _imageFile!,
                    fit: BoxFit.contain,
                  ),
                ),
              if (_results.isNotEmpty && _imageWidth > 0 && _imageHeight > 0 && widget.imagePaths.length == 1)
                LayoutBuilder(
                  builder: (context, constraints) {
                    return CustomPaint(
                      size: Size(constraints.maxWidth, constraints.maxHeight),
                      painter: _StaticBoundingBoxPainter(
                        results: _results,
                        imageWidth: _imageWidth.toDouble(),
                        imageHeight: _imageHeight.toDouble(),
                      ),
                    );
                  }
                ),
            ],
          ),
        ),
        _buildBottomPanel(),
      ],
    );
  }

  Widget _buildBottomPanel() {
    int defectCount = _totalDefectCountAllImages;

    return ClipRRect(
      child: BackdropFilter(
        filter: _ui.ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            border: Border(
              top: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
          ),
          child: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$_totalBeansAllImages Biji Kopi',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$defectCount Cacat',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    if (_currentRecord != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GradeResultScreen(scanRecord: _currentRecord!),
                        ),
                      );
                    }
                  },
                  child: const Text('Cek SNI', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StaticBoundingBoxPainter extends CustomPainter {
  final List<DetectionResult> results;
  final double imageWidth;
  final double imageHeight;

  _StaticBoundingBoxPainter({
    required this.results,
    required this.imageWidth,
    required this.imageHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (results.isEmpty) return;


    final double scaleX = size.width / imageWidth;
    final double scaleY = size.height / imageHeight;
    final double scale = scaleX < scaleY ? scaleX : scaleY;


    final double offsetX = (size.width - (imageWidth * scale)) / 2;
    final double offsetY = (size.height - (imageHeight * scale)) / 2;

    final paintBox = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final paintTextBg = Paint()..color = Colors.red.withOpacity(0.8);

    for (var result in results) {
      final rect = result.boundingBox;


      final left = (rect.left * scale) + offsetX;
      final top = (rect.top * scale) + offsetY;
      final right = (rect.right * scale) + offsetX;
      final bottom = (rect.bottom * scale) + offsetY;

      final displayRect = Rect.fromLTRB(left, top, right, bottom);


      if (result.polygon.isNotEmpty) {
        final path = Path();
        for (int i = 0; i < result.polygon.length; i++) {
          final pt = result.polygon[i];
          final px = (pt.dx * scale) + offsetX;
          final py = (pt.dy * scale) + offsetY;

          if (i == 0) {
            path.moveTo(px, py);
          } else {
            path.lineTo(px, py);
          }
        }
        path.close();

        final paintPolyFill = Paint()
          ..color = Colors.blue.withOpacity(0.3)
          ..style = PaintingStyle.fill;

        final paintPolyStroke = Paint()
          ..color = Colors.blue
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;

        canvas.drawPath(path, paintPolyFill);
        canvas.drawPath(path, paintPolyStroke);
      } else {

        canvas.drawRect(displayRect, paintBox);
      }


      final textSpan = TextSpan(
        text: '${result.label} ${(result.confidence * 100).toStringAsFixed(0)}%',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      );

      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();

      canvas.drawRect(
        Rect.fromLTWH(
          displayRect.left,
          displayRect.top - textPainter.height,
          textPainter.width + 4,
          textPainter.height + 4,
        ),
        paintTextBg,
      );

      textPainter.paint(
        canvas,
        Offset(displayRect.left + 2, displayRect.top - textPainter.height + 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
