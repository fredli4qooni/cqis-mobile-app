class SniCalculationResult {
  final double totalScore;
  final String grade;

  SniCalculationResult(this.totalScore, this.grade);
}

class SniCalculator {

  static const double bijiHitam = 1.0;
  static const double bijiHitamSebagian = 0.5;
  static const double bijiHitamPecah = 0.5;
  static const double gelondong = 1.0;
  static const double cokelat = 0.25;
  static const double kulitTanduk = 0.2;
  static const double bijiPecah = 0.04;
  static const double muda = 0.04;
  static const double berlubangSatu = 0.02;
  static const double berlubangBanyak = 0.1;
  static const double berkulitAri = 0.01;
  static const double bendaLain = 2.0;


  static String getLabelName(String label) {
    switch (label) {
      case 'hitam': return 'Biji Hitam';
      case 'hitam_sebagian': return 'Biji Hitam Sebagian';
      case 'hitam_pecah': return 'Biji Hitam Pecah';
      case 'gelondong': return 'Gelondong';
      case 'coklat': return 'Biji Cokelat';
      case 'kulit_tanduk': return 'Kulit Tanduk';
      case 'biji_pecah': return 'Biji Pecah';
      case 'muda': return 'Biji Muda';
      case 'berlubang_satu': return 'Biji Berlubang Satu';
      case 'berlubang_banyak': return 'Biji Berlubang Lebih Dari Satu';
      case 'berkulit_tanduk': return 'Biji Berkulit Ari / Tanduk';
      case 'kulit_kopi': return 'Kulit Kopi (Buah/Tanduk)';
      case 'benda_lain': return 'Benda Asing (Ranting/Tanah)';
      default: return label;
    }
  }


  static double getDefectWeight(String label) {
    switch (label) {
      case 'hitam': return bijiHitam;
      case 'hitam_sebagian': return bijiHitamSebagian;
      case 'hitam_pecah': return bijiHitamPecah;
      case 'gelondong': return gelondong;
      case 'coklat': return cokelat;
      case 'kulit_tanduk': return kulitTanduk;
      case 'biji_pecah': return bijiPecah;
      case 'muda': return muda;
      case 'berlubang_satu': return berlubangSatu;
      case 'berlubang_banyak': return berlubangBanyak;
      case 'berkulit_tanduk': return berkulitAri;
      case 'kulit_kopi': return kulitTanduk;
      case 'benda_lain': return bendaLain;
      default: return 0.0;
    }
  }


  static String determineGrade(double score) {
    if (score <= 11) return "Mutu 1";
    if (score <= 25) return "Mutu 2";
    if (score <= 44) return "Mutu 3";
    if (score <= 60) return "Mutu 4a";
    if (score <= 80) return "Mutu 4b";
    if (score <= 150) return "Mutu 5";
    return "Mutu 6";
  }


  static SniCalculationResult evaluate(Map<String, int> defectDetails) {
    double totalScore = 0;

    defectDetails.forEach((label, count) {
      if (label != 'normal') {
        totalScore += count * getDefectWeight(label);
      }
    });

    String grade = determineGrade(totalScore);

    return SniCalculationResult(totalScore, grade);
  }
}
