import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
// クエリ用 (whereなどで使う可能性があるため残す)
import '../database.dart';

class GraphPage extends StatefulWidget {
  final List<Game> history;

  const GraphPage({super.key, required this.history});

  @override
  State<GraphPage> createState() => _GraphPageState();
}

class _GraphPageState extends State<GraphPage>
    with SingleTickerProviderStateMixin {
  String _selectedPeriod = 'All';

  late TabController _tabController;

  final Map<String, int> _filterDays = {
    'All': 36500,
    'Year': 365,
    'Month': 30,
    'Week': 7,
    'Day': 1,
  };

  List<Game> _filteredGamesCenter = [];
  List<Game> _filteredGamesCountUp = [];

  Map<String, int> _statsCenter = {};
  Map<String, int> _statsCountUp = {};
  bool _isLoadingStats = false;

  @override
  void initState() {
    super.initState();

    // ★追加: コントローラーの作成 (length: 2 はタブの数)
    _tabController = TabController(length: 2, vsync: this);

    // データ読み込み (前回の修正をそのまま維持)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _filterData();
    });
  }

  @override
  void dispose() {
    // ★追加: 画面を閉じる時にコントローラーを破棄する
    _tabController.dispose();
    super.dispose();
  }

  void _filterData() {
    final now = DateTime.now();
    final int days = _filterDays[_selectedPeriod]!;
    final DateTime cutoff = now.subtract(Duration(days: days));
    final todayStart = DateTime(now.year, now.month, now.day);

    final periodGames = widget.history.where((g) {
      if (_selectedPeriod == 'All') return true;
      if (_selectedPeriod == 'Day') return g.date.isAfter(todayStart);
      return g.date.isAfter(cutoff);
    }).toList();

    periodGames.sort((a, b) => a.date.compareTo(b.date));

    // ★修正2: 画面が閉じられていたら何もしない
    if (!mounted) return;

    setState(() {
      _filteredGamesCenter = periodGames.where((g) => g.gameType == 0).toList();
      _filteredGamesCountUp = periodGames
          .where((g) => g.gameType == 1)
          .toList();
    });

    _calculateDetailedStats();
  }

  Future<void> _calculateDetailedStats() async {
    // ★修正3: 非同期処理の前にもチェック
    if (!mounted) return;

    setState(() => _isLoadingStats = true);

    Future<Map<String, int>> aggregate(List<Game> games) async {
      if (games.isEmpty) return {};

      final ids = games.map((g) => g.id).toList();

      // DBアクセス (await)
      final throws = await (database.select(
        database.throws,
      )..where((t) => t.gameId.isIn(ids))).get();

      int sBull = 0;
      int dBull = 0;
      int triple = 0;
      int doubleRing = 0;
      int single = 0;
      int out = 0;
      int total = 0;

      for (var t in throws) {
        final label = t.segmentLabel;
        total++;
        if (label == 'S-BULL') {
          sBull++;
        } else if (label == 'D-BULL') {
          dBull++;
        } else if (label.startsWith('T')) {
          triple++;
        } else if (label.startsWith('D')) {
          doubleRing++;
        } else if (label == 'OUT') {
          out++;
        } else {
          single++;
        }
      }

      return {
        'sBull': sBull,
        'dBull': dBull,
        'triple': triple,
        'double': doubleRing,
        'single': single,
        'out': out,
        'total': total,
      };
    }

    final statsC = await aggregate(_filteredGamesCenter);
    final statsR = await aggregate(_filteredGamesCountUp);

    // ★修正4: await（待機）から戻ってきたときに、まだ画面があるか確認する
    // これが「戻るボタン」対策で最も重要です！
    if (mounted) {
      setState(() {
        _statsCenter = statsC;
        _statsCountUp = statsR;
        _isLoadingStats = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // ★変更: DefaultTabController を削除し、直接 Scaffold を返す
    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance Trends'),
        bottom: TabBar( // const を外す必要があるかもしれません
          controller: _tabController, // ★追加: コントローラーをセット
          tabs: const [
            Tab(text: 'Center Count-Up'),
            Tab(text: 'Count-Up (Real)'),
          ],
          indicatorColor: Colors.amber,
          labelColor: Colors.amber,
          unselectedLabelColor: Colors.grey,
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: Colors.black87,
            child: _buildFilterTabs(),
          ),
          
          Expanded(
            child: TabBarView(
              controller: _tabController, // ★追加: ここにも同じコントローラーをセット
              children: [
                _buildTabContent(
                  games: _filteredGamesCenter,
                  stats: _statsCenter,
                  isRealMode: false,
                ),
                _buildTabContent(
                  games: _filteredGamesCountUp,
                  stats: _statsCountUp,
                  isRealMode: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent({
    required List<Game> games,
    required Map<String, int> stats,
    required bool isRealMode,
  }) {
    if (games.isEmpty) {
      return const Center(
        child: Text(
          "No data in this period.",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    double avgScore = 0;
    int maxScore = 0;
    // 未使用変数を削除
    // double avgSdX = 0;
    // double avgSdY = 0;

    for (var g in games) {
      avgScore += g.score;
      if (g.score > maxScore) maxScore = g.score;
    }
    avgScore /= games.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem("Games", "${games.length}", Colors.white),
              _buildSummaryItem(
                "Avg Score",
                avgScore.toStringAsFixed(1),
                isRealMode ? Colors.cyanAccent : Colors.orangeAccent,
              ),
              _buildSummaryItem("High Score", "$maxScore", Colors.redAccent),
            ],
          ),
          const SizedBox(height: 20),

          if (_isLoadingStats)
            const Center(child: LinearProgressIndicator())
          else if (stats.isNotEmpty && stats['total']! > 0)
            _buildStatsCard(stats, isRealMode),

          const SizedBox(height: 30),

          Text(
            "Score History",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isRealMode ? Colors.cyanAccent : Colors.orangeAccent,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 200,
            child: LineChart(_buildScoreChart(games, isRealMode)),
          ),

          if (!isRealMode) ...[
            const SizedBox(height: 30),
            const Text(
              "Precision (SD mm)",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.greenAccent,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 200,
              child: LineChart(_buildPrecisionChart(games)),
            ),
          ],

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildStatsCard(Map<String, int> stats, bool isRealMode) {
    int total = stats['total']!;
    int bulls = (stats['sBull'] ?? 0) + (stats['dBull'] ?? 0);
    double bullRate = (bulls / total) * 100;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "OVERALL STATS",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  letterSpacing: 1.5,
                ),
              ),
              Text(
                "Total Throws: $total",
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${bullRate.toStringAsFixed(1)}%",
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),
                    const Text(
                      "Total Bull Rate",
                      style: TextStyle(fontSize: 12, color: Colors.amberAccent),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 4,
                child: Column(
                  children: [
                    _buildStatRow(
                      "D-Bull",
                      stats['dBull']!,
                      total,
                      Colors.redAccent,
                    ),
                    _buildStatRow(
                      "S-Bull",
                      stats['sBull']!,
                      total,
                      Colors.white,
                    ),
                    if (isRealMode) ...[
                      _buildStatRow(
                        "Triple",
                        stats['triple']!,
                        total,
                        Colors.orange,
                      ),
                    ] else ...[
                      _buildStatRow(
                        "Inner",
                        stats['single']!,
                        total,
                        Colors.blueGrey,
                      ),
                    ],
                    _buildStatRow("Out", stats['out']!, total, Colors.grey),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, int count, int total, Color color) {
    double pct = total > 0 ? (count / total * 100) : 0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          SizedBox(
            width: 50,
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: pct / 100,
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 40,
            child: Text(
              "${pct.toStringAsFixed(1)}%",
              textAlign: TextAlign.right,
              style: const TextStyle(color: Colors.grey, fontSize: 11),
            ),
          ),
        ],
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
              label: Text(
                period,
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected ? Colors.white : Colors.grey,
                ),
              ),
              selected: isSelected,
              selectedColor: Colors.blueAccent.withValues(
                alpha: 0.5,
              ), // 警告が出るなら .withValues(alpha: 0.5)
              backgroundColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? Colors.blueAccent : Colors.grey[800]!,
                ),
              ),
              onSelected: (bool selected) {
                if (selected) {
                  setState(() {
                    _selectedPeriod = period;
                  });
                  _filterData();
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
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  LineChartData _buildScoreChart(List<Game> data, bool isRealMode) {
    if (data.isEmpty) return LineChartData();

    final spots = data.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.score.toDouble());
    }).toList();

    // ▼▼▼ 修正: 最小値と最大値を計算 ▼▼▼
    double minScore = spots.first.y;
    double maxScore = spots.first.y;

    for (var spot in spots) {
      if (spot.y < minScore) minScore = spot.y;
      if (spot.y > maxScore) maxScore = spot.y;
    }

    // 上下に持たせる余裕（パディング）
    double padding = 50.0;

    // Y軸の範囲決定
    // 最小値: (最小スコア - パディング) ただし 0以下にはしない
    double minY = (minScore - padding).clamp(0, double.infinity);

    // 最大値: (最大スコア + パディング)
    double maxY = maxScore + padding;
    // ▲▲▲ 修正ここまで ▲▲▲

    double interval = isRealMode ? 50 : 20;

    return LineChartData(
      minY: minY, // ここに計算したminYを適用
      maxY: maxY, // ここに計算したmaxYを適用
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: interval,
      ),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            interval: interval,
            getTitlesWidget: (v, m) => Text(
              v.toInt().toString(),
              style: const TextStyle(color: Colors.grey, fontSize: 10),
            ),
          ),
        ),
        bottomTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
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
          color: isRealMode ? Colors.cyanAccent : Colors.orangeAccent,
          barWidth: 3,
          dotData: const FlDotData(show: true), // ドットを表示して、点の位置を明確にする
          belowBarData: BarAreaData(
            show: true,
            color: (isRealMode ? Colors.cyanAccent : Colors.orangeAccent)
                .withValues(alpha: 0.1),
          ),
        ),
      ],
    );
  }

  LineChartData _buildPrecisionChart(List<Game> data) {
    final spotsX = data
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.sdX))
        .toList();
    final spotsY = data
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.sdY))
        .toList();

    return LineChartData(
      minY: 0,
      maxY: 60,
      gridData: const FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 10,
      ),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 10,
            getTitlesWidget: (v, m) => Text(
              v.toInt().toString(),
              style: const TextStyle(color: Colors.grey, fontSize: 10),
            ),
          ),
        ),
        bottomTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: Colors.white12),
      ),
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
