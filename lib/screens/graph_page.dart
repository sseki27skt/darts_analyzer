import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../database.dart'; // Gameクラスのため

class GraphPage extends StatefulWidget {
  final List<Game> history;

  const GraphPage({super.key, required this.history});

  @override
  State<GraphPage> createState() => _GraphPageState();
}

class _GraphPageState extends State<GraphPage> {
  String _selectedPeriod = 'All';

  final Map<String, int> _filterDays = {
    'All': 36500,
    'Year': 365,
    'Month': 30,
    'Week': 7,
    'Day': 1,
  };

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    List<Game> sortedHistory = List<Game>.from(widget.history);
    sortedHistory.sort((a, b) => a.date.compareTo(b.date));

    final int days = _filterDays[_selectedPeriod]!;
    final DateTime cutoff = now.subtract(Duration(days: days));
    
    List<Game> filteredHistory;
    if (_selectedPeriod == 'All') {
      filteredHistory = sortedHistory;
    } else if (_selectedPeriod == 'Day') {
       final todayStart = DateTime(now.year, now.month, now.day);
       filteredHistory = sortedHistory.where((g) => g.date.isAfter(todayStart)).toList();
    } else {
       filteredHistory = sortedHistory.where((g) => g.date.isAfter(cutoff)).toList();
    }

    if (filteredHistory.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Performance Trends')),
        body: Column(
          children: [
            _buildFilterTabs(),
            const Expanded(child: Center(child: Text("No data in this period."))),
          ],
        ),
      );
    }

    double avgScore = 0;
    double avgSdX = 0;
    double avgSdY = 0;
    int maxScore = 0;
    
    for (var g in filteredHistory) {
      avgScore += g.score;
      avgSdX += g.sdX;
      avgSdY += g.sdY;
      if (g.score > maxScore) maxScore = g.score;
    }
    avgScore /= filteredHistory.length;
    avgSdX /= filteredHistory.length;
    avgSdY /= filteredHistory.length;

    return Scaffold(
      appBar: AppBar(title: const Text('Performance Trends')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildFilterTabs(),
            const SizedBox(height: 10),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem("Games", "${filteredHistory.length}", Colors.white),
                _buildSummaryItem("Avg Score", avgScore.toStringAsFixed(1), Colors.orangeAccent),
                _buildSummaryItem("Best Score", "$maxScore", Colors.redAccent),
              ],
            ),
            const Divider(color: Colors.white24, height: 30),

            Expanded(
              child: ListView(
                children: [
                  const Text("Score History", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orangeAccent)),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 220,
                    child: LineChart(
                      _buildScoreChart(filteredHistory),
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text("Precision (SD mm)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.cyanAccent)),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 220,
                    child: LineChart(
                      _buildPrecisionChart(filteredHistory),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.horizontal_rule, color: Colors.blueAccent, size: 12), 
                      Text(" X-SD (Avg: ${avgSdX.toStringAsFixed(1)}) ", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      const SizedBox(width: 15),
                      const Icon(Icons.horizontal_rule, color: Colors.redAccent, size: 12), 
                      Text(" Y-SD (Avg: ${avgSdY.toStringAsFixed(1)})", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _filterDays.keys.map((period) {
          final isSelected = _selectedPeriod == period;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ChoiceChip(
              label: Text(period),
              selected: isSelected,
              selectedColor: Colors.blueAccent.withOpacity(0.3),
              onSelected: (bool selected) {
                if (selected) {
                  setState(() {
                    _selectedPeriod = period;
                  });
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 10)),
        Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
      ],
    );
  }

  LineChartData _buildScoreChart(List<Game> data) {
    final spots = data.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.score.toDouble());
    }).toList();

    double maxScore = 0;
    for (var spot in spots) {
      if (spot.y > maxScore) maxScore = spot.y;
    }

    // ★修正: 最大値を「20の倍数」に切り上げて、常にグリッドぴったりで終わるようにする
    // 例: maxScoreが105なら -> 120まで確保したい -> 余白も考えて140にする
    // ここでは「(最大スコア + 10) を 20 で割って切り上げ × 20」とします
    double maxY = ((maxScore + 10) / 20).ceil() * 20.0;
    
    // 最低でも100点までは表示する
    if (maxY < 100) maxY = 100;

    return LineChartData(
      minY: 0,
      maxY: maxY, // ★修正したmaxYを使用
      
      gridData: const FlGridData(
        show: true, 
        drawVerticalLine: false,
        horizontalInterval: 20, // 20点刻み
      ),
      
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 50, // 3桁表示用に広げたまま
            interval: 20,
            getTitlesWidget: (value, meta) {
              // 最大値そのものは表示しない（天井の線と被るため）
              // 必要な場合は `if (value > maxY)` だけにする
              if (value > maxY || value % 1 != 0) return const SizedBox.shrink();
              return Text(
                value.toInt().toString(),
                style: const TextStyle(color: Colors.grey, fontSize: 12),
                textAlign: TextAlign.right,
              );
            },
          ),
        ),
        bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: Colors.white12),
      ),
      
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          curveSmoothness: 0.2,
          color: Colors.orangeAccent,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 4,
                color: Colors.black,
                strokeWidth: 2,
                strokeColor: Colors.orangeAccent,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true, 
            color: Colors.orangeAccent.withOpacity(0.1)
          ),
        ),
      ],
    );
  }

  LineChartData _buildPrecisionChart(List<Game> data) {
    final spotsX = data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.sdX)).toList();
    final spotsY = data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.sdY)).toList();

    return LineChartData(
      minY: 0, maxY: 60,
      gridData: const FlGridData(show: true, drawVerticalLine: false),
      titlesData: const FlTitlesData(
        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30, interval: 10)),
        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: true, border: Border.all(color: Colors.white12)),
      lineBarsData: [
        LineChartBarData(
          spots: spotsX,
          isCurved: true,
          color: Colors.blueAccent,
          barWidth: 2,
          dotData: const FlDotData(show: false),
        ),
        LineChartBarData(
          spots: spotsY,
          isCurved: true,
          color: Colors.redAccent,
          barWidth: 2,
          dotData: const FlDotData(show: false),
        ),
      ],
    );
  }
}