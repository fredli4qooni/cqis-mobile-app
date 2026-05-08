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
import 'login_screen.dart';

class ProfilScreen extends StatelessWidget {
  const ProfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya', style: TextStyle(color: AppColors.textPrimary)),
        backgroundColor: AppColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24.0),
              color: AppColors.white,
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.secondary,
                    child: Icon(Icons.person, size: 40, color: AppColors.white),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Budi Santoso', style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 20)),
                        const SizedBox(height: 4),
                        const Text('budi.petani@email.com', style: TextStyle(color: AppColors.textSecondary)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Text('Petani Kopi', style: TextStyle(color: AppColors.secondary, fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),

            _buildMenuGroup(context, 'Pengaturan Akun', [
              _buildMenuItem(Icons.edit_outlined, 'Edit Profil', () {}),
              _buildMenuItem(Icons.lock_outline, 'Ganti Password', () {}),
            ]),
            
            _buildMenuGroup(context, 'Data & Aplikasi', [
              _buildMenuItem(Icons.download_outlined, 'Ekspor Semua Riwayat (CSV)', () {}),
              _buildMenuItem(Icons.info_outline, 'Tentang CQIS', () {}),
              _buildMenuItem(Icons.help_outline, 'Panduan SNI 01-2907-2008', () {}),
            ]),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (Route<dynamic> route) => false,
                    );
                  },
                  icon: const Icon(Icons.logout, color: AppColors.danger),
                  label: const Text('Keluar Aplikasi', style: TextStyle(color: AppColors.danger)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: AppColors.danger),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuGroup(BuildContext context, String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Text(title, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary)),
        ),
        Container(
          color: AppColors.white,
          child: Column(children: items),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      onTap: onTap,
    );
  }
}