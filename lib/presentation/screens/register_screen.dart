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
import '../widgets/custom_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String _selectedRole = 'Petani';
  
  final List<String> _roles = ['Petani', 'Pengepul', 'Pedagang'];

  void _handleRegister() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isLoading = false);
    
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Registrasi Berhasil'),
        content: const Text('Cek email untuk verifikasi akun Anda.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('OK', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Buat Akun Baru',
              style: Theme.of(context).textTheme.displayLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Lengkapi data di bawah untuk mendaftar.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 32),
            
            const CustomTextField(
              label: 'Nama Lengkap',
              hint: 'Masukkan nama lengkap',
            ),
            const SizedBox(height: 16),
            
            const CustomTextField(
              label: 'Email',
              hint: 'Masukkan email aktif',
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            
            Text(
              'Peran (Role)',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _selectedRole,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.textSecondary.withValues(alpha: 0.2)),
                ),
              ),
              items: _roles.map((String role) {
                return DropdownMenuItem(value: role, child: Text(role));
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedRole = newValue!;
                });
              },
            ),
            const SizedBox(height: 16),
            
            CustomTextField(
              label: 'Password',
              hint: 'Minimal 8 karakter',
              isPassword: !_isPasswordVisible,
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: AppColors.textSecondary,
                ),
                onPressed: () {
                  setState(() => _isPasswordVisible = !_isPasswordVisible);
                },
              ),
            ),
            const SizedBox(height: 16),
            
            const CustomTextField(
              label: 'Konfirmasi Password',
              hint: 'Ketik ulang password',
              isPassword: true,
            ),
            const SizedBox(height: 32),
            
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleRegister,
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2),
                      )
                    : const Text('Daftar', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}