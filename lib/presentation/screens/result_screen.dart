import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/api_service.dart';
import '../../providers/history_provider.dart';
import '../../services/database_service.dart';
import '../../services/sni_calculator.dart';
import 'dart:ui' as ui;
import 'grade_result_screen.dart';

import '../widgets/bounding_box_painter.dart';

class ResultScreen extends ConsumerStatefulWidget {
  final List<String> imagePaths;
  final ApiService apiService;

  const ResultScreen({
    super.key,
    required this.imagePaths,
    required this.apiService,
  });

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen> {
  bool _isProcessing = true;
  List<InferenceOutput> _batchOutputs = [];
  int _currentPageIndex = 0;
  final PageController _pageController = PageController();
  
  String? _errorMessage;
  int _totalBeansAllImages = 0;
  int _totalDefectCountAllImages = 0;
  int _processedCount = 0;
  List<ScanRecord> _currentRecords = [];

  @override
  void initState() {
    super.initState();
    _processImage();
  }

  Future<void> _processImage() async {
    try {
      Map<String, int> aggregatedDetails = {};
      int totalDefectCount = 0;
      int totalBeans = 0;

      for (int i = 0; i < widget.imagePaths.length; i++) {
        final path = widget.imagePaths[i];
        final output = await widget.apiService.runInferenceOnImage(path);

        _batchOutputs.add(output);
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

      // Ambil data master dari Supabase / Cache
      final dbService = DatabaseService();
      final defectDict = await dbService.fetchDefectDictionary();
      final gradeRules = await dbService.fetchGradeRules();

      final sniResult = SniCalculator.evaluate(aggregatedDetails, defectDict, gradeRules);

      if (mounted) {
        List<ScanRecord> generatedRecords = [];
        final batchTimestamp = DateTime.now();
        for (int i = 0; i < widget.imagePaths.length; i++) {
          final output = _batchOutputs[i];
          final rawDets = output.detections.map((d) => {
            'class_index': d.classIndex,
            'confidence': d.confidence,
            'label': d.label,
            'bbox': {
              'left': d.boundingBox.left,
              'top': d.boundingBox.top,
              'right': d.boundingBox.right,
              'bottom': d.boundingBox.bottom,
            },
            'polygon': d.polygon.map((pt) => [pt.dx, pt.dy]).toList(),
          }).toList();

          final record = ScanRecord(
            timestamp: batchTimestamp,
            imagePath: widget.imagePaths[i],
            defectCount: totalDefectCount,
            defectScore: sniResult.totalScore,
            totalBeans: totalBeans,
            grade: sniResult.grade,
            defectDetails: aggregatedDetails,
            rawDetections: rawDets,
            imageWidth: output.imageWidth,
            imageHeight: output.imageHeight,
          );

          generatedRecords.add(record);
        }

        setState(() {
          _isProcessing = false;
          _totalBeansAllImages = totalBeans;
          _totalDefectCountAllImages = totalDefectCount;
          _currentRecords = generatedRecords;
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
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPageIndex = index;
              });
            },
            itemCount: widget.imagePaths.length,
            itemBuilder: (context, index) {
              final path = widget.imagePaths[index];
              final output = _batchOutputs.length > index ? _batchOutputs[index] : null;
              
              return Stack(
                fit: StackFit.expand,
                children: [
                  ColorFiltered(
                    colorFilter: const ColorFilter.matrix([
                      1.2, 0, 0, 0, 30,
                      0, 1.2, 0, 0, 30,
                      0, 0, 1.2, 0, 30,
                      0, 0, 0, 1, 0,
                    ]),
                    child: Image.file(
                      File(path),
                      fit: BoxFit.contain,
                    ),
                  ),
                  if (output != null && output.detections.isNotEmpty && output.imageWidth > 0 && output.imageHeight > 0)
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return CustomPaint(
                          painter: BoundingBoxPainter(
                            output != null ? output.detections : [],
                            output?.imageWidth ?? 1,
                            output?.imageHeight ?? 1,
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
        if (widget.imagePaths.length > 1)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            width: double.infinity,
            color: Colors.blue.withOpacity(0.8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.swipe, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Gambar ${_currentPageIndex + 1} dari ${widget.imagePaths.length}  •  Geser untuk melihat semua',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
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
                    if (_currentRecords.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GradeResultScreen(scanRecords: _currentRecords),
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
