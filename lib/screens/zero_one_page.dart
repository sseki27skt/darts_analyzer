import 'package:flutter/material.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drift/drift.dart' as drift;
import 'package:flutter/services.dart';
import '../database.dart';
import '../painters/board_painter.dart';
import 'result_page.dart';
import '../utils/score_engine.dart';
import 'package:flutter/gestures.dart';

class ThrowData {
  final Offset positionMm;
  final int score;
  final String label;
  ThrowData(this.positionMm, this.score, this.label);
}

class ZeroOnePage extends StatefulWidget {
  final int initialScore; // 301, 501, ...
  final bool isMasterOut; // false: Open, true: Master

  const ZeroOnePage({
    super.key,
    required this.initialScore,
    required this.isMasterOut,
  });

  @override
  State<ZeroOnePage> createState() => _ZeroOnePageState();
}

class _ZeroOnePageState extends State<ZeroOnePage> {
  double visibleDiameterMm = 160.0;
  double ringSizeMm = 63.0;
  double ringLargeMm = 83.0;

  final List<ThrowData> _throwsData = [];
  final List<Offset> _throwsMm = [];
  final List<int> _throwScores = [];
  final List<ThrowData> _gameHistoryData = [];

  late int _currentScore;
  int _roundStartScore = 0;
  int _roundCount = 1;
  static const int maxRounds = 20;

  String _lastHitLabel = "";
  bool _isBust = false;

  double _baseVisibleDiameter = 160.0;
  static const double minZoomMm = 160.0;
  static const double maxZoomMm = 400.0;
  Offset _boardOffset = Offset.zero;
  bool _isUiVisible = true;

  @override
  void initState() {
    super.initState();
    _currentScore = widget.initialScore;
    _roundStartScore = widget.initialScore;
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      ringSizeMm = prefs.getDouble('ring_size_mm') ?? 63.0;
      ringLargeMm = prefs.getDouble('ring_large_mm') ?? 83.0;
      _baseVisibleDiameter = visibleDiameterMm;
    });
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
    if (_throwsMm.length >= 3 || _isBust || _currentScore == 0) return;

    final double centerX = constraints.maxWidth / 2;
    final double centerY = constraints.maxHeight / 2;
    final Offset localPos = details.localPosition;
    final Offset relativePx = Offset(
      localPos.dx - centerX - _boardOffset.dx,
      localPos.dy - centerY - _boardOffset.dy,
    );
    double scale = visibleDiameterMm / boardSizePx;
    Offset posMm = relativePx * scale;

    final realResult = DartsScoreEngine.calculate(posMm);
    String label = realResult['label'];
    int hitScore = realResult['score'];
    int multiplier = realResult['multiplier'];

    setState(() {
      final newThrow = ThrowData(posMm, hitScore, label);
      _throwsData.add(newThrow);
      _throwsMm.add(posMm);
      _throwScores.add(hitScore);

      int tempScore = _currentScore - hitScore;
      bool bust = false;

      if (tempScore < 0) {
        bust = true;
      } else if (tempScore == 0) {
        if (widget.isMasterOut) {
          bool isBull = label.contains('BULL');
          if (multiplier < 2 && !isBull) bust = true;
        }
      } else if (tempScore == 1 && widget.isMasterOut) {
        bust = true;
      }

      if (bust) {
        _isBust = true;
        _lastHitLabel = "BUST!";
        _currentScore = _roundStartScore;
      } else if (tempScore == 0) {
        _currentScore = 0;
        _lastHitLabel = "FINISH!";
      } else {
        _currentScore = tempScore;
        _lastHitLabel = label;
      }
    });
  }

  void _undo() {
    if (_throwsData.isEmpty) return;
    setState(() {
      if (_isBust) {
        _isBust = false;
        _currentScore = _roundStartScore;
        for (int i = 0; i < _throwScores.length - 1; i++) {
          _currentScore -= _throwScores[i];
        }
        final removed = _throwsData.removeLast();
        _throwsMm.removeLast();
        _throwScores.removeLast();
      } else {
        final removed = _throwsData.removeLast();
        _throwsMm.removeLast();
        _throwScores.removeLast();
        _currentScore += removed.score;
      }
      if (_throwsData.isNotEmpty) {
        _lastHitLabel = _throwsData.last.label;
      } else {
        _lastHitLabel = "";
      }
    });
  }

  void _nextRound() {
    _gameHistoryData.addAll(_throwsData);
    bool isFinish = _currentScore == 0;

    setState(() {
      if (!isFinish && _roundCount < maxRounds) {
        _roundCount++;
        _throwsData.clear();
        _throwsMm.clear();
        _throwScores.clear();
        _lastHitLabel = "";
        _isBust = false;
        _roundStartScore = _currentScore;
      } else {
        _finishGame();
      }
    });
  }

  void _finishGame() {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => ResultPage(
              gameHistoryMm: _gameHistoryData.map((e) => e.positionMm).toList(),
              totalScore: widget.initialScore - _currentScore,
              visibleDiameterMm: visibleDiameterMm,
              ringSizeMm: ringSizeMm,
              ringLargeMm: ringLargeMm,
              gameMode: widget.initialScore,
            ),
          ),
        )
        .then((_) {
          _saveGameResult();
          Navigator.of(context).pop();
        });
  }

  Future<void> _saveGameResult() async {
    final gameId = await database
        .into(database.games)
        .insert(
          GamesCompanion.insert(
            date: DateTime.now(),
            score: widget.initialScore - _currentScore,
            meanX: 0,
            meanY: 0,
            sdX: 0,
            sdY: 0,
            ringSizeMm: ringSizeMm,
            ringLargeMm: ringLargeMm,
            gameType: drift.Value(widget.initialScore),
            isMasterOut: drift.Value(widget.isMasterOut),
          ),
        );

    await database.batch((batch) {
      for (int i = 0; i < _gameHistoryData.length; i++) {
        final p = _gameHistoryData[i];
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text("${widget.initialScore} Game"),
        backgroundColor: Colors.black.withValues(alpha: 0.8),
        elevation: 0,
        actions: const [],
      ),
      body: SafeArea(
        child: Stack(
          children: [
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
                      onScaleStart: (details) =>
                          _baseVisibleDiameter = visibleDiameterMm,
                      onScaleUpdate: (details) {
                        if (details.scale != 1.0) {
                          _handleZoomUpdate(details.scale);
                        }
                        setState(() => _boardOffset += details.focalPointDelta);
                      },
                      onLongPress: () {
                        setState(() => _isUiVisible = !_isUiVisible);
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
                              child: CustomPaint(
                                size: Size(availableSize, availableSize),
                                painter: BoardPainter(
                                  throwsMm: _throwsMm,
                                  visibleDiameterMm: visibleDiameterMm,
                                  ringSizeMm: ringSizeMm,
                                  ringLargeMm: ringLargeMm,
                                  // ★修正: 01ではリングを表示しない
                                  showPracticeRings: false,
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
                              shadows: [
                                Shadow(blurRadius: 4, color: Colors.black),
                              ],
                            ),
                          ),
                          // 残りスコア
                          Text(
                            "$_currentScore",
                            style: TextStyle(
                              fontSize: 60,
                              fontWeight: FontWeight.w900,
                              color: _isBust ? Colors.red : Colors.white,
                              shadows: const [
                                Shadow(blurRadius: 4, color: Colors.black),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _lastHitLabel.isEmpty ? "Start" : _lastHitLabel,
                        style: const TextStyle(
                          fontSize: 32,
                          color: Colors.cyanAccent,
                          fontWeight: FontWeight.bold,
                          shadows: [Shadow(blurRadius: 4, color: Colors.black)],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(3, (index) {
                          String txt = index < _throwScores.length
                              ? "${_throwScores[index]}"
                              : "-";
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.5),
                                border: Border.all(
                                  color: Colors.white30,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                txt,
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

            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Row(
                children: [
                  if (_throwsData.isNotEmpty)
                    SizedBox(
                      width: 60,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _undo,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[800],
                          padding: EdgeInsets.zero,
                        ),
                        child: const Icon(Icons.undo, color: Colors.white),
                      ),
                    ),
                  if (_throwsMm.length == 3 ||
                      _isBust ||
                      _currentScore == 0) ...[
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
                          ),
                          child: const Text(
                            "NEXT ROUND",
                            style: TextStyle(
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
