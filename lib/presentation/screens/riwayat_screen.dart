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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/history_provider.dart';
import '../../services/database_service.dart';
import 'grade_result_screen.dart';

class RiwayatScreen extends ConsumerStatefulWidget {
  const RiwayatScreen({super.key});

  @override
  ConsumerState<RiwayatScreen> createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends ConsumerState<RiwayatScreen> {
  String _selectedFilter = 'Semua';
  final List<String> _filters = ['Semua', 'Mutu 1', 'Mutu 2', 'Mutu 3', 'Mutu 4', 'Mutu 5', 'Mutu 6'];

  Color _getGradeColor(String grade) {
    switch (grade) {
      case "Mutu 1": return AppColors.primary;
      case "Mutu 2": return AppColors.secondary;
      case "Mutu 3": return AppColors.secondary;
      case "Mutu 4a": return AppColors.warning;
      case "Mutu 4b": return AppColors.warning;
      case "Mutu 5": return AppColors.warning;
      default: return AppColors.danger;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scansAsync = ref.watch(historyProvider);

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
                        setState(() {
                          _selectedFilter = filter;
                        });
                      },
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      backgroundColor: AppColors.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected ? AppColors.primary : AppColors.textSecondary.withOpacity(0.2),
                        )
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          
          Expanded(
            child: scansAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
              error: (error, stack) => Center(child: Text('Error: $error')),
              data: (scans) {
                final filteredData = _selectedFilter == 'Semua' 
                    ? scans 
                    : scans.where((item) => item.grade.startsWith(_selectedFilter)).toList();

                if (filteredData.isEmpty) {
                  return Center(
                    child: Text('Tidak ada riwayat untuk filter $_selectedFilter', style: const TextStyle(color: AppColors.textSecondary)),
                  );
                }

                final Map<String, List<ScanRecord>> groupedScans = {};
                for (var scan in filteredData) {
                  final key = scan.timestamp.toIso8601String().substring(0, 19);
                  if (!groupedScans.containsKey(key)) {
                    groupedScans[key] = [];
                  }
                  groupedScans[key]!.add(scan);
                }

                final sortedKeys = groupedScans.keys.toList()..sort((a, b) => b.compareTo(a));

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: sortedKeys.length,
                  itemBuilder: (context, index) {
                    final key = sortedKeys[index];
                    final batch = groupedScans[key]!;
                    final item = batch.first;
                    final color = _getGradeColor(item.grade);
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GradeResultScreen(scanRecords: batch),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Container(
                                height: 60, width: 60,
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    item.grade.replaceAll('Mutu ', 'M'), 
                                    style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18)
                                  )
                                ),
                              ),
                              const SizedBox(width: 16),
                              
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('SCAN-${item.id?.toString().padLeft(3, '0') ?? 'NEW'}', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    Text(item.timestamp.toString().substring(0, 16), style: Theme.of(context).textTheme.bodyLarge),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Text('Nilai Cacat: ${item.defectScore.toStringAsFixed(1)}', style: Theme.of(context).textTheme.bodyMedium),
                                        if (batch.length > 1) ...[
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(4)),
                                            child: Text('${batch.length} Gbr', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                          )
                                        ]
                                      ],
                                    ),
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
                );
              }
            ),
          ),
        ],
      ),
    );
  }
}