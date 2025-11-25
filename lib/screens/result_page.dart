import 'dart:math';
import 'package:flutter/material.dart';
import '../painters/board_painter.dart';
import '../utils/score_engine.dart';
import 'package:flutter/foundation.dart'; // kIsWeb用

class ResultPage extends StatefulWidget {
  final List<Offset> gameHistoryMm;
  final int totalScore;
  final double visibleDiameterMm;
  final double ringSizeMm;
  final double ringLargeMm;
  final int gameMode;

  const ResultPage({
    super.key,
    required this.gameHistoryMm,
    required this.totalScore,
    required this.visibleDiameterMm,
    required this.ringSizeMm,
    required this.ringLargeMm,
    required this.gameMode,
  });

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  // シートのサイズ設定
  static const double _sheetMinSize = 0.15;
  static const double _sheetMaxSize = 0.8;
  static const double _sheetInitialSize = 0.15;

  final DraggableScrollableController _sheetController =
      DraggableScrollableController();
  final ScrollController _webScrollController = ScrollController();

  bool _isWebSheetOpen = false;

  void _toggleSheet() {
    if (kIsWeb) {
      setState(() {
        _isWebSheetOpen = !_isWebSheetOpen;
      });
    } else {
      double currentSize = _sheetController.size;
      if (currentSize < 0.5) {
        _sheetController.animateTo(
          _sheetMaxSize,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } else {
        _sheetController.animateTo(
          _sheetMinSize,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
      }
    }
  }

  @override
  void dispose() {
    _sheetController.dispose();
    _webScrollController.dispose();
    super.dispose();
  }

  Widget _buildSheetContent(
    BuildContext context,
    ScrollController scrollController,
  ) {
    // 統計計算ロジック
    List<Offset> history = widget.gameHistoryMm;
    double meanX = 0, meanY = 0;
    double sdX = 0, sdY = 0;
    double cepMm = 0;
    double meanDistMm = 0;
    Offset? centroidMm;
    int sBullCount = 0,
        dBullCount = 0,
        tripleCount = 0,
        doubleCount = 0,
        singleCount = 0,
        outCount = 0;

    if (history.isNotEmpty) {
      double sumX = 0, sumY = 0;
      double maxDistMm = 0;
      double sumSqDiffX = 0, sumSqDiffY = 0;
      double sumDist = 0;

      for (var p in history) {
        sumX += p.dx;
        sumY += p.dy;
        double d = p.distance;
        sumDist += d;
        if (d > maxDistMm) maxDistMm = d;

        final result = DartsScoreEngine.calculate(p);
        final label = result['label'] as String;

        if (label == 'S-BULL')
          sBullCount++;
        else if (label == 'D-BULL')
          dBullCount++;
        else if (label.startsWith('T'))
          tripleCount++;
        else if (label.startsWith('D'))
          doubleCount++;
        else if (label == 'OUT')
          outCount++;
        else
          singleCount++;
      }
      meanX = sumX / history.length;
      meanY = sumY / history.length;
      meanDistMm = sumDist / history.length;
      centroidMm = Offset(meanX, meanY);

      for (var p in history) {
        sumSqDiffX += pow(p.dx - meanX, 2);
        sumSqDiffY += pow(p.dy - meanY, 2);
      }
      sdX = sqrt(sumSqDiffX / history.length);
      sdY = sqrt(sumSqDiffY / history.length);

      List<double> distances = history
          .map((p) => (p - centroidMm!).distance)
          .toList();
      distances.sort();
      cepMm = distances[(distances.length / 2).floor()];
    }

    int totalBulls = sBullCount + dBullCount;
    double bullRate = history.isNotEmpty
        ? (totalBulls / history.length * 100)
        : 0.0;
    double ppd = history.isNotEmpty ? widget.totalScore / history.length : 0.0;
    double ppr = ppd * 3;

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900]!.withValues(alpha: 0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: kIsWeb
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 10,
                  spreadRadius: 5,
                ),
              ],
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.1), width: 1),
        ),
      ),
      child: Column(
        children: [
          // 固定ヘッダーエリア (ドラッグ & タップ対応)
          GestureDetector(
            onTap: _toggleSheet,
            behavior: HitTestBehavior.opaque,

            // ▼▼▼ 追加: ドラッグ操作の検知 (アプリ版のみ) ▼▼▼
            onVerticalDragUpdate: kIsWeb
                ? null
                : (details) {
                    // 画面全体の高さに対する移動量の割合を計算
                    double delta =
                        details.primaryDelta! /
                        MediaQuery.of(context).size.height;
                    // ドラッグ方向は逆 (下にドラッグするとサイズは減る)
                    double newSize = _sheetController.size - delta;
                    // 範囲内に収めて適用
                    _sheetController.jumpTo(
                      newSize.clamp(_sheetMinSize, _sheetMaxSize),
                    );
                  },

            onVerticalDragEnd: kIsWeb
                ? null
                : (details) {
                    // 指を離した瞬間の縦方向の速度 (ピクセル/秒)
                    double velocity = details.primaryVelocity ?? 0;
                    double currentSize = _sheetController.size;

                    // 勢い判定のしきい値 (この速度以上ならフリックとみなす)
                    const double flingThreshold = 700.0;

                    if (velocity < -flingThreshold) {
                      // 上向きに勢いよくスワイプ -> 最大まで開く
                      _sheetController.animateTo(
                        _sheetMaxSize,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                      );
                    } else if (velocity > flingThreshold) {
                      // 下向きに勢いよくスワイプ -> 最小まで閉じる
                      _sheetController.animateTo(
                        _sheetMinSize,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                      );
                    } else {
                      // 勢いがない場合: 画面の半分より上なら全開、下なら全閉に吸着させる
                      // (中途半端な位置で止まらないようにする親切設計)
                      if (currentSize > (_sheetMaxSize + _sheetMinSize) / 2) {
                        _sheetController.animateTo(
                          _sheetMaxSize,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        );
                      } else {
                        _sheetController.animateTo(
                          _sheetMinSize,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        );
                      }
                    }
                  },
            // ▲▲▲ 追加ここまで ▲▲▲
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey[600],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "TOTAL SCORE",
                        style: TextStyle(
                          color: Colors.grey[400],
                          letterSpacing: 2.0,
                        ),
                      ),
                      Text(
                        "${widget.totalScore}",
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          height: 1.0,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // スクロールエリア
          Expanded(
            child: SingleChildScrollView(
              controller: scrollController,
              physics: const AlwaysScrollableScrollPhysics(), // 常にスクロール挙動を有効化
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  if (widget.gameMode == 1) ...[
                    Row(
                      children: [
                        Expanded(
                          child: _buildMainStatBox(
                            "PPR",
                            ppr.toStringAsFixed(1),
                            "Points Per Round",
                            Colors.cyanAccent,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildMainStatBox(
                            "PPD",
                            ppd.toStringAsFixed(1),
                            "Points Per Dart",
                            Colors.blueAccent,
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    Row(
                      children: [
                        Expanded(
                          child: _buildMainStatBox(
                            "Avg Dist",
                            "${meanDistMm.toStringAsFixed(1)} mm",
                            "Mean Distance",
                            Colors.orangeAccent,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildMainStatBox(
                            "CEP",
                            "${cepMm.toStringAsFixed(1)} mm",
                            "50% Radius",
                            Colors.greenAccent,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 20),
                  const Text(
                    "Bull Stats",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: _buildStatCard(
                          "Bull Rate",
                          "${bullRate.toStringAsFixed(1)}%",
                          "$totalBulls / ${history.length} hits",
                          Colors.amberAccent,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildStatCard(
                          "S-Bull",
                          "$sBullCount",
                          "50 pts",
                          Colors.white,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildStatCard(
                          "D-Bull",
                          "$dBullCount",
                          "50 pts",
                          Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Distribution",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMiniStat("Triple", "$tripleCount", Colors.orange),
                      _buildMiniStat("Double", "$doubleCount", Colors.red),
                      _buildMiniStat("Single", "$singleCount", Colors.white),
                      _buildMiniStat("Out", "$outCount", Colors.grey),
                    ],
                  ),
                  const Divider(color: Colors.white24, height: 30),
                  if (history.isNotEmpty)
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            "Horizontal SD",
                            sdX,
                            "X-Axis (mm)",
                            Colors.blueGrey,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildStatCard(
                            "Vertical SD",
                            sdY,
                            "Y-Axis (mm)",
                            Colors.blueGrey,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 20),
                  if (centroidMm != null)
                    Text(
                      "Centroid Bias: Right ${meanX.toStringAsFixed(1)}mm, Down ${meanY.toStringAsFixed(1)}mm",
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ... (ヘルパーメソッド _buildMainStatBox などはそのまま) ...
  Widget _buildMainStatBox(
    String title,
    String value,
    String sub,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          Text(
            sub,
            style: TextStyle(fontSize: 10, color: color.withValues(alpha: 0.8)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    dynamic val,
    String subtitle,
    Color accentColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
          const SizedBox(height: 4),
          Text(
            val is String ? val : val.toStringAsFixed(1),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: accentColor,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: accentColor.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[400])),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    double autoFitDiameter = 400.0;
    List<Offset> history = widget.gameHistoryMm;
    Offset? centroidMm;
    double cepMm = 0;

    if (history.isNotEmpty) {
      double maxDistMm = 0;
      double sumX = 0, sumY = 0;
      for (var p in history) {
        double d = p.distance;
        if (d > maxDistMm) maxDistMm = d;
        sumX += p.dx;
        sumY += p.dy;
      }
      double meanX = sumX / history.length;
      double meanY = sumY / history.length;
      centroidMm = Offset(meanX, meanY);

      List<double> distances = history
          .map((p) => (p - centroidMm!).distance)
          .toList();
      distances.sort();
      cepMm = distances[(distances.length / 2).floor()];

      double targetDiameter = maxDistMm * 2 * 1.2;
      double minDiameter = max(60.0, widget.ringSizeMm * 1.2);
      autoFitDiameter = max(targetDiameter, minDiameter);
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Game Result'),
        backgroundColor: Colors.black.withValues(alpha: 0.5),
        elevation: 0,
      ),
      body: Stack(
        children: [
          // --- Layer 1: ダーツボード ---
          Positioned.fill(
            child: Container(
              color: Colors.black,
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height * _sheetInitialSize,
              ),
              child: InteractiveViewer(
                minScale: 0.1,
                maxScale: 5.0,
                boundaryMargin: const EdgeInsets.all(double.infinity),
                child: Center(
                  child: CustomPaint(
                    size: Size(
                      min(
                        MediaQuery.of(context).size.width,
                        MediaQuery.of(context).size.height,
                      ),
                      min(
                        MediaQuery.of(context).size.width,
                        MediaQuery.of(context).size.height,
                      ),
                    ),
                    painter: BoardPainter(
                      throwsMm: widget.gameHistoryMm,
                      visibleDiameterMm: autoFitDiameter,
                      ringSizeMm: widget.ringSizeMm,
                      ringLargeMm: widget.ringLargeMm,
                      showPracticeRings: widget.gameMode == 0,
                      cepMm: cepMm > 0 ? cepMm : null,
                      centroidMm: centroidMm,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // --- Layer 2: 詳細パネル (Web/App分岐) ---
          if (kIsWeb)
            Align(
              alignment: Alignment.bottomCenter,
              child: AnimatedFractionallySizedBox(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                widthFactor: 1.0,
                heightFactor: _isWebSheetOpen
                    ? _sheetMaxSize
                    : _sheetInitialSize,
                child: _buildSheetContent(context, _webScrollController),
              ),
            )
          else
            DraggableScrollableSheet(
              controller: _sheetController,
              initialChildSize: _sheetInitialSize,
              minChildSize: _sheetMinSize,
              maxChildSize: _sheetMaxSize,
              builder: (context, scrollController) {
                return _buildSheetContent(context, scrollController);
              },
            ),
        ],
      ),
    );
  }
}
