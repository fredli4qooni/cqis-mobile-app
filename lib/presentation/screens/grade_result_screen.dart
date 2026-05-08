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
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_theme.dart';
import 'main_screen.dart';

class GradeResultScreen extends StatelessWidget {
  const GradeResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasil Seleksi Mutu', style: TextStyle(color: AppColors.textPrimary)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.secondary),
              ),
              child: Column(
                children: [
                  Text('GRADE', style: Theme.of(context).textTheme.bodyLarge?.copyWith(letterSpacing: 2)),
                  Text('MUTU 2', style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 48, color: AppColors.primary)),
                  const SizedBox(height: 8),
                  const Text('Kualitas baik untuk ekspor', style: TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            const Text(
              'Total Nilai Cacat: 18.5 / Batas Mutu 2: 25',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 32),

            SizedBox(
              height: 200,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 60,
                      sections: [
                        PieChartSectionData(color: AppColors.danger, value: 5, title: '', radius: 20),
                        PieChartSectionData(color: AppColors.warning, value: 3.5, title: '', radius: 20),
                        PieChartSectionData(color: AppColors.accent, value: 10, title: '', radius: 20),
                      ],
                    ),
                  ),
                  const Text('18.5', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primary)),
                ],
              ),
            ),
            const SizedBox(height: 32),

            Align(
              alignment: Alignment.centerLeft,
              child: Text('Rincian Cacat', style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 18)),
            ),
            const SizedBox(height: 16),
            Table(
              border: TableBorder.all(color: AppColors.textSecondary.withValues(alpha: 0.2)),
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(1),
              },
              children: const [
                TableRow(
                  decoration: BoxDecoration(color: AppColors.primary),
                  children: [
                    Padding(padding: EdgeInsets.all(8.0), child: Text('Kelas', style: TextStyle(color: AppColors.white))),
                    Padding(padding: EdgeInsets.all(8.0), child: Text('Jml', style: TextStyle(color: AppColors.white), textAlign: TextAlign.center)),
                    Padding(padding: EdgeInsets.all(8.0), child: Text('Nilai', style: TextStyle(color: AppColors.white), textAlign: TextAlign.center)),
                  ],
                ),
                TableRow(
                  children: [
                    Padding(padding: EdgeInsets.all(8.0), child: Text('Biji Hitam Penuh')),
                    Padding(padding: EdgeInsets.all(8.0), child: Text('5', textAlign: TextAlign.center)),
                    Padding(padding: EdgeInsets.all(8.0), child: Text('5', textAlign: TextAlign.center)),
                  ],
                ),
                TableRow(
                  children: [
                    Padding(padding: EdgeInsets.all(8.0), child: Text('Biji Pecah')),
                    Padding(padding: EdgeInsets.all(8.0), child: Text('10', textAlign: TextAlign.center)),
                    Padding(padding: EdgeInsets.all(8.0), child: Text('2', textAlign: TextAlign.center)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {}, 
                    icon: const Icon(Icons.picture_as_pdf), 
                    label: const Text('Ekspor PDF'), //
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const MainScreen()),
                        (Route<dynamic> route) => false,
                      );
                    },
                    icon: const Icon(Icons.check),
                    label: const Text('Simpan & Selesai'),
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}