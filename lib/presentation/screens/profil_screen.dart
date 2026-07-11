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
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import 'login_screen.dart';
import '../../providers/history_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'edit_profil_screen.dart';
import 'change_password_screen.dart';

class ProfilScreen extends ConsumerStatefulWidget {
  const ProfilScreen({super.key});

  @override
  ConsumerState<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends ConsumerState<ProfilScreen> {
  User? _user;

  @override
  void initState() {
    super.initState();
    _user = Supabase.instance.client.auth.currentUser;
  }

  void _handleLogout() async {
    await Supabase.instance.client.auth.signOut();
    if (!mounted) return;
    
    ref.invalidate(historyProvider);
    
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isGuest = _user == null;
    final String name = _user?.userMetadata?['full_name'] ?? 'Pengguna Tamu';
    final String email = _user?.email ?? 'Akses Sementara (Data disimpan lokal)';
    final String role = _user?.userMetadata?['role'] ?? 'Mode Tamu';
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
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.textSecondary.withOpacity(0.2),
                    backgroundImage: _user?.userMetadata?['avatar_url'] != null
                        ? NetworkImage(_user!.userMetadata!['avatar_url'])
                        : null,
                    child: _user?.userMetadata?['avatar_url'] == null
                        ? const Icon(Icons.person_outline, size: 40, color: AppColors.textSecondary)
                        : null,
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 20)),
                        const SizedBox(height: 4),
                        Text(email, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: isGuest ? AppColors.warning.withOpacity(0.2) : AppColors.accent.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(role, style: TextStyle(color: isGuest ? AppColors.warning : AppColors.secondary, fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            if (!isGuest)
              _buildMenuGroup(context, 'Pengaturan Akun', [
                _buildMenuItem(Icons.edit_outlined, 'Edit Profil', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const EditProfilScreen()),
                  ).then((_) => setState(() {
                    _user = Supabase.instance.client.auth.currentUser;
                  }));
                }),
                _buildMenuItem(Icons.lock_outline, 'Ganti Password', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ChangePasswordScreen()),
                  );
                }),
              ]),
            
            _buildMenuGroup(context, 'Aplikasi', [
              _buildMenuItem(Icons.info_outline, 'Tentang CQIS', () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('CQIS - Coffee Quality Inspection System v1.0')),
                );
              }),
              _buildMenuItem(Icons.help_outline, 'Panduan SNI 01-2907-2008', () async {
                final Uri url = Uri.parse('https://www.cctcid.com/wp-content/uploads/2018/08/SNI_2907-2008_Biji_Kopi-1.pdf');
                if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Tidak dapat membuka tautan panduan.')),
                    );
                  }
                }
              }),
            ]),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                child: isGuest
                  ? ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                          (Route<dynamic> route) => false,
                        );
                      },
                      icon: const Icon(Icons.login),
                      label: const Text('Daftar / Masuk Akun Penuh'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    )
                  : OutlinedButton.icon(
                      onPressed: _handleLogout,
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