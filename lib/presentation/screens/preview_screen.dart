/*
 * ============================================================================
 * Copyright (c) 2026 Fredli Fourqoni. All rights reserved.
 * 
 * This file is part of CQIS (Coffee Quality Inspection System), which is licensed under the 
 * PolyForm Noncommercial License 1.0.0.
 * 
 * You may not use this file except in compliance with the License.
 * A copy of the License is located in the root directory of this project or at:
 * https://polyformproject.org/licenses/noncommercial/1.0.0
 * 
 * STRICT WARNING: Commercial use, reproduction, and distribution of this 
 * code for business or profit purposes are STRICTLY PROHIBITED.
 * ============================================================================
 */

import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'hasil_deteksi_screen.dart';

class PreviewScreen extends StatefulWidget {
  const PreviewScreen({super.key});

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  bool _isAnalyzing = false;

  void _startAnalysis() async {
    setState(() => _isAnalyzing = true);
    
    await Future.delayed(const Duration(seconds: 3));
    
    if (!mounted) return;
    setState(() => _isAnalyzing = false);
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HasilDeteksiScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Container(
                color: AppColors.background,
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.7,
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.image_outlined, size: 100, color: AppColors.secondary),
                      SizedBox(height: 16),
                      Text('Mock Gambar Kopi Hasil Foto', style: TextStyle(color: AppColors.secondary)),
                    ],
                  ),
                ),
              ),
            ),

            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(8)),
                child: const Text(
                  'Pastikan biji kopi tersebar rata dan tidak menumpuk',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.white),
                ),
              ),
            ),

            Positioned(
              bottom: 24,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isAnalyzing ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.white,
                        side: const BorderSide(color: AppColors.white),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Ulang Foto'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isAnalyzing ? null : _startAnalysis,
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                      child: const Text('Analisis Sekarang'),
                    ),
                  ),
                ],
              ),
            ),

            if (_isAnalyzing)
              Container(
                color: Colors.black.withValues(alpha: 0.7),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: AppColors.accent),
                      SizedBox(height: 24),
                      Text('Mendeteksi biji kopi...', style: TextStyle(color: AppColors.white, fontSize: 16)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}