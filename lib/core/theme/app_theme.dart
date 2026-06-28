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
import 'package:google_fonts/google_fonts.dart';

class AppColors {

  static const Color primary = Color(0xFF064E3B);
  static const Color secondary = Color(0xFF10B981);
  static const Color accent = Color(0xFFD4AF37);

  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);

  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color white = Color(0xFFFFFFFF);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        error: AppColors.danger,
        surface: AppColors.white,
      ),

      textTheme: TextTheme(
        displayLarge: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        bodyLarge: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.normal, color: AppColors.textPrimary),
        bodyMedium: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.normal, color: AppColors.textSecondary),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 2,
        ),
      ),

      cardTheme: CardThemeData(
        color: AppColors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}