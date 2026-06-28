import 'package:flutter_test/flutter_test.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:io';

void main() {
  test('Check Model Tensors', () async {
    final interpreter = await Interpreter.fromFile(File('assets/models/best.tflite'));
    print("Input tensors:");
    for (var tensor in interpreter.getInputTensors()) {
      print("${tensor.name}: ${tensor.shape} (type: ${tensor.type})");
    }
    print("\nOutput tensors:");
    for (var tensor in interpreter.getOutputTensors()) {
      print("${tensor.name}: ${tensor.shape} (type: ${tensor.type})");
    }
  });
}
