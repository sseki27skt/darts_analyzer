import 'package:flutter/material.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drift/drift.dart' as drift;
import '../database.dart';
import '../painters/board_painter.dart';
import 'result_page.dart';
import '../utils/score_engine.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart'; // HapticFeedback用
import 'package:flutter/foundation.dart'; // kIsWeb用

class ThrowData {
  final Offset positionMm;
  final int score;
  final String label;
  ThrowData(this.positionMm, this.score, this.label);
}

class PrecisionInputPage extends StatefulWidget {
  final int gameMode;
  const PrecisionInputPage({super.key, this.gameMode = 0});

  @override
  State<PrecisionInputPage> createState() => _PrecisionInputPageState();
}

class _PrecisionInputPageState extends State<PrecisionInputPage> {
  // --- 状態変数 ---
  double visibleDiameterMm = 160.0;
  double ringSizeMm = 63.0;
  double ringLargeMm = 83.0;
  late int _scoringMode;

  int _scoreInner = 5;
  int _scoreOuter = 4;
  int _scoreSmall = 3;
  int _scoreLarge = 2;
  int _scoreArea = 0;
  double _outBoundaryMm = 340.0;

  final List<ThrowData> _throwsData = [];
  final List<Offset> _throwsMm = [];
  final List<int> _throwScores = [];
  final List<ThrowData> _gameHistoryData = [];

  int _currentScore = 0;
  int _roundCount = 1;
  static const int maxRounds = 8;
  String _lastHitLabel = "";

  double _baseVisibleDiameter = 160.0;
  static const double minZoomMm = 40.0;
  static const double maxZoomMm = 400.0;

  // ★追加: UIの表示状態
  bool _isUiVisible = true;
  Offset _boardOffset = Offset.zero;

  @override
  void initState() {
    super.initState();
    _scoringMode = widget.gameMode;
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      ringSizeMm = prefs.getDouble('ring_size_mm') ?? 63.0;
      ringLargeMm = prefs.getDouble('ring_large_mm') ?? 83.0;

      _scoreInner = prefs.getInt('score_inner') ?? 5;
      _scoreOuter = prefs.getInt('score_outer') ?? 4;
      _scoreSmall = prefs.getInt('score_small') ?? 3;
      _scoreLarge = prefs.getInt('score_large') ?? 2;
      _scoreArea = prefs.getInt('score_area') ?? 0;

      // ▼▼▼ 修正: デフォルト値の決定ロジックを変更 ▼▼▼
      // Center Count-Up (mode 0) ならデフォルトは 1 (Inside Triple)
      // それ以外なら 0 (Full Board)
      int defaultBoundary = widget.gameMode == 0 ? 1 : 0;
      int boundaryType = prefs.getInt('boundary_type') ?? defaultBoundary;
      // ▲▲▲ 修正ここまで ▲▲▲

      switch (boundaryType) {
        case 0:
          _outBoundaryMm = 340.0;
          break;
        case 1:
          _outBoundaryMm = 198.0;
          break;

        default:
          _outBoundaryMm = 340.0;
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

  void _handleTap(
    TapUpDetails details,
    BoxConstraints constraints,
    double boardSizePx,
  ) {
    if (_throwsMm.length >= 3) return;

    final double centerX = constraints.maxWidth / 2;
    final double centerY = constraints.maxHeight / 2;
    final Offset localPos = details.localPosition;

    final Offset relativePx = Offset(
      localPos.dx - centerX - _boardOffset.dx,
      localPos.dy - centerY - _boardOffset.dy,
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

  void _undo() {
    if (_throwsData.isEmpty) return;
    setState(() {
      final removed = _throwsData.removeLast();
      _throwsMm.removeLast();
      _throwScores.removeLast();
      _currentScore -= removed.score;
      if (_throwsData.isNotEmpty) {
        _lastHitLabel = _throwsData.last.label;
      } else {
        _lastHitLabel = "";
      }
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
        double sumX = 0, sumY = 0;
        for (var p in _gameHistoryData) {
          sumX += p.positionMm.dx;
          sumY += p.positionMm.dy;
        }
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

        Navigator.of(context)
            .push(
              MaterialPageRoute(
                builder: (context) => ResultPage(
                  gameHistoryMm: _gameHistoryData
                      .map((e) => e.positionMm)
                      .toList(),
                  totalScore: scoreToSave,
                  visibleDiameterMm: visibleDiameterMm,
                  ringSizeMm: ringSizeMm,
                  ringLargeMm: ringLargeMm,
                  gameMode: _scoringMode,
                ),
              ),
            )
            .then((_) {
              _saveGameResult(
                scoreToSave,
                meanX,
                meanY,
                sdX,
                sdY,
                pointsToSave,
              );
              _resetGame();
            });
      }
    });
  }

  Future<void> _saveGameResult(
    int score,
    double mx,
    double my,
    double sdx,
    double sdy,
    List<ThrowData> pointsToSave,
  ) async {
    if (kIsWeb) {
      print("Web版のため、データベースへの保存をスキップします");
      return;
    }
    final gameId = await database
        .into(database.games)
        .insert(
          GamesCompanion.insert(
            date: DateTime.now(),
            score: score,
            meanX: mx,
            meanY: my,
            sdX: sdx,
            sdY: sdy,
            ringSizeMm: ringSizeMm,
            ringLargeMm: ringLargeMm,
            gameType: drift.Value(_scoringMode),
            isMasterOut: const drift.Value(false),
          ),
        );

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
            segmentLabel: drift.Value(p.label),
          ),
        );
      }
    });
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
      visibleDiameterMm = 160.0;
      _baseVisibleDiameter = 160.0;
      _boardOffset = Offset.zero;
    });
  }

  @override
  Widget build(BuildContext context) {
    String title = _scoringMode == 0 ? 'Center Count-Up' : 'Count-Up';

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.black.withValues(alpha: 0.8),
        elevation: 0,
        actions: const [],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // --- Layer 1: ダーツボード (最背面) ---
            Positioned.fill(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  double availableSize = min(
                    constraints.maxWidth,
                    constraints.maxHeight,
                  );

                  return Listener(
                    onPointerSignal: _handleScrollZoom,
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onScaleStart: (details) {
                        _baseVisibleDiameter = visibleDiameterMm;
                      },
                      onScaleUpdate: (details) {
                        if (details.scale != 1.0) {
                          _handleZoomUpdate(details.scale);
                        }
                        setState(() {
                          _boardOffset += details.focalPointDelta;
                        });
                      },
                      // 長押しで「スコア表示」のON/OFF切り替え
                      onLongPress: () {
                        setState(() {
                          _isUiVisible = !_isUiVisible;
                        });
                        HapticFeedback.mediumImpact();
                      },
                      onTapUp: (details) =>
                          _handleTap(details, constraints, availableSize),

                      child: ClipRect(
                        child: Container(
                          color: Colors.transparent,
                          width: constraints.maxWidth,
                          height: constraints.maxHeight,
                          child: Center(
                            child: Transform.translate(
                              offset: _boardOffset,
                              child: RepaintBoundary(
                                child: CustomPaint(
                                  size: Size(availableSize, availableSize),
                                  painter: BoardPainter(
                                    throwsMm: _throwsMm.toList(),
                                    visibleDiameterMm: visibleDiameterMm,
                                    ringSizeMm: ringSizeMm,
                                    ringLargeMm: ringLargeMm,
                                    showPracticeRings: _scoringMode == 0,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // --- Layer 2: スコア情報 (長押しで消える) ---
            Positioned(
              top: 10,
              left: 20,
              right: 20,
              child: AnimatedOpacity(
                opacity: _isUiVisible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: IgnorePointer(
                  ignoring: true,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "ROUND $_roundCount / $maxRounds",
                            style: const TextStyle(
                              color: Colors.amber,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              shadows: kIsWeb ? [] : [
                                Shadow(
                                  blurRadius: 4.0,
                                  color: Colors.black,
                                  offset: Offset(2, 2),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            "Total: $_currentScore",
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              shadows: kIsWeb ? [] : const [
                                Shadow(
                                  blurRadius: 4.0,
                                  color: Colors.black,
                                  offset: Offset(2, 2),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _lastHitLabel.isEmpty ? "READY" : "HIT: $_lastHitLabel",
                        style: TextStyle(
                          fontSize: 32,
                          color: _lastHitLabel.contains("OUT")
                              ? Colors.redAccent
                              : Colors.cyanAccent,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.0,
                          shadows: kIsWeb ? [] : const [
                            Shadow(
                              blurRadius: 10.0,
                              color: Colors.black,
                              offset: Offset(0, 0),
                            ),
                            Shadow(
                              blurRadius: 2.0,
                              color: Colors.black,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(3, (index) {
                          String scoreText = index < _throwScores.length
                              ? "${_throwScores[index]}"
                              : "-";
                          bool isCurrent = index == _throwScores.length;

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                            ),
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.5),
                                border: Border.all(
                                  color: isCurrent
                                      ? Colors.blueAccent
                                      : Colors.white30,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                scoreText,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // --- Layer 3: アクションボタン (★修正: 常に表示) ---
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Row(
                // AnimatedOpacity と IgnorePointer を削除
                children: [
                  // Undoボタン (1投以上ある時だけ表示)
                  if (_throwsData.isNotEmpty)
                    SizedBox(
                      width: 60,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _undo,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[800],
                          padding: EdgeInsets.zero,
                          elevation: 8,
                          shadowColor: Colors.black.withValues(alpha: 0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: Colors.white24),
                          ),
                        ),
                        child: const Icon(Icons.undo, color: Colors.white),
                      ),
                    ),

                  // NEXT ROUND ボタン (3投完了時のみ出現)
                  if (_throwsMm.length == 3) ...[
                    const SizedBox(width: 10),
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _nextRound,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _roundCount == maxRounds
                                ? Colors.redAccent
                                : Colors.blueAccent,
                            disabledBackgroundColor: Colors.grey[800]!
                                .withValues(alpha: 0.8),
                            elevation: 8,
                            shadowColor: Colors.black.withValues(alpha: 0.5),
                          ),
                          child: Text(
                            _roundCount == maxRounds
                                ? "SHOW RESULT"
                                : "NEXT ROUND",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
