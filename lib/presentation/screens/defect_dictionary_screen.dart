import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../services/database_service.dart';

class DefectDictionaryScreen extends StatefulWidget {
  const DefectDictionaryScreen({super.key});

  @override
  State<DefectDictionaryScreen> createState() => _DefectDictionaryScreenState();
}

class _DefectDictionaryScreenState extends State<DefectDictionaryScreen> {
  String _selectedFilter = 'Semua';
  List<DefectDictionary> _allDefects = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final dbService = DatabaseService();
    final defects = await dbService.fetchDefectDictionary();
    if (mounted) {
      setState(() {
        _allDefects = defects;
        _isLoading = false;
      });
    }
  }
  
  List<DefectDictionary> get _filteredDefects {
    if (_selectedFilter == 'Cacat Major') {
      return _allDefects.where((d) => d.category.toLowerCase() == 'major').toList();
    } else if (_selectedFilter == 'Cacat Minor') {
      return _allDefects.where((d) => d.category.toLowerCase() == 'minor').toList();
    }
    return _allDefects;
  }

  void _showDefectDetail(BuildContext context, DefectDictionary defect) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _DefectDetailSheet(defect: defect),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Kamus Cacat Kopi'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Column(
        children: [
          // Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _buildFilterChip('Semua'),
                const SizedBox(width: 8),
                _buildFilterChip('Cacat Major'),
                const SizedBox(width: 8),
                _buildFilterChip('Cacat Minor'),
              ],
            ),
          ),
          
          // List of defects
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filteredDefects.length,
              itemBuilder: (context, index) {
                final defect = _filteredDefects[index];
                final isMajor = defect.category.toLowerCase() == 'major';
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: InkWell(
                    onTap: () => _showDefectDetail(context, defect),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isMajor ? AppColors.danger.withOpacity(0.1) : AppColors.warning.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.circle,
                              color: isMajor ? AppColors.danger : AppColors.warning,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  defect.name,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isMajor ? AppColors.danger : AppColors.warning,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    isMajor ? 'Cacat Major' : 'Cacat Minor',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right, color: AppColors.textSecondary),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedFilter = label;
          });
        }
      },
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textPrimary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}

class _DefectDetailSheet extends StatelessWidget {
  final DefectDictionary defect;

  const _DefectDetailSheet({required this.defect});

  @override
  Widget build(BuildContext context) {
    final isMajor = defect.category.toLowerCase() == 'major';
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textSecondary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Icon(
                  Icons.circle,
                  color: isMajor ? AppColors.danger : AppColors.warning,
                  size: 40,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        defect.name,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isMajor ? 'Cacat Major' : 'Cacat Minor',
                        style: TextStyle(
                          color: isMajor ? AppColors.danger : AppColors.warning,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            _buildSection(
              context,
              title: 'Bobot Penalti (Score)',
              icon: Icons.calculate,
              content: 'Setiap 1 keping cacat ini akan mengurangi poin mutu sebesar ${defect.penaltyScore}',
              color: AppColors.textPrimary,
            ),
            const SizedBox(height: 16),

            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Tutup', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, {required String title, required IconData icon, required String content, required Color color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
