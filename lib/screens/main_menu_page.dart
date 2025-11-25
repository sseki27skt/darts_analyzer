import 'package:flutter/material.dart';
import 'input_page.dart';
import 'history_page.dart';
import 'settings_page.dart';
import 'zero_one_page.dart'; // ★追加
import 'package:flutter/foundation.dart'; // これが必要です

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
                title: "CENTER COUNT-UP",
                subtitle: "ブル集中練習モード。点数配分・リングサイズ調整可能。",
                destination: const PrecisionInputPage(gameMode: 0),
                color: Colors.amber,
              ),
              if (!kIsWeb) ...[
              const SizedBox(height: 16),

              _buildGameButton(
                context,
                title: "COUNT-UP (Game)",
                subtitle: "標準的なカウントアップ。T20=60, BULL=50。",
                destination: const PrecisionInputPage(gameMode: 1),
                color: Colors.cyanAccent,
              ),

              const SizedBox(height: 16),

              // ★修正: 01 GAME (ダイアログ表示)
              _buildGameButton(
                context,
                title: "01 GAME",
                subtitle: "301〜1501。Open Out / Master Out。",
                destination: null,
                onCustomPress: () => _showZeroOneDialog(context), // ダイアログを開く
                color: Colors.blueAccent,
              ),

              if (kDebugMode) ...[
                const SizedBox(height: 16), // 余白も隠す
                _buildGameButton(
                  context,
                  title: "CRICKET COUNT (今後実装)",
                  subtitle: "クリケットナンバーのグルーピング練習。",
                  destination: null, // 遷移先がないのでnull
                  color: Colors.greenAccent,
                ),
              ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ★追加: 01設定ダイアログ
  void _showZeroOneDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const ZeroOneSettingDialog(),
    );
  }

  Widget _buildGameButton(
    BuildContext context, {
    required String title,
    required String subtitle,
    Widget? destination,
    VoidCallback? onCustomPress,
    required Color color,
  }) {
    return ElevatedButton(
      onPressed:
          onCustomPress ??
          (destination != null
              ? () => Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (c) => destination))
              : null),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(20),
        backgroundColor: color.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: destination != null || onCustomPress != null
                ? color
                : Colors.grey,
            width: 2,
          ),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // 縦方向も中央に
        crossAxisAlignment: CrossAxisAlignment.center, // 横方向を中央に！(ここが重要)
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: destination != null || onCustomPress != null
                  ? color
                  : Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

// ★追加: 01設定用のステートフルウィジェット (ダイアログの中身)
class ZeroOneSettingDialog extends StatefulWidget {
  const ZeroOneSettingDialog({super.key});

  @override
  State<ZeroOneSettingDialog> createState() => _ZeroOneSettingDialogState();
}

class _ZeroOneSettingDialogState extends State<ZeroOneSettingDialog> {
  int _selectedScore = 501; // デフォルト
  int _outOption = 0; // 0: Open Out, 1: Master Out

  final List<int> _scoreOptions = [301, 501, 701, 901, 1101, 1501];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("01 Game Settings"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // スコア選択
          const Text(
            "Start Score",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
          Wrap(
            spacing: 8.0,
            children: _scoreOptions.map((score) {
              return ChoiceChip(
                label: Text("$score"),
                selected: _selectedScore == score,
                selectedColor: Colors.blueAccent.withValues(alpha: 0.3),
                onSelected: (selected) {
                  if (selected) setState(() => _selectedScore = score);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // アウトオプション選択
          const Text(
            "Out Option",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.redAccent,
            ),
          ),
          RadioListTile<int>(
            title: const Text("Open Out"),
            subtitle: const Text("Finish on any number."),
            value: 0,
            groupValue: _outOption,
            activeColor: Colors.blueAccent,
            onChanged: (val) => setState(() => _outOption = val!),
          ),
          RadioListTile<int>(
            title: const Text("Master Out"),
            subtitle: const Text("Finish on Double, Triple, or Bull."),
            value: 1,
            groupValue: _outOption,
            activeColor: Colors.redAccent,
            onChanged: (val) => setState(() => _outOption = val!),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ZeroOnePage(
                  initialScore: _selectedScore,
                  isMasterOut: _outOption == 1,
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
          child: const Text(
            "START",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
