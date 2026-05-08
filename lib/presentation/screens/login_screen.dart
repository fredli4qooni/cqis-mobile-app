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
import '../widgets/custom_text_field.dart';
import 'register_screen.dart';
import 'main_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  void _handleLogin() async {
    setState(() => _isLoading = true);
    
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;
    setState(() => _isLoading = false);
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              const Center(
                child: Icon(Icons.coffee_rounded, size: 60, color: AppColors.primary),
              ),
              const SizedBox(height: 24),
              Text(
                'Masuk ke Akun Anda',
                style: Theme.of(context).textTheme.displayLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              
              const CustomTextField(
                label: 'Email',
                hint: 'Masukkan email Anda',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              
              CustomTextField(
                label: 'Password',
                hint: 'Masukkan password Anda',
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
              
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                  },
                  child: const Text('Lupa password?', style: TextStyle(color: AppColors.secondary)),
                ),
              ),
              const SizedBox(height: 24),
              
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2),
                        )
                      : const Text('Masuk', style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 24),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Belum punya akun?', style: TextStyle(color: AppColors.textSecondary)),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RegisterScreen()),
                      );
                    },
                    child: const Text('Daftar Sekarang', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}