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
import 'grade_result_screen.dart';

class HasilDeteksiScreen extends StatelessWidget {
  const HasilDeteksiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> detectedObjects = [
      {'kelas': 'Biji Hitam', 'jumlah': 3, 'warna': AppColors.danger},
      {'kelas': 'Biji Pecah', 'jumlah': 5, 'warna': AppColors.warning},
      {'kelas': 'Biji Normal', 'jumlah': 22, 'warna': AppColors.primary},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasil Deteksi', style: TextStyle(color: AppColors.textPrimary)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  const Center(child: Icon(Icons.image, size: 80, color: AppColors.secondary)),
                  Positioned(
                    top: 50, left: 60,
                    child: _buildMockBoundingBox('Hitam 0.9', AppColors.danger),
                  ),
                  Positioned(
                    top: 120, left: 150,
                    child: _buildMockBoundingBox('Normal 0.95', AppColors.primary),
                  ),
                  Positioned(
                    bottom: 80, right: 70,
                    child: _buildMockBoundingBox('Pecah 0.8', AppColors.warning),
                  ),
                ],
              ),
            ),
          ),
          
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(24.0),
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Ringkasan Batch Ini', style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 18)),
                  const SizedBox(height: 16),
                  
                  Expanded(
                    child: ListView.builder(
                      itemCount: detectedObjects.length,
                      itemBuilder: (context, index) {
                        final obj = detectedObjects[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(backgroundColor: obj['warna'], radius: 8),
                          title: Text(obj['kelas']),
                          trailing: Text('${obj['jumlah']} biji', style: const TextStyle(fontWeight: FontWeight.bold)),
                        );
                      },
                    ),
                  ),
                  
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context), // Kembali ke kamera
                          style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                          child: const Text('+ Tambah Batch'), //
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const GradeResultScreen()),
                            );
                          },
                          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                          child: const Text('Hitung Grade Akhir'), //
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMockBoundingBox(String label, Color color) {
    return Container(
      width: 60, height: 60,
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 2),
      ),
      child: Align(
        alignment: Alignment.topLeft,
        child: Container(
          color: color,
          padding: const EdgeInsets.all(2),
          child: Text(label, style: const TextStyle(color: AppColors.white, fontSize: 8)),
        ),
      ),
    );
  }
}