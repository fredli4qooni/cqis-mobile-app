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
import 'pre_condition_screen.dart';
import 'riwayat_screen.dart';
import 'grade_result_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> recentScans = [
      {'date': '12 Mei 2026', 'grade': 'Mutu 1', 'color': AppColors.primary},
      {'date': '10 Mei 2026', 'grade': 'Mutu 2', 'color': AppColors.secondary},
      {'date': '08 Mei 2026', 'grade': 'Mutu 4a', 'color': AppColors.warning},
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Row(
          children: [
            const Icon(Icons.coffee_rounded, color: AppColors.white),
            const SizedBox(width: 8),
            Text(
              'CQIS',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                color: AppColors.white,
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_outlined,
              color: AppColors.white,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.account_circle, color: AppColors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selamat datang, Budi!',
              style: Theme.of(
                context,
              ).textTheme.displayLarge?.copyWith(fontSize: 22),
            ),
            const SizedBox(height: 4),
            Text(
              'Siap menyeleksi kopi hari ini?',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),

            Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PreConditionScreen(),
                      ),
                    );
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.document_scanner,
                        size: 40,
                        color: AppColors.white,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Mulai Seleksi Mutu',
                        style: Theme.of(context).textTheme.displayLarge
                            ?.copyWith(color: AppColors.white, fontSize: 18),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Scan Terakhir',
                  style: Theme.of(
                    context,
                  ).textTheme.displayLarge?.copyWith(fontSize: 18),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RiwayatScreen()),
                    );
                  }, 
                  child: const Text('Lihat Semua', style: TextStyle(color: AppColors.secondary))
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 140,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: recentScans.length,
                itemBuilder: (context, index) {
                  final scan = recentScans[index];
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const GradeResultScreen(),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 140,
                      margin: const EdgeInsets.only(right: 16),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.textSecondary.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 70,
                            decoration: BoxDecoration(
                              color: AppColors.accent.withValues(alpha: 0.2),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.image,
                                color: AppColors.secondary,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: scan['color'].withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    scan['grade'],
                                    style: TextStyle(
                                      color: scan['color'],
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  scan['date'],
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),

            Text(
              'Info Standar SNI',
              style: Theme.of(
                context,
              ).textTheme.displayLarge?.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 0,
              color: AppColors.white,
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: AppColors.textSecondary.withValues(alpha: 0.1),
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: AppColors.primary,
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Grade Mutu 1',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Batas nilai cacat maksimal adalah 11 per 300 gram sampel.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
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