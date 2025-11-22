import 'dart:math';
import 'package:flutter/material.dart';
import '../painters/board_painter.dart';

class ResultPage extends StatelessWidget {
  final List<Offset> gameHistoryMm;
  final int totalScore;
  final double visibleDiameterMm;
  final double ringSizeMm;
  final double ringLargeMm;

  const ResultPage({
    super.key,
    required this.gameHistoryMm,
    required this.totalScore,
    required this.visibleDiameterMm,
    required this.ringSizeMm,
    required this.ringLargeMm,
  });

  @override
  Widget build(BuildContext context) {
    double meanX = 0, meanY = 0;
    double sdX = 0, sdY = 0;
    double cepMm = 0;
    Offset? centroidMm;

    if (gameHistoryMm.isNotEmpty) {
      double sumX = 0, sumY = 0;
      for (var p in gameHistoryMm) { sumX += p.dx; sumY += p.dy; }
      meanX = sumX / gameHistoryMm.length;
      meanY = sumY / gameHistoryMm.length;
      centroidMm = Offset(meanX, meanY);

      List<double> distances = gameHistoryMm.map((p) => (p - centroidMm!).distance).toList();
      distances.sort();
      cepMm = distances[(distances.length / 2).floor()];

      double sumSqDiffX = 0, sumSqDiffY = 0;
      for (var p in gameHistoryMm) {
        sumSqDiffX += pow(p.dx - meanX, 2);
        sumSqDiffY += pow(p.dy - meanY, 2);
      }
      sdX = sqrt(sumSqDiffX / gameHistoryMm.length);
      sdY = sqrt(sumSqDiffY / gameHistoryMm.length);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Game Result')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text("TOTAL SCORE", style: TextStyle(color: Colors.grey[400], letterSpacing: 2.0)),
            Text("$totalScore", style: const TextStyle(fontSize: 60, fontWeight: FontWeight.w900, height: 1.0)),
            const SizedBox(height: 30),
            
            if (gameHistoryMm.isEmpty)
              const Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Text("(No plot data available)", style: TextStyle(color: Colors.grey)),
              ),

            LayoutBuilder(
              builder: (context, constraints) {
                double size = min(constraints.maxWidth, 300);
                return CustomPaint(
                  size: Size(size, size),
                  painter: BoardPainter(
                    throwsMm: gameHistoryMm,
                    visibleDiameterMm: visibleDiameterMm,
                    ringSizeMm: ringSizeMm,
                    ringLargeMm: ringLargeMm,
                    cepMm: cepMm > 0 ? cepMm : null,
                    centroidMm: centroidMm,
                  ),
                );
              },
            ),
            
            const SizedBox(height: 30),

            if (gameHistoryMm.isNotEmpty) ...[
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.greenAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.greenAccent.withOpacity(0.5)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.adjust, color: Colors.greenAccent, size: 30),
                    const SizedBox(width: 15),
                    Column(
                      children: [
                        const Text("CEP (半数必中界)", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.greenAccent)),
                        Text(
                          "${cepMm.toStringAsFixed(1)} mm", 
                          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white)
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(child: _buildStatCard("横ブレ (X)", sdX, "左右SD(mm)")),
                    const SizedBox(width: 10),
                    Expanded(child: _buildStatCard("縦ブレ (Y)", sdY, "上下SD(mm)")),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text("重心: 右へ${meanX.toStringAsFixed(1)}mm, 下へ${meanY.toStringAsFixed(1)}mm", style: const TextStyle(color: Colors.grey)),
            ],

            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("BACK TO HOME"),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatCard(String title, double sdVal, String hint) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white24)),
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text(sdVal.toStringAsFixed(1), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
          const SizedBox(height: 5),
          Text(hint, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }
}