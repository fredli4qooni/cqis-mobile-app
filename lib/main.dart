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
import 'core/theme/app_theme.dart';
import 'presentation/screens/splash_screen.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await initializeDateFormatting('id_ID', null);
  
  await Supabase.initialize(
    url: 'https://creqgridjdxxbopqzoaq.supabase.co',
    publishableKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNyZXFncmlkamR4eGJvcHF6b2FxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODI3MjAwMzIsImV4cCI6MjA5ODI5NjAzMn0.0Xl4N5ljr2eC3lcXjf2fSpe1SWYQqC1pBitya1dj0gk',
  );

  runApp(const ProviderScope(child: CQISApp()));
}

class CQISApp extends StatelessWidget {
  const CQISApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CQIS',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}