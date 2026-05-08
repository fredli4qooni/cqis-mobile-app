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

class RiwayatScreen extends StatefulWidget {
  const RiwayatScreen({super.key});

  @override
  State<RiwayatScreen> createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends State<RiwayatScreen> {
  String _selectedFilter = 'Semua';
  final List<String> _filters = ['Semua', 'Mutu 1', 'Mutu 2', 'Mutu 3', 'Mutu 4'];

  final List<Map<String, dynamic>> _riwayatData = [
    {'id': 'SCAN-001', 'date': '08 Mei 2026, 14:30', 'grade': 'Mutu 1', 'defect': 8.0, 'color': AppColors.primary},
    {'id': 'SCAN-002', 'date': '07 Mei 2026, 09:15', 'grade': 'Mutu 2', 'defect': 18.5, 'color': AppColors.secondary},
    {'id': 'SCAN-003', 'date': '05 Mei 2026, 16:45', 'grade': 'Mutu 4a', 'defect': 65.0, 'color': AppColors.warning},
    {'id': 'SCAN-004', 'date': '01 Mei 2026, 10:00', 'grade': 'Mutu 1', 'defect': 10.5, 'color': AppColors.primary},
  ];

  @override
  Widget build(BuildContext context) {
    final filteredData = _selectedFilter == 'Semua' 
        ? _riwayatData 
        : _riwayatData.where((item) => item['grade'].toString().startsWith(_selectedFilter)).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Seleksi', style: TextStyle(color: AppColors.textPrimary)),
        backgroundColor: AppColors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filters.map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(filter),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() => _selectedFilter = filter);
                      },
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: isSelected ? AppColors.white : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      backgroundColor: AppColors.background,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredData.length,
              itemBuilder: (context, index) {
                final item = filteredData[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const GradeResultScreen()),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Container(
                            height: 60, width: 60,
                            decoration: BoxDecoration(
                              color: item['color'].withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(child: Text(item['grade'].toString().replaceAll('Mutu ', 'M'), style: TextStyle(color: item['color'], fontWeight: FontWeight.bold, fontSize: 18))),
                          ),
                          const SizedBox(width: 16),
                          
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item['id'], style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text(item['date'], style: Theme.of(context).textTheme.bodyLarge),
                                const SizedBox(height: 4),
                                Text('Nilai Cacat: ${item['defect']}', style: Theme.of(context).textTheme.bodyMedium),
                              ],
                            ),
                          ),
                          
                          const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}