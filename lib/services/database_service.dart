import 'dart:convert';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DefectDictionary {
  final String code;
  final String name;
  final String category;
  final double penaltyScore;

  DefectDictionary({required this.code, required this.name, required this.category, required this.penaltyScore});

  factory DefectDictionary.fromMap(Map<String, dynamic> map) {
    return DefectDictionary(
      code: map['code'] ?? '',
      name: map['name'] ?? '',
      category: map['category'] ?? 'Minor',
      penaltyScore: map['penalty_score']?.toDouble() ?? 0.0,
    );
  }
}

class GradeRule {
  final String gradeName;
  final double minDefect;
  final double maxDefect;
  final String description;

  GradeRule({required this.gradeName, required this.minDefect, required this.maxDefect, this.description = ''});

  factory GradeRule.fromMap(Map<String, dynamic> map) {
    return GradeRule(
      gradeName: map['grade_name'] ?? '',
      minDefect: map['min_defect']?.toDouble() ?? 0.0,
      maxDefect: map['max_defect']?.toDouble() ?? 0.0,
      description: map['description'] ?? '',
    );
  }
}

class ScanRecord {
  final dynamic id; // Bisa int (SQLite) atau String uuid (Supabase)
  final DateTime timestamp;
  final String imagePath;
  final int defectCount;
  final double defectScore;
  final int totalBeans;
  final String grade;
  final Map<String, int> defectDetails;
  final List<dynamic>? rawDetections;
  final int? imageWidth;
  final int? imageHeight;

  ScanRecord({
    this.id,
    required this.timestamp,
    required this.imagePath,
    required this.defectCount,
    required this.defectScore,
    required this.totalBeans,
    required this.grade,
    required this.defectDetails,
    this.rawDetections,
    this.imageWidth,
    this.imageHeight,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'image_path': imagePath,
      'defect_count': defectCount,
      'defect_score': defectScore,
      'total_beans': totalBeans,
      'grade': grade,
      'defect_details': jsonEncode(defectDetails),
      'raw_detections': rawDetections != null ? jsonEncode(rawDetections) : '[]',
      'image_width': imageWidth ?? 0,
      'image_height': imageHeight ?? 0,
    };
  }

  factory ScanRecord.fromMap(Map<String, dynamic> map) {
    return ScanRecord(
      id: map['id'],
      timestamp: DateTime.parse(map['created_at'] ?? map['timestamp']),
      imagePath: map['image_path'],
      defectCount: map['defect_count'],
      defectScore: map['defect_score']?.toDouble() ?? 0.0,
      totalBeans: map['total_beans'],
      grade: map['grade'],
      defectDetails: map['defect_details'] is String 
          ? Map<String, int>.from(jsonDecode(map['defect_details']))
          : Map<String, int>.from(map['defect_details'] as Map), // Supabase JSONB comes as Map
      rawDetections: map['raw_detections'] is String
          ? jsonDecode(map['raw_detections'])
          : (map['raw_detections'] as List<dynamic>? ?? []),
      imageWidth: map['image_width'] as int? ?? 0,
      imageHeight: map['image_height'] as int? ?? 0,
    );
  }
}

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'mutukopi_db.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE scan_history(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        timestamp TEXT,
        image_path TEXT,
        defect_count INTEGER,
        defect_score REAL,
        total_beans INTEGER,
        grade TEXT,
        defect_details TEXT
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('DROP TABLE IF EXISTS scan_history');
      await _onCreate(db, newVersion);
    }
  }

  Future<dynamic> insertScan(ScanRecord record) async {
    final user = Supabase.instance.client.auth.currentUser;
    
    if (user != null) {
      // Save to Supabase
      try {
        String finalImagePath = record.imagePath;

        // Jika imagePath adalah path lokal dan file fisik benar-benar ada
        if (!finalImagePath.startsWith('http')) {
          try {
            final file = File(finalImagePath);
            if (await file.exists()) {
              // 1. Ekstrak ekstensi (contoh: jpg)
              final ext = finalImagePath.split('.').last;
              // 2. Buat nama file unik (gabungan ID user dan timestamp)
              final fileName = '${user.id}_${DateTime.now().millisecondsSinceEpoch}.$ext';
              
              // 3. Upload ke bucket 'scan-images'
              await Supabase.instance.client.storage
                  .from('scan-images')
                  .upload(fileName, file);
              
              // 4. Ambil Public URL untuk disimpan ke Database
              finalImagePath = Supabase.instance.client.storage
                  .from('scan-images')
                  .getPublicUrl(fileName);
            }
          } catch (e) {
            print('Gagal mengunggah foto ke Supabase Storage: $e');
            // Jika gagal upload (misal koneksi lambat), kita tetap lanjutkan simpan ke tabel
            // menggunakan path lokal sebagai fallback (aplikasi tidak akan crash).
          }
        }

        final response = await Supabase.instance.client.from('scans').insert({
          'user_id': user.id,
          'created_at': record.timestamp.toIso8601String(),
          'image_path': finalImagePath, // Menggunakan URL publik (jika berhasil upload)
          'defect_count': record.defectCount,
          'defect_score': record.defectScore,
          'total_beans': record.totalBeans,
          'grade': record.grade,
          'defect_details': record.defectDetails, // JSONB handles Map automatically
          'raw_detections': record.rawDetections ?? [], // JSONB array
          'image_width': record.imageWidth ?? 0,
          'image_height': record.imageHeight ?? 0,
        }).select().single();
        return response['id'];
      } catch (e) {
        print('Supabase insert error: $e');
        // Fallback to SQLite
      }
    }

    // Fallback or Guest Mode: Save to SQLite
    final db = await database;
    return await db.insert(
      'scan_history',
      record.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ScanRecord>> getAllScans() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user != null) {
      // Fetch from Supabase
      try {
        final data = await Supabase.instance.client
            .from('scans')
            .select()
            .eq('user_id', user.id)
            .order('created_at', ascending: false);
        return data.map((map) => ScanRecord.fromMap(map)).toList();
      } catch (e) {
        print('Supabase fetch error: $e');
        // Fallback to SQLite
      }
    }

    // Fetch from SQLite
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'scan_history',
      orderBy: 'timestamp DESC',
    );
    return maps.map((map) => ScanRecord.fromMap(map)).toList();
  }

  Future<void> deleteScan(dynamic id) async {
    if (id is String) {
      // Delete from Supabase
      try {
        await Supabase.instance.client.from('scans').delete().match({'id': id});
      } catch (e) {
        print('Supabase delete error: $e');
      }
    } else if (id is int) {
      // Delete from SQLite
      final db = await database;
      await db.delete(
        'scan_history',
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }

  static List<DefectDictionary>? _cachedDictionary;
  static List<GradeRule>? _cachedGradeRules;

  static List<DefectDictionary> get cachedDictionary => _cachedDictionary ?? [];
  static List<GradeRule> get cachedGradeRules => _cachedGradeRules ?? [];

  Future<List<DefectDictionary>> fetchDefectDictionary() async {
    if (_cachedDictionary != null && _cachedDictionary!.isNotEmpty) {
      return _cachedDictionary!;
    }
    try {
      final data = await Supabase.instance.client
          .from('defect_dictionary')
          .select()
          .order('code', ascending: true);
      _cachedDictionary = data.map((map) => DefectDictionary.fromMap(map)).toList();
      return _cachedDictionary!;
    } catch (e) {
      print('Error fetching defect dictionary: $e');
      return [];
    }
  }

  Future<List<GradeRule>> fetchGradeRules() async {
    if (_cachedGradeRules != null && _cachedGradeRules!.isNotEmpty) {
      return _cachedGradeRules!;
    }
    try {
      final data = await Supabase.instance.client
          .from('grade_rules')
          .select()
          .order('min_defect', ascending: true);
      _cachedGradeRules = data.map((map) => GradeRule.fromMap(map)).toList();
      return _cachedGradeRules!;
    } catch (e) {
      print('Error fetching grade rules: $e');
      return [];
    }
  }
}
