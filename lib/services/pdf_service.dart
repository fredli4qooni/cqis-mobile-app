import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'database_service.dart';
import 'sni_calculator.dart';

class PdfService {
  static Future<Uint8List> generateQualityReport(ScanRecord record) async {
    final pdf = pw.Document();
    
    // Identitas Pengguna
    final user = Supabase.instance.client.auth.currentUser;
    final userName = user?.userMetadata?['full_name'] ?? 'Pengguna Tamu';
    final userRole = user?.userMetadata?['role'] ?? 'Guest Mode';

    // Rincian Cacat (hanya yang > 0 dan bukan 'normal')
    final defectsOnly = record.defectDetails.entries
        .where((e) => e.key != 'normal' && e.value > 0)
        .toList();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            _buildHeader(),
            pw.SizedBox(height: 20),
            _buildRecordInfo(record, userName, userRole),
            pw.SizedBox(height: 20),
            _buildSummary(record),
            pw.SizedBox(height: 20),
            _buildDefectsTable(defectsOnly),
            pw.SizedBox(height: 30),
            _buildFooter(),
          ];
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildHeader() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(
          'CQIS',
          style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold, color: PdfColors.brown800),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          'Coffee Quality Inspection System',
          style: pw.TextStyle(fontSize: 14, color: PdfColors.grey700),
        ),
        pw.SizedBox(height: 16),
        pw.Divider(thickness: 2, color: PdfColors.brown800),
        pw.SizedBox(height: 16),
        pw.Text(
          'SERTIFIKAT MUTU KOPI (SNI 01-2907-2008)',
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          textAlign: pw.TextAlign.center,
        ),
      ],
    );
  }

  static pw.Widget _buildRecordInfo(ScanRecord record, String userName, String userRole) {
    final dateStr = DateFormat('dd MMMM yyyy HH:mm', 'id_ID').format(record.timestamp);
    final scanId = record.id?.toString().padLeft(3, '0') ?? 'NEW';

    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('ID Laporan: SCAN-$scanId', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 4),
            pw.Text('Tanggal Uji: $dateStr'),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text('Penguji: $userName', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 4),
            pw.Text('Peran: $userRole'),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildSummary(ScanRecord record) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: [
          _summaryItem('Grade Akhir', record.grade.toUpperCase(), isHighlight: true),
          _summaryItem('Total Nilai Cacat', record.defectScore.toStringAsFixed(1)),
          _summaryItem('Total Keping Diuji', '${record.totalBeans} Keping'),
        ],
      ),
    );
  }

  static pw.Widget _summaryItem(String title, String value, {bool isHighlight = false}) {
    return pw.Column(
      children: [
        pw.Text(title, style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
        pw.SizedBox(height: 4),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: isHighlight ? 20 : 16,
            fontWeight: pw.FontWeight.bold,
            color: isHighlight ? PdfColors.brown800 : PdfColors.black,
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildDefectsTable(List<MapEntry<String, int>> defectsOnly) {
    if (defectsOnly.isEmpty) {
      return pw.Center(
        child: pw.Text('Tidak ditemukan keping cacat. Biji kopi sempurna!', style: pw.TextStyle(fontStyle: pw.FontStyle.italic)),
      );
    }

    final tableHeaders = ['Jenis Cacat', 'Jumlah Keping', 'Bobot Nilai', 'Total Nilai'];
    
    final tableData = defectsOnly.map((defect) {
      final name = SniCalculator.getLabelName(defect.key, DatabaseService.cachedDictionary);
      final count = defect.value;
      final weight = SniCalculator.getDefectWeight(defect.key, DatabaseService.cachedDictionary);
      final total = count * weight;
      
      return [
        name,
        count.toString(),
        weight.toString(),
        total.toStringAsFixed(1),
      ];
    }).toList();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Rincian Nilai Cacat', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        pw.TableHelper.fromTextArray(
          headers: tableHeaders,
          data: tableData,
          border: pw.TableBorder.all(color: PdfColors.grey400),
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.brown600),
          cellAlignment: pw.Alignment.center,
          cellAlignments: {0: pw.Alignment.centerLeft},
          cellPadding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        ),
      ],
    );
  }

  static pw.Widget _buildFooter() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Divider(color: PdfColors.grey300),
        pw.SizedBox(height: 8),
        pw.Text(
          'Laporan ini dihasilkan secara otomatis oleh sistem CQIS berdasarkan pemindaian AI.',
          style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600, fontStyle: pw.FontStyle.italic),
          textAlign: pw.TextAlign.center,
        ),
      ],
    );
  }
}
