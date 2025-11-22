import 'package:flutter/material.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drift/drift.dart' as drift;
import '../database.dart';
import '../painters/board_painter.dart';
import 'result_page.dart';
import '../utils/score_engine.dart'; 
import 'package:flutter/gestures.dart'; // マウスホイール用

// ★1. データ構造の定義（この位置が正しい）
class ThrowData {
  final Offset positionMm;
  final int score;
  final String label;

  ThrowData(this.positionMm, this.score, this.label);
}

class PrecisionInputPage extends StatefulWidget {
  const PrecisionInputPage({super.key});

  @override
  State<PrecisionInputPage> createState() => _PrecisionInputPageState();
}

class _PrecisionInputPageState extends State<PrecisionInputPage> {
  // --- 状態変数定義 (重複を排除し、一つに統合) ---
  
  // キャリブレーションとモード
  double visibleDiameterMm = 160.0;
  double ringSizeMm = 63.0;
  double ringLargeMm = 83.0;
  double ringHalfTripleMm = 107.0;
  int _scoringMode = 0; 
  
  // スコア設定
  int _scoreInner = 5;
  int _scoreOuter = 4;
  int _scoreSmall = 3;
  int _scoreLarge = 2;
  int _scoreHalfTriple = 1;
  int _scoreArea = 0;
  double _outBoundaryMm = 340.0;

  // ゲームデータ管理
  final List<ThrowData> _throwsData = [];      // 現在の投擲データ (ロジック用)
  final List<Offset> _throwsMm = [];           // Painter用 (座標のみ)
  final List<int> _throwScores = [];           // UI表示用 (点数のみ)
  final List<ThrowData> _gameHistoryData = [];  // 過去のラウンドの投擲データ

  // ゲーム進行
  int _currentScore = 0;
  int _roundCount = 1;
  static const int maxRounds = 8;
  String _lastHitLabel = "";

  // ズーム操作用の一時変数
  double _baseVisibleDiameter = 160.0; 
  static const double minZoomMm = 160.0; 
  static const double maxZoomMm = 400.0; 


  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      ringSizeMm = prefs.getDouble('ring_size_mm') ?? 63.0;
      ringLargeMm = prefs.getDouble('ring_large_mm') ?? 83.0;
      ringHalfTripleMm = prefs.getDouble('ring_half_triple_mm') ?? 107.0;

      _scoreInner = prefs.getInt('score_inner') ?? 5;
      _scoreOuter = prefs.getInt('score_outer') ?? 4;
      _scoreSmall = prefs.getInt('score_small') ?? 3;
      _scoreLarge = prefs.getInt('score_large') ?? 2;
      _scoreHalfTriple = prefs.getInt('score_half_triple') ?? 1;
      _scoreArea = prefs.getInt('score_area') ?? 0;
      _scoringMode = prefs.getInt('scoring_mode') ?? 0;
      
      int boundaryType = prefs.getInt('boundary_type') ?? 0;
      switch (boundaryType) {
        case 0: _outBoundaryMm = 340.0; break;
        case 1: _outBoundaryMm = 214.0; break;
        case 2: _outBoundaryMm = ringHalfTripleMm; break;
        default: _outBoundaryMm = 340.0;
      }
      
      _baseVisibleDiameter = visibleDiameterMm;
    });
  }

  int _calculatePoint(double distanceMm) {
    if (distanceMm > _outBoundaryMm / 2) return 0;
    if (distanceMm <= 8.0) return _scoreInner;
    if (distanceMm <= 22.0) return _scoreOuter;
    if (distanceMm <= ringSizeMm / 2) return _scoreSmall;
    if (distanceMm <= ringLargeMm / 2) return _scoreLarge;
    if (distanceMm <= ringHalfTripleMm / 2) return _scoreHalfTriple;
    return _scoreArea;
  }

  void _handleZoomUpdate(double scale) {
    setState(() {
      double newVisibleDiameter = _baseVisibleDiameter / scale;
      visibleDiameterMm = newVisibleDiameter.clamp(minZoomMm, maxZoomMm);
    });
  }

  void _handleScrollZoom(PointerSignalEvent event) {
    if (event is PointerScrollEvent) {
      double sensitivity = 0.5;
      double delta = event.scrollDelta.dy;
      
      setState(() {
        double newVisibleDiameter = visibleDiameterMm + delta * sensitivity;
        visibleDiameterMm = newVisibleDiameter.clamp(minZoomMm, maxZoomMm);
        _baseVisibleDiameter = visibleDiameterMm;
      });
    }
  }


  void _handleTap(TapUpDetails details, double boardSizePx) {
    if (_throwsMm.length >= 3) return;

    final double centerX = boardSizePx / 2;
    final double centerY = boardSizePx / 2;
    final Offset localPos = details.localPosition;

    final Offset relativePx = Offset(
      localPos.dx - centerX,
      localPos.dy - centerY,
    );

    double scale = visibleDiameterMm / boardSizePx;
    Offset posMm = relativePx * scale;
    double distanceMm = posMm.distance;

    final realResult = DartsScoreEngine.calculate(posMm);
    String label = realResult['label'];
    int realScore = realResult['score']; 

    setState(() {
      int pts = 0;
      if (_scoringMode == 1) {
        pts = realScore;
      } else {
        pts = _calculatePoint(distanceMm);
      }

      final newThrow = ThrowData(posMm, pts, label);
      _throwsData.add(newThrow);
      _throwsMm.add(posMm); 

      _throwScores.add(pts);
      _currentScore += pts;
      _lastHitLabel = label;
    });
  }

  void _nextRound() {
    _gameHistoryData.addAll(_throwsData); 

    setState(() {
      if (_roundCount < maxRounds) {
        _roundCount++;
        _throwsData.clear(); 
        _throwsMm.clear();
        _throwScores.clear();
        _lastHitLabel = ""; 
      } else {
        // ゲーム終了後の処理
        double sumX = 0, sumY = 0;
        for (var p in _gameHistoryData) { sumX += p.positionMm.dx; sumY += p.positionMm.dy; }
        double meanX = sumX / _gameHistoryData.length;
        double meanY = sumY / _gameHistoryData.length;

        double sumSqDiffX = 0, sumSqDiffY = 0;
        for (var p in _gameHistoryData) {
          sumSqDiffX += pow(p.positionMm.dx - meanX, 2);
          sumSqDiffY += pow(p.positionMm.dy - meanY, 2);
        }
        double sdX = sqrt(sumSqDiffX / _gameHistoryData.length);
        double sdY = sqrt(sumSqDiffY / _gameHistoryData.length);

        final pointsToSave = List<ThrowData>.from(_gameHistoryData); 
        final scoreToSave = _currentScore;

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ResultPage(
              gameHistoryMm: _gameHistoryData.map((e) => e.positionMm).toList(),
              totalScore: scoreToSave,
              visibleDiameterMm: visibleDiameterMm,
              ringSizeMm: ringSizeMm,
              ringLargeMm: ringLargeMm,
            ),
          ),
        ).then((_) {
          _saveGameResult(scoreToSave, meanX, meanY, sdX, sdY, pointsToSave); 
          _resetGame();
        });
      }
    });
  }

  Future<void> _saveGameResult(
    int score, 
    double mx, double my, double sdx, double sdy,
    List<ThrowData> pointsToSave, 
  ) async {
    final gameId = await database.into(database.games).insert(GamesCompanion.insert(
      date: DateTime.now(),
      score: score,
      meanX: mx,
      meanY: my,
      sdX: sdx,
      sdY: sdy,
      ringSizeMm: ringSizeMm,
      ringLargeMm: ringLargeMm,
    ));

    await database.batch((batch) {
      for (int i = 0; i < pointsToSave.length; i++) {
        final p = pointsToSave[i];
        batch.insert(
          database.throws,
          ThrowsCompanion.insert(
            gameId: gameId,
            x: p.positionMm.dx, 
            y: p.positionMm.dy, 
            orderIndex: i,
            segmentLabel: drift.Value(p.label), // ★修正済み
          ),
        );
      }
    });
    print("Game Saved to DB! ID: $gameId");
  }

  void _resetGame() {
    setState(() {
      _gameHistoryData.clear(); 
      _throwsData.clear();     
      _throwsMm.clear();
      _throwScores.clear();
      _currentScore = 0;
      _roundCount = 1;
      _lastHitLabel = "";
      visibleDiameterMm = minZoomMm; 
      _baseVisibleDiameter = minZoomMm; 
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Bull Master - Practice'),
        actions: const [],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Column(
                children: [
                  Text("ROUND $_roundCount / $maxRounds", style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  
                  Text("Total Score", style: TextStyle(color: Colors.grey[400], fontSize: 14)),
                  Text("$_currentScore", style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900, height: 1.0)),
                  
                  const SizedBox(height: 5),

                  Text(
                    _lastHitLabel.isEmpty ? "Ready" : "HIT: $_lastHitLabel",
                    style: const TextStyle(fontSize: 24, color: Colors.cyanAccent, fontWeight: FontWeight.bold, letterSpacing: 2.0),
                  ),
                  const SizedBox(height: 10),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      String scoreText = index < _throwScores.length ? "${_throwScores[index]}" : "-";
                      bool isCurrent = index == _throwScores.length;
                      
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Container(
                          width: 50, height: 50,
                          decoration: BoxDecoration(
                            color: isCurrent ? Colors.blueGrey[800] : Colors.grey[900],
                            border: Border.all(color: isCurrent ? Colors.blueAccent : Colors.transparent, width: 2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Text(scoreText, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        ),
                      );
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    double availableSize = min(constraints.maxWidth, constraints.maxHeight);
                    
                    return Center(
                      child: Listener( 
                        onPointerSignal: _handleScrollZoom,
                        child: GestureDetector( 
                          onScaleStart: (details) {
                            _baseVisibleDiameter = visibleDiameterMm;
                          },
                          onScaleUpdate: (details) {
                            if (details.scale != 1.0) {
                              _handleZoomUpdate(details.scale);
                            }
                          },
                          onTapUp: (details) => _handleTap(details, availableSize),
                          child: CustomPaint(
                            size: Size(availableSize, availableSize),
                            painter: BoardPainter(
                              throwsMm: _throwsMm,
                              visibleDiameterMm: visibleDiameterMm,
                              ringSizeMm: ringSizeMm,
                              ringLargeMm: ringLargeMm,
                              ringHalfTripleMm: ringHalfTripleMm,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _throwsMm.length == 3 ? _nextRound : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _roundCount == maxRounds ? Colors.redAccent : Colors.blueAccent,
                    disabledBackgroundColor: Colors.grey[800],
                  ),
                  child: Text(_roundCount == maxRounds ? "SHOW RESULT" : "NEXT ROUND", style: const TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}