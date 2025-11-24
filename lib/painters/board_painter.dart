import 'dart:math';
import 'package:flutter/material.dart';

class BoardPainter extends CustomPainter {
  final List<Offset> throwsMm;
  final double visibleDiameterMm;
  final double ringSizeMm;
  final double ringLargeMm;
  // ★削除: final double ringHalfTripleMm;
  
  final double? cepMm; 
  final Offset? centroidMm; 

  BoardPainter({
    required this.throwsMm,
    required this.visibleDiameterMm,
    required this.ringSizeMm,
    required this.ringLargeMm,
    // ★削除: this.ringHalfTripleMm = 107.0, 
    this.cepMm,
    this.centroidMm,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final double scalePxPerMm = size.width / visibleDiameterMm;

    const double rDoubleOut = 170.0;
    const double rDoubleIn = 162.0;
    const double rTripleOut = 107.0;
    const double rTripleIn = 99.0;
    const double rBullOut = 22.0;
    const double rBullIn = 8.0;

    final Paint segmentPaint = Paint()..style = PaintingStyle.stroke..strokeCap = StrokeCap.butt;

    // 背景
    canvas.drawCircle(center, (rDoubleOut + 20) * scalePxPerMm, Paint()..color = const Color(0xFF101010));

    const double segmentAngle = 2 * pi / 20;
    const double startOffset = -pi / 2 - (segmentAngle / 2);

    for (int i = 0; i < 20; i++) {
      final double angle = startOffset + (i * segmentAngle);
      final bool isSetA = i % 2 == 0;
      final Color colorSingle = isSetA ? const Color(0xFF252525) : const Color(0xFF505050); 
      final Color colorRing = isSetA ? const Color(0xFF661010) : const Color(0xFF102040);

      void drawSegmentWithBits(double rOut, double rIn, Color color) {
        segmentPaint.color = color;
        segmentPaint.strokeWidth = (rOut - rIn) * scalePxPerMm;
        double rMid = (rOut + rIn) / 2;
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: rMid * scalePxPerMm),
          angle, segmentAngle, false, segmentPaint,
        );
        _drawBits(canvas, center, angle, segmentAngle, rIn * scalePxPerMm, rOut * scalePxPerMm, color);
      }

      drawSegmentWithBits(rDoubleOut, rDoubleIn, colorRing);
      drawSegmentWithBits(rDoubleIn, rTripleOut, colorSingle);
      drawSegmentWithBits(rTripleOut, rTripleIn, colorRing);
      drawSegmentWithBits(rTripleIn, rBullOut, colorSingle);
    }

    // スパイダー
    final Paint spiderPaint = Paint()..color = Colors.white12..style = PaintingStyle.stroke..strokeWidth = 0.5;
    for (int i = 0; i < 20; i++) {
      double angle = startOffset + (i * segmentAngle);
      Offset start = center + Offset(cos(angle) * rBullOut * scalePxPerMm, sin(angle) * rBullOut * scalePxPerMm);
      Offset end = center + Offset(cos(angle) * rDoubleOut * scalePxPerMm, sin(angle) * rDoubleOut * scalePxPerMm);
      canvas.drawLine(start, end, spiderPaint);
    }
    canvas.drawCircle(center, rDoubleOut * scalePxPerMm, spiderPaint);
    canvas.drawCircle(center, rDoubleIn * scalePxPerMm, spiderPaint);
    canvas.drawCircle(center, rTripleOut * scalePxPerMm, spiderPaint);
    canvas.drawCircle(center, rTripleIn * scalePxPerMm, spiderPaint);

    final Paint ringPaint = Paint()..style = PaintingStyle.stroke;

    // Ring Large
    ringPaint.color = const Color.fromRGBO(255, 115, 0, 0.3); 
    ringPaint.strokeWidth = 1.0;
    canvas.drawCircle(center, (ringLargeMm / 2) * scalePxPerMm, ringPaint);
    
    // ★削除: Half-Triple Ring (水色の環) の描画を削除

    // Ring Small
    ringPaint.color = const Color.fromRGBO(255, 115, 0, 0.8); 
    ringPaint.strokeWidth = 1.5;
    canvas.drawCircle(center, (ringSizeMm / 2) * scalePxPerMm, ringPaint);

    // ブルエリア
    final Paint fillPaint = Paint()..style = PaintingStyle.fill;
    fillPaint.color = const Color(0xFF661010);
    canvas.drawCircle(center, rBullOut * scalePxPerMm, fillPaint);
    _drawBitsCircle(canvas, center, rBullIn * scalePxPerMm, rBullOut * scalePxPerMm, const Color(0xFF661010));
    fillPaint.color = Colors.black;
    canvas.drawCircle(center, rBullIn * scalePxPerMm, fillPaint);
    _drawBitsCircle(canvas, center, 0, rBullIn * scalePxPerMm, Colors.black);
    spiderPaint.color = Colors.grey[800]!;
    canvas.drawCircle(center, rBullOut * scalePxPerMm, spiderPaint);
    canvas.drawCircle(center, rBullIn * scalePxPerMm, spiderPaint);

    if (cepMm != null && centroidMm != null) {
      Offset cPos = center + (centroidMm! * scalePxPerMm);
      final Paint cepPaint = Paint()..style = PaintingStyle.fill..color = Colors.greenAccent.withOpacity(0.2);
      canvas.drawCircle(cPos, cepMm! * scalePxPerMm, cepPaint);
      cepPaint..style = PaintingStyle.stroke..color = Colors.greenAccent..strokeWidth = 1.5;
      canvas.drawCircle(cPos, cepMm! * scalePxPerMm, cepPaint);
      final Paint centroidPaint = Paint()..color = Colors.cyanAccent..strokeWidth = 2.0;
      double crossSize = 6.0;
      canvas.drawLine(cPos - Offset(crossSize, 0), cPos + Offset(crossSize, 0), centroidPaint);
      canvas.drawLine(cPos - Offset(0, crossSize), cPos + Offset(0, crossSize), centroidPaint);
    }

    final pointFill = Paint()..color = Colors.amberAccent; 
    final pointStroke = Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = 1.0;
    for (var posMm in throwsMm) {
      Offset drawPos = center + (posMm * scalePxPerMm);
      canvas.drawCircle(drawPos, 4, pointFill);
      canvas.drawCircle(drawPos, 4, pointStroke);
    }
  }
  
  void _drawBits(Canvas canvas, Offset center, double startAngle, double sweepAngle, double rInnerPx, double rOuterPx, Color baseColor) {
     final Color bitColor = Color.lerp(baseColor, Colors.black, 0.4)!.withOpacity(0.5);
    final Paint bitPaint = Paint()..color = bitColor..style = PaintingStyle.fill;
    const double bitRadiusPx = 1.5; 
    const double rStepPx = 5.0;
    const double arcStepPx = 5.0;
    for (double r = rInnerPx + rStepPx / 2; r < rOuterPx; r += rStepPx) {
      double arcLength = r * sweepAngle;
      int numBits = (arcLength / arcStepPx).floor();
      if (numBits == 0) continue;
      double thetaStep = sweepAngle / numBits;
      for (int j = 0; j < numBits; j++) {
        double theta = startAngle + (j + 0.5) * thetaStep;
        Offset bitPos = center + Offset(cos(theta) * r, sin(theta) * r);
        canvas.drawCircle(bitPos, bitRadiusPx, bitPaint);
      }
    }
  }

  void _drawBitsCircle(Canvas canvas, Offset center, double rInnerPx, double rOuterPx, Color baseColor) {
     final Color bitColor = Color.lerp(baseColor, Colors.black, 0.4)!.withOpacity(0.5);
    final Paint bitPaint = Paint()..color = bitColor..style = PaintingStyle.fill;
    const double bitRadiusPx = 1.5;
    const double rStepPx = 5.0;
    const double arcStepPx = 5.0;
    for (double r = rInnerPx + rStepPx / 2; r < rOuterPx; r += rStepPx) {
      double circumference = 2 * pi * r;
      int numBits = (circumference / arcStepPx).floor();
      if (numBits == 0) continue;
      double thetaStep = (2 * pi) / numBits;
      for (int j = 0; j < numBits; j++) {
        double theta = j * thetaStep;
        Offset bitPos = center + Offset(cos(theta) * r, sin(theta) * r);
        canvas.drawCircle(bitPos, bitRadiusPx, bitPaint);
      }
    }
  }
  
  @override
  bool shouldRepaint(covariant BoardPainter oldDelegate) {
    return oldDelegate.throwsMm != throwsMm ||
           oldDelegate.visibleDiameterMm != visibleDiameterMm ||
           oldDelegate.ringSizeMm != ringSizeMm ||
           oldDelegate.ringLargeMm != ringLargeMm ||
           // ★削除: ringHalfTripleMm の比較を削除
           oldDelegate.cepMm != cepMm ||
           oldDelegate.centroidMm != centroidMm;
  }
}