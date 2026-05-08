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
import 'preview_screen.dart';

class CameraScreen extends StatelessWidget {
  const CameraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            const Center(
              child: Icon(Icons.camera_alt, color: Colors.white24, size: 100),
            ),

            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.width * 0.8,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.white, width: 2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Letakkan biji kopi di sini', style: TextStyle(color: AppColors.white)),
                  ),
                ),
              ),
            ),

            Positioned(
              top: 40,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Text(
                    'Sebar 20-30 biji, jarak kamera 20-25cm, latar putih',
                    style: TextStyle(color: AppColors.white, fontSize: 12),
                  ),
                ),
              ),
            ),

            Positioned(
              top: 16,
              left: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: AppColors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),

            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.photo_library, color: AppColors.white, size: 30),
                    onPressed: () {
                    },
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const PreviewScreen()),
                      );
                    },
                    child: Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.white, width: 4),
                      ),
                      child: Center(
                        child: Container(
                          height: 64,
                          width: 64,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.flash_off, color: AppColors.white, size: 30),
                    onPressed: () {
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}