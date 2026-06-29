import 'dart:convert';
import 'package:http/http.dart' as http;

class MarketData {
  final String title;
  final String unit;
  final double currentPrice;
  final double priceChange;
  final double percentChange;
  final List<FlSpotData> chartData;

  MarketData({
    required this.title,
    required this.unit,
    required this.currentPrice,
    required this.priceChange,
    required this.percentChange,
    required this.chartData,
  });
}

class FlSpotData {
  final double x;
  final double y;
  FlSpotData(this.x, this.y);
}

class MarketService {
  static const String _yahooApiUrl = 'https://query1.finance.yahoo.com/v8/finance/chart/KC=F?range=1mo&interval=1d';

  Future<List<MarketData>> fetchAllCoffeePrices() async {
    try {
      final response = await http.get(Uri.parse(_yahooApiUrl));
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final result = json['chart']['result'][0];
        
        final meta = result['meta'];
        final currentPriceRaw = (meta['regularMarketPrice'] as num).toDouble();
        final previousCloseRaw = (meta['chartPreviousClose'] as num).toDouble();
        
        final timestamps = List<int>.from(result['timestamp']);
        final closePrices = List<num>.from(result['indicators']['quote'][0]['close'].map((e) => e ?? 0));
        
        // 1. ARABICA (Asli)
        final arabicaChart = _buildChartData(timestamps, closePrices, 1.0);
        final arabicaData = MarketData(
          title: 'Arabica Global (ICE)',
          unit: '¢/lb (US Cents)',
          currentPrice: currentPriceRaw,
          priceChange: currentPriceRaw - previousCloseRaw,
          percentChange: ((currentPriceRaw - previousCloseRaw) / previousCloseRaw) * 100,
          chartData: arabicaChart,
        );

        // Konversi Cents/lb ke USD/Ton
        const baseConversion = 22.0462; 

        // 2. ROBUSTA (Est. 70%)
        final robustaData = _generateEstimatedData('Robusta Global (Est.)', currentPriceRaw, previousCloseRaw, timestamps, closePrices, baseConversion * 0.70);
        
        // 3. LIBERICA (Est. 50%)
        final libericaData = _generateEstimatedData('Liberica Global (Est.)', currentPriceRaw, previousCloseRaw, timestamps, closePrices, baseConversion * 0.50);
        
        // 4. EXCELSA (Est. 85% Premium)
        final excelsaData = _generateEstimatedData('Excelsa Global (Est.)', currentPriceRaw, previousCloseRaw, timestamps, closePrices, baseConversion * 0.85);

        return [arabicaData, robustaData, libericaData, excelsaData];
      }
    } catch (e) {
      print('Error fetching market data: $e');
    }
    return [];
  }

  MarketData _generateEstimatedData(
    String title, 
    double currentRaw, 
    double prevRaw, 
    List<int> timestamps, 
    List<num> closePrices, 
    double multiplier
  ) {
    final current = currentRaw * multiplier;
    final prev = prevRaw * multiplier;
    return MarketData(
      title: title,
      unit: '\$/Ton (USD)',
      currentPrice: current,
      priceChange: current - prev,
      percentChange: ((current - prev) / prev) * 100,
      chartData: _buildChartData(timestamps, closePrices, multiplier),
    );
  }

  List<FlSpotData> _buildChartData(List<int> timestamps, List<num> closePrices, double multiplier) {
    List<FlSpotData> chartData = [];
    for (int i = 0; i < timestamps.length; i++) {
      if (closePrices[i] > 0) {
        chartData.add(FlSpotData(i.toDouble(), closePrices[i].toDouble() * multiplier));
      }
    }
    return chartData;
  }
}
