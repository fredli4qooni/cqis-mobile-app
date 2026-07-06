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
import 'camera_screen.dart';

class PreConditionScreen extends StatefulWidget {
  const PreConditionScreen({super.key});

  @override
  State<PreConditionScreen> createState() => _PreConditionScreenState();
}

class _PreConditionScreenState extends State<PreConditionScreen> {
  bool isMoistureValid = false;
  bool isNoInsects = false;
  bool isNoBadOdor = false;
  bool isSampleWeighed = false;

  bool get isAllChecked => isMoistureValid && isNoInsects && isNoBadOdor && isSampleWeighed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Persiapan Sebelum Scan', style: TextStyle(color: AppColors.textPrimary)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pastikan kondisi berikut sebelum memulai seleksi mutu sesuai SNI 01-2907-2008 Pasal 5.1.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 32),

            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              activeColor: AppColors.primary,
              title: const Text('Kadar air biji kopi < 12.5%'),
              value: isMoistureValid,
              onChanged: (val) => setState(() => isMoistureValid = val ?? false),
              secondary: const Icon(Icons.water_drop_outlined, color: AppColors.secondary),
            ),
            const Divider(),

            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              activeColor: AppColors.primary,
              title: const Text('Tidak ada serangga hidup di dalam biji kopi'),
              value: isNoInsects,
              onChanged: (val) => setState(() => isNoInsects = val ?? false),
              secondary: const Icon(Icons.bug_report_outlined, color: AppColors.secondary),
            ),
            const Divider(),

            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              activeColor: AppColors.primary,
              title: const Text('Tidak ada biji kopi berbau busuk atau berjamur'),
              value: isNoBadOdor,
              onChanged: (val) => setState(() => isNoBadOdor = val ?? false),
              secondary: const Icon(Icons.coronavirus_outlined, color: AppColors.secondary),
            ),
            const Divider(),

            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              activeColor: AppColors.primary,
              title: const Text('Timbang sampel kopi sebanyak 300 gram (bagi ke bbrp foto jika banyak)'),
              value: isSampleWeighed,
              onChanged: (val) => setState(() => isSampleWeighed = val ?? false),
              secondary: const Icon(Icons.scale_outlined, color: AppColors.secondary),
            ),
            
            const Spacer(),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: AppColors.textSecondary),
                    ),
                    child: const Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: isAllChecked 
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const CameraScreen()),
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Lanjutkan ke Scan'),
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