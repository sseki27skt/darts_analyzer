import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drift/drift.dart' as drift;
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:math';
import '../database.dart';
import 'package:flutter/foundation.dart';

class SettingsPage extends StatefulWidget {
  final double currentRingSizeMm;
  final double currentRingLargeMm;

  const SettingsPage({
    super.key,
    required this.currentRingSizeMm,
    required this.currentRingLargeMm,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late double _ringSizeMm;
  late double _ringLargeMm;

  int _scoreInner = 5;
  int _scoreOuter = 4;
  int _scoreSmall = 3;
  int _scoreLarge = 2;
  int _scoreArea = 1;
  int _boundaryType = 1; // デフォルト: Triple Inner
  int _scoringMode = 0;

  @override
  void initState() {
    super.initState();
    _ringSizeMm = widget.currentRingSizeMm;
    _ringLargeMm = widget.currentRingLargeMm;
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _ringSizeMm = prefs.getDouble('ring_size_mm') ?? 63.0;
      _ringLargeMm = prefs.getDouble('ring_large_mm') ?? 83.0;

      _scoreInner = prefs.getInt('score_inner') ?? 5;
      _scoreOuter = prefs.getInt('score_outer') ?? 4;
      _scoreSmall = prefs.getInt('score_small') ?? 3;
      _scoreLarge = prefs.getInt('score_large') ?? 2;
      _scoreArea = prefs.getInt('score_area') ?? 1;
      _scoringMode = prefs.getInt('scoring_mode') ?? 0;

      // ★修正: ここだけにする（重複削除）
      _boundaryType = prefs.getInt('boundary_type_center') ?? 1;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('ring_size_mm', _ringSizeMm);
    await prefs.setDouble('ring_large_mm', _ringLargeMm);

    // ★修正: boundary_type_center だけに保存する
    await prefs.setInt('boundary_type_center', _boundaryType);

    await prefs.setInt('score_inner', _scoreInner);
    await prefs.setInt('score_outer', _scoreOuter);
    await prefs.setInt('score_small', _scoreSmall);
    await prefs.setInt('score_large', _scoreLarge);

    await prefs.setInt('score_area', _scoreArea);
    // await prefs.setInt('boundary_type', _boundaryType); // ← ★古いキーへの保存は削除！
    await prefs.setInt('scoring_mode', _scoringMode);

    if (mounted) {
      Navigator.of(context).pop({
        'ring': _ringSizeMm,
        'ringLarge': _ringLargeMm,
        'needsReload': true,
      });
    }
  }

  // ... (以下のデータ管理ロジックやbuildメソッドはそのまま) ...
  // _exportData, _importData, _generateDummyData, _clearDatabase など
  // buildメソッドの中身も変更なし

  // (省略して記述していますが、元のコードの残りの部分をそのまま貼り付けてください)
  // ...

  // ----------------------------------------
  // データ管理ロジック (元のコードを維持)
  // ----------------------------------------
  Future<void> _exportData() async {
    // ... (元のコード)
    try {
      final allGames = await database.select(database.games).get();
      final allThrows = await database.select(database.throws).get();

      final Map<int, List<Map<String, dynamic>>> throwsByGame = {};
      for (var t in allThrows) {
        if (!throwsByGame.containsKey(t.gameId)) {
          throwsByGame[t.gameId] = [];
        }
        throwsByGame[t.gameId]!.add({
          'x': t.x,
          'y': t.y,
          'orderIndex': t.orderIndex,
          'segmentLabel': t.segmentLabel,
        });
      }

      final List<Map<String, dynamic>> exportList = [];
      for (var game in allGames) {
        exportList.add({
          'meta': {
            'date': game.date.toIso8601String(),
            'score': game.score,
            'meanX': game.meanX,
            'meanY': game.meanY,
            'sdX': game.sdX,
            'sdY': game.sdY,
            'ringSizeMm': game.ringSizeMm,
            'ringLargeMm': game.ringLargeMm,
            'gameType': game.gameType,
          },
          'points': throwsByGame[game.id] ?? [],
        });
      }

      final jsonString = jsonEncode(exportList);
      await Clipboard.setData(ClipboardData(text: jsonString));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Exported ${exportList.length} games to Clipboard!"),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Export Failed: $e")));
      }
    }
  }

  Future<void> _importData() async {
    // ... (元のコード)
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Import Data (DB)"),
        content: const Text(
          "Warning: This will DELETE all current data.\nAre you sure?",
          style: TextStyle(color: Colors.redAccent),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "Overwrite",
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text == null || data!.text!.isEmpty) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Clipboard is empty")));
      return;
    }

    try {
      final List<dynamic> jsonList = jsonDecode(data.text!);

      await database.transaction(() async {
        await database.delete(database.throws).go();
        await database.delete(database.games).go();

        for (final item in jsonList) {
          final Map<String, dynamic> meta = item['meta'];
          final List<dynamic> points = item['points'];

          final gameId = await database
              .into(database.games)
              .insert(
                GamesCompanion.insert(
                  date: DateTime.parse(meta['date']),
                  score: meta['score'],
                  meanX: (meta['meanX'] as num).toDouble(),
                  meanY: (meta['meanY'] as num).toDouble(),
                  sdX: (meta['sdX'] as num).toDouble(),
                  sdY: (meta['sdY'] as num).toDouble(),
                  ringSizeMm: (meta['ringSizeMm'] as num).toDouble(),
                  ringLargeMm:
                      (meta['ringLargeMm'] as num?)?.toDouble() ?? 83.0,
                  gameType: drift.Value(meta['gameType'] as int? ?? 0),
                ),
              );

          for (final p in points) {
            await database
                .into(database.throws)
                .insert(
                  ThrowsCompanion.insert(
                    gameId: gameId,
                    x: (p['x'] as num).toDouble(),
                    y: (p['y'] as num).toDouble(),
                    orderIndex: p['orderIndex'],
                    segmentLabel: drift.Value(p['segmentLabel'] ?? ''),
                  ),
                );
          }
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Import Successful! Please restart app."),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Import Failed: $e")));
      }
    }
  }

  Future<void> _generateDummyData() async {
    // ... (元のコード)
    if (!kDebugMode) return;
    final random = Random();
    final now = DateTime.now();

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Generate Dummy Data"),
        content: const Text(
          "This will add 30 fake game records with plots.\nAre you sure?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "Generate",
              style: TextStyle(color: Colors.orangeAccent),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await database.transaction(() async {
      for (int i = 30; i >= 0; i--) {
        final date = now.subtract(Duration(days: i, hours: random.nextInt(12)));
        final score = 40 + random.nextInt(61);
        final spread = 40.0 - (i * 0.8);

        final List<Offset> dummyPoints = [];
        double sumX = 0, sumY = 0;
        for (int j = 0; j < 3; j++) {
          double u = 0, v = 0;
          while (u == 0) {
            u = random.nextDouble();
          }
          while (v == 0) {
            v = random.nextDouble();
          }
          double mag = sqrt(-2.0 * log(u)) * (spread / 2);
          double x = mag * cos(2.0 * pi * v);
          double y = mag * sin(2.0 * pi * v);
          dummyPoints.add(Offset(x, y));
          sumX += x;
          sumY += y;
        }

        double meanX = sumX / 3;
        double meanY = sumY / 3;
        double sumSqX = 0, sumSqY = 0;
        for (var p in dummyPoints) {
          sumSqX += pow(p.dx - meanX, 2);
          sumSqY += pow(p.dy - meanY, 2);
        }
        double sdX = sqrt(sumSqX / 3);
        double sdY = sqrt(sumSqY / 3);

        final gameId = await database
            .into(database.games)
            .insert(
              GamesCompanion.insert(
                date: date,
                score: score,
                meanX: meanX,
                meanY: meanY,
                sdX: sdX,
                sdY: sdY,
                ringSizeMm: _ringSizeMm,
                ringLargeMm: _ringLargeMm,
                gameType: drift.Value(0), // Center mode
              ),
            );

        for (int j = 0; j < 3; j++) {
          await database
              .into(database.throws)
              .insert(
                ThrowsCompanion.insert(
                  gameId: gameId,
                  x: dummyPoints[j].dx,
                  y: dummyPoints[j].dy,
                  orderIndex: j,
                  segmentLabel: drift.Value("DEBUG"),
                ),
              );
        }
      }
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Generated 30 dummy records!")),
      );
    }
  }

  Future<void> _clearDatabase() async {
    // ... (元のコード)
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Reset Database"),
        content: const Text(
          "DELETE ALL DATA. Are you sure?",
          style: TextStyle(color: Colors.redAccent),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "DELETE ALL",
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await database.transaction(() async {
      await database.delete(database.throws).go();
      await database.delete(database.games).go();
    });

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Database Cleared!")));
    }
  }

  Widget _buildScoreInput(String label, int value, Function(int) onChanged) {
    // ... (元のコード)
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: () {
                if (value > 0) setState(() => onChanged(value - 1));
              },
            ),
            Text(
              "$value",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () {
                if (value < 100) setState(() => onChanged(value + 1));
              },
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // ... (元のコード: buildメソッド全体)
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Scoring Rules (Center Mode)",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                ),
              ),
              const SizedBox(height: 10),

              // --- Boundary Setting ---
              const Text(
                "Valid Board Area (Out Boundary)",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              DropdownButton<int>(
                value: _boundaryType,
                isExpanded: true,
                dropdownColor: Colors.grey[800],
                items: const [
                  DropdownMenuItem(
                    value: 0,
                    child: Text("Outside Double Ring (> 340mm)"),
                  ),
                  DropdownMenuItem(
                    value: 1,
                    child: Text("Inside Triple Ring (< 198mm)"),
                  ),
                ],
                onChanged: (val) => setState(() => _boundaryType = val!),
              ),
              const SizedBox(height: 20),

              _buildScoreInput(
                "Inner Bull (< 8mm)",
                _scoreInner,
                (v) => _scoreInner = v,
              ),
              _buildScoreInput(
                "Outer Bull (< 22mm)",
                _scoreOuter,
                (v) => _scoreOuter = v,
              ),
              _buildScoreInput(
                "Small Ring",
                _scoreSmall,
                (v) => _scoreSmall = v,
              ),
              _buildScoreInput(
                "Large Ring",
                _scoreLarge,
                (v) => _scoreLarge = v,
              ),
              _buildScoreInput(
                "Other Valid Area",
                _scoreArea,
                (v) => _scoreArea = v,
              ),

              const Divider(height: 40, thickness: 1, color: Colors.white24),

              const Text(
                "Calibration",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              Text("Small Ring: ${_ringSizeMm.toStringAsFixed(1)} mm"),
              Slider(
                value: _ringSizeMm,
                min: 20.0,
                max: 100.0,
                divisions: 80,
                label: "${_ringSizeMm.toStringAsFixed(1)} mm",
                onChanged: (val) => setState(() => _ringSizeMm = val),
              ),

              Text("Large Ring: ${_ringLargeMm.toStringAsFixed(1)} mm"),
              Slider(
                value: _ringLargeMm,
                min: 40.0,
                max: 200.0,
                divisions: 160,
                label: "${_ringLargeMm.toStringAsFixed(1)} mm",
                onChanged: (val) => setState(() => _ringLargeMm = val),
              ),

              const Divider(height: 40, thickness: 1, color: Colors.white24),

              if (!kIsWeb) ...[
                const Text(
                  "Data Management",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.cyanAccent,
                  ),
                ),
              ],
              if (kDebugMode) ...[
                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.science),
                    label: const Text("Generate Dummy Data (Debug)"),
                    onPressed: _generateDummyData,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.orangeAccent,
                    ),
                  ),
                ),
              ],

              if (!kIsWeb) ...[
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.copy),
                        label: const Text("Export DB"),
                        onPressed: _exportData,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.paste),
                        label: const Text("Import DB"),
                        onPressed: _importData,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.redAccent,
                        ),
                      ),
                    ),
                  ],
                ),

                const Text(
                  "※Export: Copy JSON to clipboard.\n※Import: Paste JSON from clipboard.",
                  style: TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ],

              if (!kIsWeb) ...[
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.delete_forever),
                    label: const Text("Reset Database"),
                    onPressed: _clearDatabase,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side: const BorderSide(color: Colors.redAccent),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _saveSettings,
                  icon: const Icon(Icons.save),
                  label: const Text("SAVE & CLOSE"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
