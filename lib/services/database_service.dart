import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ScanRecord {
  final dynamic id; // Bisa int (SQLite) atau String uuid (Supabase)
  final DateTime timestamp;
  final String imagePath;
  final int defectCount;
  final double defectScore;
  final int totalBeans;
  final String grade;
  final Map<String, int> defectDetails;

  ScanRecord({
    this.id,
    required this.timestamp,
    required this.imagePath,
    required this.defectCount,
    required this.defectScore,
    required this.totalBeans,
    required this.grade,
    required this.defectDetails,
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
        final response = await Supabase.instance.client.from('scans').insert({
          'user_id': user.id,
          'created_at': record.timestamp.toIso8601String(),
          'image_path': record.imagePath,
          'defect_count': record.defectCount,
          'defect_score': record.defectScore,
          'total_beans': record.totalBeans,
          'grade': record.grade,
          'defect_details': record.defectDetails, // JSONB handles Map automatically
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
}
