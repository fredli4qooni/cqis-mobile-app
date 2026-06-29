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
import '../../services/database_service.dart';
import '../../services/sni_calculator.dart';
import '../../services/pdf_service.dart';
import 'package:printing/printing.dart';
import 'main_screen.dart';

class GradeResultScreen extends StatelessWidget {
  final ScanRecord scanRecord;

  const GradeResultScreen({super.key, required this.scanRecord});

  String _getGradeDescription(String grade) {
    switch (grade) {
      case "Mutu 1": return "Kualitas Ekspor Premium (Sangat Baik)";
      case "Mutu 2": return "Kualitas Baik untuk Ekspor";
      case "Mutu 3": return "Kualitas Standar Ekspor";
      case "Mutu 4a": return "Kualitas Menengah Atas";
      case "Mutu 4b": return "Kualitas Menengah Bawah";
      case "Mutu 5": return "Kualitas Lokal Biasa";
      case "Mutu 6": return "Kualitas Rendah (Reject)";
      default: return "Tidak terdefinisi";
    }
  }

  double _getMaxScoreForGrade(String grade) {
    switch (grade) {
      case "Mutu 1": return 11;
      case "Mutu 2": return 25;
      case "Mutu 3": return 44;
      case "Mutu 4a": return 60;
      case "Mutu 4b": return 80;
      case "Mutu 5": return 150;
      default: return 225;
    }
  }

  @override
  Widget build(BuildContext context) {
    final defectDetails = scanRecord.defectDetails;


    final defectsOnly = defectDetails.entries
        .where((e) => e.key != 'normal' && e.value > 0)
        .toList();


    final List<Color> chartColors = [
      const Color(0xFFE63946),
      const Color(0xFFF4A261),
      const Color(0xFFE9C46A),
      const Color(0xFF2A9D8F),
      const Color(0xFF264653),
      const Color(0xFF8AB17D),
      const Color(0xFFB56576),
      const Color(0xFF355070),
      const Color(0xFF6D597A),
      const Color(0xFFEAAC8B),
      const Color(0xFF118AB2),
      const Color(0xFF06D6A0),
      const Color(0xFFFFD166),
      const Color(0xFFEF476F),
      const Color(0xFF073B4C),
      const Color(0xFF8338EC),
      const Color(0xFFFF006E),
      const Color(0xFF3A86FF),
      const Color(0xFF00B4D8),
      const Color(0xFFFB8500),
    ];

    List<PieChartSectionData> pieSections = [];
    int colorIndex = 0;

    if (defectsOnly.isEmpty) {

      pieSections.add(PieChartSectionData(
        color: AppColors.secondary,
        value: 1,
        title: '',
        radius: 20
      ));
    } else {
      for (var defect in defectsOnly) {
        double weight = SniCalculator.getDefectWeight(defect.key);
        double value = defect.value * weight;

        pieSections.add(
          PieChartSectionData(
            color: chartColors[colorIndex % chartColors.length],
            value: value,
            title: '',
            radius: 20,
          )
        );
        colorIndex++;
      }
    }

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
                color: AppColors.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.secondary),
              ),
              child: Column(
                children: [
                  Text('GRADE', style: Theme.of(context).textTheme.bodyLarge?.copyWith(letterSpacing: 2)),
                  Text(scanRecord.grade.toUpperCase(), style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 48, color: AppColors.primary)),
                  const SizedBox(height: 8),
                  Text(_getGradeDescription(scanRecord.grade), style: const TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Text(
              'Total Nilai Cacat: ${scanRecord.defectScore.toStringAsFixed(1)} / Batas Mutu: ${_getMaxScoreForGrade(scanRecord.grade).toStringAsFixed(0)}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                      sections: pieSections,
                    ),
                  ),
                  Text(
                    scanRecord.defectScore.toStringAsFixed(1),
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primary)
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            Align(
              alignment: Alignment.centerLeft,
              child: Text('Rincian Cacat (SNI 01-2907-2008)', style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 18)),
            ),
            const SizedBox(height: 16),
            Table(
              border: TableBorder.all(color: AppColors.textSecondary.withOpacity(0.2)),
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(1),
              },
              children: [
                const TableRow(
                  decoration: BoxDecoration(color: AppColors.primary),
                  children: [
                    Padding(padding: EdgeInsets.all(8.0), child: Text('Kelas', style: TextStyle(color: AppColors.white))),
                    Padding(padding: EdgeInsets.all(8.0), child: Text('Jml', style: TextStyle(color: AppColors.white), textAlign: TextAlign.center)),
                    Padding(padding: EdgeInsets.all(8.0), child: Text('Nilai', style: TextStyle(color: AppColors.white), textAlign: TextAlign.center)),
                  ],
                ),
                ...defectsOnly.map((defect) {
                  double weight = SniCalculator.getDefectWeight(defect.key);
                  double totalValue = defect.value * weight;
                  return TableRow(
                    children: [
                      Padding(padding: const EdgeInsets.all(8.0), child: Text(SniCalculator.getLabelName(defect.key))),
                      Padding(padding: const EdgeInsets.all(8.0), child: Text('${defect.value}', textAlign: TextAlign.center)),
                      Padding(padding: const EdgeInsets.all(8.0), child: Text(totalValue.toStringAsFixed(1), textAlign: TextAlign.center)),
                    ],
                  );
                }).toList(),
              ],
            ),
            const SizedBox(height: 32),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      try {
                        await Printing.layoutPdf(
                          onLayout: (format) async => await PdfService.generateQualityReport(scanRecord),
                          name: 'Laporan_Mutu_CQIS_${scanRecord.id ?? "NEW"}.pdf',
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Gagal membuat PDF: $e')),
                        );
                      }
                    },
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('Ekspor PDF'),
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