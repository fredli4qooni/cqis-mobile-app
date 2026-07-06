import 'database_service.dart';

class SniCalculationResult {
  final double totalScore;
  final String grade;

  SniCalculationResult(this.totalScore, this.grade);
}

class SniCalculator {
  // Mapping dari label AI ke Kode Cacat di Database
  static const Map<String, String> labelToCode = {
    'hitam': 'D01',
    'hitam_sebagian': 'D02',
    'hitam_pecah': 'D03',
    'gelondong': 'D04',
    'coklat': 'D05',
    'kulit_tanduk': 'D06',
    'kulit_kopi': 'D07',
    'biji_pecah': 'D08',
    'pecah': 'D08',
    'muda': 'D09',
    'berlubang_satu': 'D10',
    'lubang_satu': 'D10',
    'berlubang_banyak': 'D11',
    'lubang_lebih_dari_satu': 'D11',
    'berkulit_tanduk': 'D12',
    'benda_lain': 'D13',
    'ranting': 'D13',
    'tanah': 'D13',
    'batu': 'D13',
  };

  static String getLabelName(String label, List<DefectDictionary> dictionary) {
    if (label == 'normal') return 'Normal';
    
    String? code = labelToCode[label];
    if (code != null) {
      try {
        final def = dictionary.firstWhere((d) => d.code == code);
        return def.name;
      } catch (_) {}
    }
    return label; // Fallback ke label asli jika tidak ditemukan
  }

  static double getDefectWeight(String label, List<DefectDictionary> dictionary) {
    if (dictionary.isEmpty) return 0.0; // Fallback aman
    
    String? code = labelToCode[label];
    if (code != null) {
      try {
        final def = dictionary.firstWhere((d) => d.code == code);
        return def.penaltyScore;
      } catch (_) {}
    }
    return 0.0;
  }

  static String determineGrade(double score, List<GradeRule> rules) {
    if (rules.isEmpty) {
      // Fallback statis jika gagal mengambil data dari Supabase
      if (score <= 11) return "Mutu 1";
      if (score <= 25) return "Mutu 2";
      if (score <= 44) return "Mutu 3";
      if (score <= 60) return "Mutu 4a";
      if (score <= 80) return "Mutu 4b";
      if (score <= 150) return "Mutu 5";
      return "Mutu 6";
    }

    // Urutkan berdasarkan batas bawah (min_defect)
    rules.sort((a, b) => a.minDefect.compareTo(b.minDefect));
    
    for (var rule in rules) {
      // Mengatasi nilai desimal dengan margin kecil agar cocok dengan batasan <=
      if (score >= rule.minDefect && score <= rule.maxDefect) {
        return rule.gradeName;
      }
    }
    
    // Fallback ke grade terakhir jika score di atas semua aturan
    return rules.last.gradeName;
  }

  static SniCalculationResult evaluate(
    Map<String, int> defectDetails, 
    List<DefectDictionary> dictionary, 
    List<GradeRule> rules
  ) {
    double totalScore = 0;

    defectDetails.forEach((label, count) {
      if (label != 'normal') {
        totalScore += count * getDefectWeight(label, dictionary);
      }
    });

    String grade = determineGrade(totalScore, rules);

    return SniCalculationResult(totalScore, grade);
  }
}
