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

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> onboardingData = [
    {
      "title": "Grading Manual Memakan Waktu?",
      "description": "CQIS Solusinya.",
      "image": "assets/images/onboarding_1.png",
    },
    {
      "title": "Deteksi Otomatis",
      "description":
          "Foto biji kopi, AI kami deteksi 20 jenis kondisi secara otomatis.",
      "image": "assets/images/onboarding_2.png",
    },
    {
      "title": "Hasil Sesuai Standar",
      "description":
          "Dapatkan grade mutu SNI 01-2907-2008 dalam hitungan detik.",
      "image": "assets/images/onboarding_3.png",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
                child: const Text(
                  "Lewati",
                  style: TextStyle(color: AppColors.secondary),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (value) => setState(() => _currentPage = value),
                itemCount: onboardingData.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 300,
                          width: double.infinity,
                          child: Image.asset(
                            onboardingData[index]["image"]!,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 48),
                        Text(
                          onboardingData[index]["title"]!,
                          style: Theme.of(context).textTheme.displayLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          onboardingData[index]["description"]!,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(color: AppColors.textSecondary),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 32.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(
                      onboardingData.length,
                      (index) => buildDot(index, context),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_currentPage == onboardingData.length - 1) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeIn,
                        );
                      }
                    },
                    child: Text(
                      _currentPage == onboardingData.length - 1
                          ? "Mulai"
                          : "Lanjut",
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDot(int index, BuildContext context) {
    return Container(
      height: 8,
      width: _currentPage == index ? 24 : 8,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: _currentPage == index
            ? AppColors.primary
            : AppColors.accent.withValues(alpha: 0.5),
      ),
    );
  }
}
