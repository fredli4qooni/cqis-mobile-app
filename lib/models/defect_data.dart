import 'package:flutter/material.dart';

enum DefectCategory { berat, ringan }

class CoffeeDefect {
  final String name;
  final DefectCategory category;
  final IconData icon;
  final String cause;
  final String impact;
  final String solution;

  const CoffeeDefect({
    required this.name,
    required this.category,
    required this.icon,
    required this.cause,
    required this.impact,
    required this.solution,
  });
}

class DefectDataStore {
  static const List<CoffeeDefect> defects = [
    CoffeeDefect(
      name: 'Biji Hitam (Black Bean)',
      category: DefectCategory.berat,
      icon: Icons.circle,
      cause: 'Buah kopi jatuh ke tanah, terinfeksi jamur, atau kurang air secara ekstrem saat pertumbuhan.',
      impact: 'Rasa fermentasi, busuk (stinker), phenolic, dan sangat pahit kotor.',
      solution: 'Panen hanya buah merah di pohon. Hindari mengutip buah yang sudah jatuh ke tanah.',
    ),
    CoffeeDefect(
      name: 'Biji Asam / Coklat (Sour Bean)',
      category: DefectCategory.berat,
      icon: Icons.circle_outlined,
      cause: 'Fermentasi berlebih karena penundaan pengupasan setelah panen, atau penjemuran yang terlalu lambat.',
      impact: 'Rasa cuka (vinegary), asam menyengat, dan profil rasa yang kotor.',
      solution: 'Segera kupas (pulp) ceri maksimal 12 jam setelah panen dan pastikan area penjemuran kering & berventilasi baik.',
    ),
    CoffeeDefect(
      name: 'Biji Berlubang / Hama (Insect Damage)',
      category: DefectCategory.berat,
      icon: Icons.bug_report,
      cause: 'Serangan hama penggerek buah kopi (Hypothenemus hampei / PBKo).',
      impact: 'Menurunkan aroma, rasa menjadi hampa (flat), rentan tumbuh jamur (moldy) di lubang gigitan.',
      solution: 'Gunakan perangkap Brocotrap di kebun, lakukan pemangkasan rutin, dan sanitasi sisa buah di tanah.',
    ),
    CoffeeDefect(
      name: 'Biji Pecah (Broken / Chipped)',
      category: DefectCategory.ringan,
      icon: Icons.broken_image,
      cause: 'Pisau pulper / huller terlalu rapat, atau kadar air kopi terlalu kering saat digiling.',
      impact: 'Biji gosong sebagian saat disangrai (roasting), menghasilkan rasa arang (ashy).',
      solution: 'Kalibrasi ulang mesin pulper/huller. Pastikan kadar air kulit tanduk ideal (11-12%) sebelum di-huller.',
    ),
    CoffeeDefect(
      name: 'Biji Keriput (Withered Bean)',
      category: DefectCategory.ringan,
      icon: Icons.lens_blur,
      cause: 'Kekeringan pada pohon saat masa pembuahan (kurang nutrisi/air).',
      impact: 'Kurangnya intensitas rasa, bodi tipis (light body), rasa seperti jerami (straw-like).',
      solution: 'Berikan pemupukan berimbang, gunakan pohon penaung (shade trees), dan irigasi yang cukup di musim kemarau.',
    ),
    CoffeeDefect(
      name: 'Biji Cangkang (Shell)',
      category: DefectCategory.ringan,
      icon: Icons.trip_origin,
      cause: 'Faktor genetik alami di mana dua biji tumbuh secara malformasi membungkus satu sama lain.',
      impact: 'Biji sangat tipis sehingga mudah terbakar saat di-roasting, menghasilkan rasa asap (smoky) atau gosong.',
      solution: 'Faktor genetik sulit dicegah sepenuhnya, tapi pisahkan melalui sortasi densitas (gravity separator).',
    ),
  ];
}
