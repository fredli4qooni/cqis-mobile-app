import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class BoundingBoxPainter extends CustomPainter {
  final List<DetectionResult> results;
  final int imageWidth;
  final int imageHeight;

  BoundingBoxPainter(this.results, this.imageWidth, this.imageHeight);

  @override
  void paint(Canvas canvas, Size size) {
    if (imageWidth == 0 || imageHeight == 0) return;

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
        text: result.label,
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
