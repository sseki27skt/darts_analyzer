// lib/screens/settings_page.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  final double currentRingSizeMm;
  final double currentRingLargeMm;
  // ★削除: currentVisibleMm は不要

  const SettingsPage({
    super.key, 
    required this.currentRingSizeMm, 
    required this.currentRingLargeMm, 
    // ★削除
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // --- 状態変数定義をここに集中させる ---
  late double _ringSizeMm;
  late double _ringLargeMm;
  // ★削除: _visibleMm は不要

  // ... (他のスコア設定変数, _scoringMode などはそのまま) ...
  double _ringHalfTripleMm = 107.0; 
  int _scoreInner = 5;
  // ...

  @override
  void initState() {
    super.initState();
    _ringSizeMm = widget.currentRingSizeMm;
    _ringLargeMm = widget.currentRingLargeMm;
    // ★削除: _visibleMm の初期化は不要
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _ringSizeMm = prefs.getDouble('ring_size_mm') ?? 63.0;
      _ringLargeMm = prefs.getDouble('ring_large_mm') ?? 83.0;
      // ★削除: visibleDiameterMm のロードは不要

      // ... (スコア設定のロードはそのまま) ...
      _ringHalfTripleMm = prefs.getDouble('ring_half_triple_mm') ?? 107.0;
      _scoreInner = prefs.getInt('score_inner') ?? 5;
      // ...
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('ring_size_mm', _ringSizeMm);
    await prefs.setDouble('ring_large_mm', _ringLargeMm);
    // ★削除: 'visible_mm' の保存は不要
    
    // ... (他のスコア設定の保存はそのまま) ...
    await prefs.setDouble('ring_half_triple_mm', _ringHalfTripleMm);
    await prefs.setInt('score_inner', _scoreInner);
    // ...

    if (mounted) {
      Navigator.of(context).pop({
        'ring': _ringSizeMm,
        'ringLarge': _ringLargeMm,
        // ★削除: 'visible' は不要
        'needsReload': true, 
      });
    }
  }

  // ... (build メソッド内で Slider を削除) ...
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ... (Scoring Rules Section) ...

              const Divider(height: 40, thickness: 1, color: Colors.white24),

              const Text("Calibration", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              
              Text("Small Ring: ${_ringSizeMm.toStringAsFixed(1)} mm"),
              Slider(value: _ringSizeMm, min: 20.0, max: 100.0, divisions: 80, label: "${_ringSizeMm.toStringAsFixed(1)} mm", onChanged: (val) => setState(() => _ringSizeMm = val)),
              
              Text("Large Ring: ${_ringLargeMm.toStringAsFixed(1)} mm"),
              Slider(value: _ringLargeMm, min: 40.0, max: 200.0, divisions: 160, label: "${_ringLargeMm.toStringAsFixed(1)} mm", onChanged: (val) => setState(() => _ringLargeMm = val)),

              Text("Half-Triple Ring: ${_ringHalfTripleMm.toStringAsFixed(1)} mm"),
              Slider(value: _ringHalfTripleMm, min: 80.0, max: 220.0, divisions: 140, label: "${_ringHalfTripleMm.toStringAsFixed(1)} mm", activeColor: Colors.cyanAccent, onChanged: (val) => setState(() => _ringHalfTripleMm = val)),
              
              // ★削除: Zoomスライダーは不要
              // Text("Zoom: ..."),
              // Slider(...)

              const Divider(height: 40, thickness: 1, color: Colors.white24),
              
              // ... (Data Management Section) ...
              
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity, height: 50,
                child: ElevatedButton.icon(
                  onPressed: _saveSettings,
                  icon: const Icon(Icons.save),
                  label: const Text("SAVE & CLOSE"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreInput(String label, int value, Function(int) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Row(
          children: [
            IconButton(icon: const Icon(Icons.remove_circle_outline), onPressed: () { if (value > 0) setState(() => onChanged(value - 1)); }),
            Text("$value", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: () { if (value < 100) setState(() => onChanged(value + 1)); }),
          ],
        ),
      ],
    );
  }
}