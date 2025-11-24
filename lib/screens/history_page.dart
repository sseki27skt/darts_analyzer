import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as drift;
import '../database.dart';
import 'result_page.dart';
import 'graph_page.dart';

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
                final dateStr =
                    "${record.date.month}/${record.date.day} ${record.date.hour.toString().padLeft(2, '0')}:${record.date.minute.toString().padLeft(2, '0')}";

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  color: Colors.grey[900],
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _scoreToColor(record.score),
                      child: Text(
                        "${record.score}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(dateStr),
                    subtitle: Text(
                      "S:${record.ringSizeMm.toStringAsFixed(0)} / X:${record.sdX.toStringAsFixed(1)}",
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _openDetail(context, record),
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
}
