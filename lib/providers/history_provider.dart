import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/database_service.dart';

class HistoryNotifier extends StateNotifier<AsyncValue<List<ScanRecord>>> {
  final DatabaseService _dbService;

  HistoryNotifier(this._dbService) : super(const AsyncValue.loading()) {
    loadHistory();
  }

  Future<void> loadHistory() async {
    state = const AsyncValue.loading();
    try {
      final scans = await _dbService.getAllScans();
      state = AsyncValue.data(scans);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addScan(ScanRecord record) async {
    try {
      await _dbService.insertScan(record);
      await loadHistory();
    } catch (e) {
      print('Error adding scan to history: $e');
    }
  }
  
  Future<void> deleteScan(dynamic id) async {
    try {
      await _dbService.deleteScan(id);
      await loadHistory();
    } catch (e) {
      print('Error deleting scan: $e');
    }
  }
}

final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

final historyProvider = StateNotifierProvider<HistoryNotifier, AsyncValue<List<ScanRecord>>>((ref) {
  final dbService = ref.watch(databaseServiceProvider);
  return HistoryNotifier(dbService);
});
