import 'dart:convert';
import 'dart:ui';
import 'package:http/http.dart' as http;



class DetectionResult {
  final int classIndex;
  final String label;
  final double confidence;
  final Rect boundingBox;
  final String sizeCategory;
  final List<Offset> polygon;

  DetectionResult({
    required this.classIndex,
    required this.label,
    required this.confidence,
    required this.boundingBox,
    required this.sizeCategory,
    this.polygon = const [],
  });
}

class InferenceOutput {
  final List<DetectionResult> detections;
  final int imageWidth;
  final int imageHeight;

  InferenceOutput(this.detections, this.imageWidth, this.imageHeight);
}

class ApiService {

  final String baseUrl = 'http://202.134.242.63:5000';

  Future<void> loadModel() async {

    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<InferenceOutput> runInferenceOnImage(String imagePath) async {
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/predict'));
    request.files.add(await http.MultipartFile.fromPath('file', imagePath));

    try {
      var streamedResponse = await request.send().timeout(const Duration(seconds: 15));
      var response = await http.Response.fromStream(streamedResponse).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);

        int imageWidth = jsonResponse['image_width'];
        int imageHeight = jsonResponse['image_height'];

        List<DetectionResult> results = [];

        for (var det in jsonResponse['detections']) {
          var bbox = det['bbox'];
          Rect rect = Rect.fromLTRB(
            (bbox['left'] as num).toDouble(),
            (bbox['top'] as num).toDouble(),
            (bbox['right'] as num).toDouble(),
            (bbox['bottom'] as num).toDouble(),
          );

          List<Offset> polygon = [];
          if (det['polygon'] != null) {
            for (var pt in det['polygon']) {
              polygon.add(Offset((pt[0] as num).toDouble(), (pt[1] as num).toDouble()));
            }
          }

          String rawLabel = det['label'].toString().toLowerCase().trim();
          String finalLabel = (rawLabel == 'coklat' || rawLabel == 'cokelat') ? 'normal' : det['label'];

          results.add(DetectionResult(
            classIndex: det['class_index'],
            label: finalLabel,
            confidence: (det['confidence'] as num).toDouble(),
            boundingBox: rect,
            sizeCategory: '',
            polygon: polygon,
          ));
        }

        return InferenceOutput(results, imageWidth, imageHeight);
      } else {
        throw Exception("Server Error: ${response.body}");
      }
    } catch (e) {
      throw Exception("Gagal terhubung ke API Server: $e\nPastikan script app.py berjalan dan IP Laptop benar.");
    }
  }

  void dispose() {

  }


}
