import 'package:flutter/material.dart';
import 'input_page.dart';
import 'history_page.dart';
import 'settings_page.dart';

class GameSelectionPage extends StatelessWidget {
  const GameSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bull Master - Practice Menu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const HistoryPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // SettingsPageに遷移しますが、InputPageの状態に依存しないため、
              // ここではダミーの設定値を渡します。
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SettingsPage(
                    currentRingSizeMm: 63.0,
                    currentRingLargeMm: 83.0,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildGameButton(
                context,
                title: "CENTER COUNT-UP (練習)",
                subtitle: "ブル集中練習モード。点数配分・リングサイズ調整可能。",
                destination: const PrecisionInputPage(),
                color: Colors.amber,
              ),
              const SizedBox(height: 16),
              _buildGameButton(
                context,
                title: "01 GAME (今後実装)",
                subtitle: "ゼロワンのスタッツ計測練習モード。",
                destination: null, // まだ実装しないのでnull
                color: Colors.blueAccent,
              ),
              const SizedBox(height: 16),
              _buildGameButton(
                context,
                title: "CRICKET COUNT (今後実装)",
                subtitle: "クリケットナンバーのグルーピング練習。",
                destination: null, // まだ実装しないのでnull
                color: Colors.greenAccent,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameButton(
    BuildContext context, {
    required String title,
    required String subtitle,
    required Widget? destination,
    required Color color,
  }) {
    return ElevatedButton(
      onPressed: destination != null
          ? () => Navigator.of(context).push(
                MaterialPageRoute(builder: (c) => destination),
              )
          : null,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(20),
        backgroundColor: color.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: destination != null ? color : Colors.grey, width: 2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: destination != null ? color : Colors.grey)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.white70)),
        ],
      ),
    );
  }
}