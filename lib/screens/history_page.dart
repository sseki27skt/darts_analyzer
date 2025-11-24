import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as drift;
import '../database.dart';
import 'result_page.dart';
import 'graph_page.dart';
import 'package:intl/intl.dart'; // 日付フォーマット用

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<Game> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final query = database.select(database.games)
      ..orderBy([
        (t) => drift.OrderingTerm(
          expression: t.date,
          mode: drift.OrderingMode.desc,
        ),
      ]);

    final result = await query.get();

    if (mounted) {
      setState(() {
        _history = result;
      });
    }
  }

  Future<void> _openDetail(BuildContext context, Game game) async {
    final throwsQuery = database.select(database.throws)
      ..where((t) => t.gameId.equals(game.id))
      ..orderBy([(t) => drift.OrderingTerm(expression: t.orderIndex)]);

    final throwsData = await throwsQuery.get();
    final List<Offset> points = throwsData
        .map((t) => Offset(t.x, t.y))
        .toList();

    if (!mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ResultPage(
          gameHistoryMm: points,
          totalScore: game.score,
          visibleDiameterMm: 160.0,
          ringSizeMm: game.ringSizeMm,
          ringLargeMm: game.ringLargeMm,
          // ★追加: DBから取得した gameType を渡す
          gameMode: game.gameType,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Practice History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.show_chart),
            tooltip: "Show Trends",
            onPressed: () {
              if (_history.length < 2) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Play at least 2 games to see trends!"),
                  ),
                );
                return;
              }
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => GraphPage(history: _history),
                ),
              );
            },
          ),
        ],
      ),
      body: _history.isEmpty
          ? const Center(child: Text("No History (DB)"))
          : ListView.builder(
              itemCount: _history.length,
              itemBuilder: (context, index) {
                final record = _history[index];

                // 日付フォーマット (intl パッケージを入れた場合は DateFormat を推奨)
                // 現状のロジックをそのまま使うならこちら
                final dateStr =
                    "${record.date.year}/${record.date.month}/${record.date.day} ${record.date.hour.toString().padLeft(2, '0')}:${record.date.minute.toString().padLeft(2, '0')}";

                // スコアに応じた色を取得
                final scoreColor = _scoreToColor(record.score);

                return Card(
                  clipBehavior: Clip.antiAlias, // タップ時の波紋をカード内に収める
                  elevation: 4, // 影を少し強くして浮き上がらせる
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  color: Colors.grey[900],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16), // 角を丸くモダンに
                    side: BorderSide(
                      color: Colors.white.withOpacity(0.1),
                      width: 1,
                    ), // 薄い枠線
                  ),
                  child: InkWell(
                    onTap: () => _openDetail(context, record),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0), // カード内部の余白
                      child: Row(
                        children: [
                          // 左側: スコア表示エリア
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              color: scoreColor.withOpacity(0.2), // 背景は薄く
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: scoreColor,
                                width: 2,
                              ), // 枠線は濃く
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "SCORE",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "${record.score}",
                                  style: TextStyle(
                                    color: scoreColor, // 文字色もスコア色に合わせる
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24, // 大きく表示
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 16), // スコアと詳細の間のスペース
                          // 中央: 日付と分析データ
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 日付
                                Text(
                                  dateStr,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // 分析データの行 (アイコン付きで見やすく)
                                Row(
                                  children: [
                                    // Ring Size
                                    _buildStatBadge(
                                      Icons.adjust,
                                      "${record.ringSizeMm.toStringAsFixed(0)}mm",
                                      Colors.orangeAccent,
                                    ),
                                    const SizedBox(width: 12),
                                    // SD X
                                    _buildStatBadge(
                                      Icons.bar_chart,
                                      "SD:${record.sdX.toStringAsFixed(1)}",
                                      Colors.blueAccent,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // 右端: 矢印アイコン
                          const Icon(
                            Icons.chevron_right,
                            color: Colors.white30,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
    
  }

  Color _scoreToColor(int score) {
    if (score >= 100) return Colors.redAccent;
    if (score >= 80) return Colors.orangeAccent;
    if (score >= 50) return Colors.blueAccent;
    return Colors.grey;
  }

  // 統計データを表示するための小さなパーツ
Widget _buildStatBadge(IconData icon, String text, Color color) {
  return Row(
    children: [
      Icon(icon, size: 14, color: color),
      const SizedBox(width: 4),
      Text(
        text,
        style: const TextStyle(color: Colors.white70, fontSize: 12),
      ),
    ],
  );
}
}
