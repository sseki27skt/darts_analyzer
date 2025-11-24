import 'dart:math';
import 'package:flutter/material.dart';
import '../painters/board_painter.dart';
import '../utils/score_engine.dart';

class ResultPage extends StatelessWidget {
  final List<Offset> gameHistoryMm;
  final int totalScore;
  final double visibleDiameterMm;
  final double ringSizeMm;
  final double ringLargeMm;
  // ★追加: ゲームモードを受け取る
  final int gameMode; // 0: Center, 1: Real

  const ResultPage({
    super.key,
    required this.gameHistoryMm,
    required this.totalScore,
    required this.visibleDiameterMm,
    required this.ringSizeMm,
    required this.ringLargeMm,
    // ★追加
    required this.gameMode,
  });

  @override
  Widget build(BuildContext context) {
    // --- 統計・座標計算 ---
    double meanX = 0, meanY = 0;
    double sdX = 0, sdY = 0;
    double cepMm = 0;
    double meanDistMm = 0; // ★追加: 平均距離
    Offset? centroidMm;
    double autoFitDiameter = 400.0;

    // スタッツ用
    int sBullCount = 0;
    int dBullCount = 0;
    int tripleCount = 0;
    int doubleCount = 0;
    int singleCount = 0;
    int outCount = 0;

    if (gameHistoryMm.isNotEmpty) {
      double sumX = 0, sumY = 0;
      double maxDistMm = 0;
      double sumSqDiffX = 0, sumSqDiffY = 0;
      double sumDist = 0; // ★追加

      for (var p in gameHistoryMm) {
        sumX += p.dx;
        sumY += p.dy;
        double d = p.distance;
        sumDist += d; // ★追加
        if (d > maxDistMm) maxDistMm = d;

        final result = DartsScoreEngine.calculate(p);
        final label = result['label'] as String;
        
        if (label == 'S-BULL') {
          sBullCount++;
        } else if (label == 'D-BULL') dBullCount++;
        else if (label.startsWith('T')) tripleCount++;
        else if (label.startsWith('D')) doubleCount++;
        else if (label == 'OUT') outCount++;
        else singleCount++;
      }

      meanX = sumX / gameHistoryMm.length;
      meanY = sumY / gameHistoryMm.length;
      meanDistMm = sumDist / gameHistoryMm.length; // ★計算
      centroidMm = Offset(meanX, meanY);

      for (var p in gameHistoryMm) {
        sumSqDiffX += pow(p.dx - meanX, 2);
        sumSqDiffY += pow(p.dy - meanY, 2);
      }
      sdX = sqrt(sumSqDiffX / gameHistoryMm.length);
      sdY = sqrt(sumSqDiffY / gameHistoryMm.length);

      List<double> distances = gameHistoryMm.map((p) => (p - centroidMm!).distance).toList();
      distances.sort();
      cepMm = distances[(distances.length / 2).floor()];

      double targetDiameter = maxDistMm * 2 * 1.2;
      double minDiameter = max(60.0, ringSizeMm * 1.2);
      autoFitDiameter = max(targetDiameter, minDiameter);
    }

    int totalBulls = sBullCount + dBullCount;
    double bullRate = gameHistoryMm.isNotEmpty 
        ? (totalBulls / gameHistoryMm.length * 100) 
        : 0.0;
    
    // ★追加: PPR / PPD 計算
    // 1ラウンド=3投として換算 (ダーツ本数が3の倍数でない場合も考慮して平均化)
    double ppd = gameHistoryMm.isNotEmpty ? totalScore / gameHistoryMm.length : 0.0;
    double ppr = ppd * 3;

    final double sheetMinSize = 0.15;
    final double sheetInitialSize = 0.15;

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
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * sheetInitialSize),
              child: InteractiveViewer(
                minScale: 0.1,
                maxScale: 5.0,
                boundaryMargin: const EdgeInsets.all(double.infinity),
                child: Center(
                  child: CustomPaint(
                    size: Size(
                      min(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height),
                      min(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height),
                    ),
                    painter: BoardPainter(
                      throwsMm: gameHistoryMm,
                      visibleDiameterMm: autoFitDiameter,
                      ringSizeMm: ringSizeMm,
                      ringLargeMm: ringLargeMm,
                      showPracticeRings: gameMode == 0,
                      cepMm: cepMm > 0 ? cepMm : null,
                      centroidMm: centroidMm,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // --- Layer 2: 詳細パネル ---
          DraggableScrollableSheet(
            initialChildSize: sheetInitialSize,
            minChildSize: sheetMinSize,
            maxChildSize: 0.8,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.grey[900]!.withValues(alpha: 0.95),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 10, spreadRadius: 5),
                  ],
                  border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.1), width: 1)),
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40, height: 4,
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: Colors.grey[600],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("TOTAL SCORE", style: TextStyle(color: Colors.grey[400], letterSpacing: 2.0)),
                          Text("$totalScore", style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900, height: 1.0)),
                        ],
                      ),
                      
                      const SizedBox(height: 30),

                      // ★修正: モードに応じてメイン表示を切り替え
                      if (gameMode == 1) ...[
                        // --- Real Count-Up: スタッツ (PPR/PPD) ---
                        Row(
                          children: [
                            Expanded(
                              child: _buildMainStatBox("PPR", ppr.toStringAsFixed(1), "Points Per Round", Colors.cyanAccent),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildMainStatBox("PPD", ppd.toStringAsFixed(1), "Points Per Dart", Colors.blueAccent),
                            ),
                          ],
                        ),
                      ] else ...[
                        // --- Center Count-Up: グルーピング (平均距離/CEP) ---
                         Row(
                          children: [
                            Expanded(
                              child: _buildMainStatBox("Avg Dist", "${meanDistMm.toStringAsFixed(1)} mm", "Mean Distance", Colors.orangeAccent),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildMainStatBox("CEP", "${cepMm.toStringAsFixed(1)} mm", "50% Radius", Colors.greenAccent),
                            ),
                          ],
                        ),
                      ],

                      const SizedBox(height: 20),

                      // --- Bull Stats (共通) ---
                      const Text("Bull Stats", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: _buildStatCard("Bull Rate", "${bullRate.toStringAsFixed(1)}%", "$totalBulls / ${gameHistoryMm.length} hits", Colors.amberAccent),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildStatCard("S-Bull", "$sBullCount", "50 pts", Colors.white), // 50ptsに修正
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildStatCard("D-Bull", "$dBullCount", "50 pts", Colors.redAccent),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // --- Distribution (共通) ---
                      const Text("Distribution", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
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

                      // SD表示 (共通)
                      if (gameHistoryMm.isNotEmpty)
                        Row(
                          children: [
                            Expanded(child: _buildStatCard("Horizontal SD", sdX, "X-Axis (mm)", Colors.blueGrey)),
                            const SizedBox(width: 10),
                            Expanded(child: _buildStatCard("Vertical SD", sdY, "Y-Axis (mm)", Colors.blueGrey)),
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
              );
            },
          ),
        ],
      ),
    );
  }

  // メインスタッツ用の大きなボックス
  Widget _buildMainStatBox(String title, String value, String sub, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
      ),
      child: Column(
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white)),
          Text(sub, style: TextStyle(fontSize: 10, color: color.withValues(alpha: 0.8))),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, dynamic val, String subtitle, Color accentColor) {
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
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: accentColor),
          ),
          Text(subtitle, style: TextStyle(fontSize: 10, color: accentColor.withValues(alpha: 0.7))),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[400])),
      ],
    );
  }
}