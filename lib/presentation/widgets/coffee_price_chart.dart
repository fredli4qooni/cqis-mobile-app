import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_theme.dart';
import '../../services/market_service.dart';

class CoffeePriceChart extends StatefulWidget {
  const CoffeePriceChart({super.key});

  @override
  State<CoffeePriceChart> createState() => _CoffeePriceChartState();
}

class _CoffeePriceChartState extends State<CoffeePriceChart> {
  final MarketService _marketService = MarketService();
  List<MarketData> _marketDataList = [];
  bool _isLoading = true;
  
  final PageController _pageController = PageController();
  Timer? _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await _marketService.fetchAllCoffeePrices();
    if (mounted) {
      setState(() {
        _marketDataList = data;
        _isLoading = false;
      });
      _startAutoPlay();
    }
  }

  void _startAutoPlay() {
    _timer?.cancel();
    if (_marketDataList.isEmpty) return;
    
    _timer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
      if (_pageController.hasClients) {
        int nextPage = _currentPage + 1;
        if (nextPage >= _marketDataList.length) {
          nextPage = 0;
          _pageController.animateToPage(
            nextPage,
            duration: const Duration(milliseconds: 600),
            curve: Curves.fastOutSlowIn,
          );
        } else {
          _pageController.animateToPage(
            nextPage,
            duration: const Duration(milliseconds: 600),
            curve: Curves.fastOutSlowIn,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildContainer(
        child: const SizedBox(
          height: 200,
          child: Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        ),
      );
    }

    if (_marketDataList.isEmpty) {
      return _buildContainer(
        child: const SizedBox(
          height: 200,
          child: Center(
            child: Text('Gagal memuat data pasar'),
          ),
        ),
      );
    }

    return _buildContainer(
      child: Column(
        children: [
          SizedBox(
            height: 220,
            child: GestureDetector(
              onPanDown: (_) => _timer?.cancel(),
              onPanCancel: _startAutoPlay,
              onPanEnd: (_) => _startAutoPlay(),
              child: PageView.builder(
                controller: _pageController,
                itemCount: _marketDataList.length,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemBuilder: (context, index) {
                  return _buildChartSlide(_marketDataList[index]);
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(
                _marketDataList.length,
                (index) {
                  final data = _marketDataList[index];
                  final isActive = _currentPage == index;
                  final titleSplit = data.title.split(' ');
                  final shortTitle = titleSplit.isNotEmpty ? titleSplit[0] : '';
                  final priceText = shortTitle.toLowerCase() == 'arabica'
                      ? '${data.currentPrice.toStringAsFixed(2)}¢'
                      : '\$${data.currentPrice.toStringAsFixed(0)}';
                  
                  return GestureDetector(
                    onTap: () {
                      _pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                      _startAutoPlay();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isActive ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
                        border: Border.all(
                          color: isActive ? AppColors.primary : AppColors.textSecondary.withOpacity(0.2),
                          width: isActive ? 1.5 : 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            shortTitle,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isActive ? AppColors.primary : AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                priceText,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                data.percentChange >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                                color: data.percentChange >= 0 ? AppColors.primary : AppColors.danger,
                                size: 10,
                              ),
                              Text(
                                '${data.percentChange.abs().toStringAsFixed(1)}%',
                                style: TextStyle(
                                  color: data.percentChange >= 0 ? AppColors.primary : AppColors.danger,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContainer({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.textSecondary.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: child,
    );
  }

  Widget _buildChartSlide(MarketData marketData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.trending_up, color: AppColors.primary, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          marketData.title,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${marketData.unit} (30 Hari)',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: marketData.percentChange >= 0
                    ? AppColors.primary.withOpacity(0.1)
                    : AppColors.danger.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    marketData.percentChange >= 0
                        ? Icons.arrow_upward
                        : Icons.arrow_downward,
                    color: marketData.percentChange >= 0
                        ? AppColors.primary
                        : AppColors.danger,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${marketData.percentChange.abs().toStringAsFixed(2)}%',
                    style: TextStyle(
                      color: marketData.percentChange >= 0
                          ? AppColors.primary
                          : AppColors.danger,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (marketData.chartData.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${marketData.title.contains('Arabica') ? '' : '\$'}${marketData.currentPrice.toStringAsFixed(marketData.title.contains('Arabica') ? 2 : 0)} ${marketData.title.contains('Arabica') ? '¢/lb' : ''}',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontSize: 24,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 100,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: marketData.chartData.map((e) => FlSpot(e.x, e.y)).toList(),
                        isCurved: true,
                        color: marketData.percentChange >= 0 ? AppColors.primary : AppColors.danger,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: (marketData.percentChange >= 0 ? AppColors.primary : AppColors.danger)
                              .withOpacity(0.1),
                        ),
                      ),
                    ],
                    minX: marketData.chartData.first.x,
                    maxX: marketData.chartData.last.x,
                    minY: marketData.chartData.map((e) => e.y).reduce((a, b) => a < b ? a : b) * 0.98,
                    maxY: marketData.chartData.map((e) => e.y).reduce((a, b) => a > b ? a : b) * 1.02,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
