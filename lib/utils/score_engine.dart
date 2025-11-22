import 'dart:math';
import 'package:flutter/material.dart';

class DartsScoreEngine {
  // ダーツボードの配列 (12時から時計回り)
  static const List<int> segments = [
    20, 1, 18, 4, 13, 6, 10, 15, 2, 17, 3, 19, 7, 16, 8, 11, 14, 9, 12, 5
  ];

  // 判定メソッド
  // 引数: 中心を(0,0)としたmm単位の座標
  static Map<String, dynamic> calculate(Offset posMm) {
    double r = posMm.distance;
    
    // 1. ブル判定 (距離のみ)
    // 一般的なソフトダーツのサイズ
    if (r <= 8.0) return {'score': 50, 'label': 'D-BULL', 'multiplier': 2}; // Inner (50)
    if (r <= 22.0) return {'score': 50, 'label': 'S-BULL', 'multiplier': 1}; // Outer (50)

    // 2. アウト判定 (ダブルリングの外側)
    // ダブルの外径は170mm
    if (r > 170.0) return {'score': 0, 'label': 'OUT', 'multiplier': 0};

    // 3. 角度計算 (atan2を使用)
    // Flutterの座標系: 右が+x, 下が+y
    // atan2(y, x) は 3時方向が0度, 時計回りにプラス, 反時計回りにマイナス(-pi ~ pi)
    
    double theta = atan2(posMm.dy, posMm.dx); // ラジアン (-pi ~ pi)
    double degrees = theta * (180 / pi); // 度数法 (-180 ~ 180)

    // 座標系の調整:
    // ダーツの「20」は12時方向(-90度)。これを配列のindex 0に合わせるための補正。
    // atan2の0度(3時)から、時計回りに90度回すと6時。さらに回して...と考えず、
    // シンプルに「真上が0度になるように」90度足して調整します。
    
    degrees += 90; 
    
    // 負の値を正の範囲(0~360)に直す
    if (degrees < 0) degrees += 360;
    
    // セグメントの回転調整
    // 20のエリアは「真上を中心に±9度 (351度〜9度)」。
    // 計算しやすいように、9度足して「0〜18度がセグメント0(20)」となるようにシフトします。
    degrees += 9;
    if (degrees >= 360) degrees -= 360;

    // インデックス決定 (0 ~ 19)
    int index = (degrees / 18).floor();
    // 安全装置 (計算誤差対策)
    if (index < 0) index = 0;
    if (index >= 20) index = 19;

    int baseScore = segments[index];

    // 4. エリア判定 (Multipliers)
    // Double: 162mm ~ 170mm
    // Triple: 99mm ~ 107mm
    String label = "S$baseScore";
    int score = baseScore;
    int multiplier = 1;

    if (r >= 162.0 && r <= 170.0) {
      label = "D$baseScore";
      score *= 2;
      multiplier = 2;
    } else if (r >= 99.0 && r <= 107.0) {
      label = "T$baseScore";
      score *= 3;
      multiplier = 3;
    }

    return {
      'score': score,
      'label': label, // 表示用 (例: T20)
      'multiplier': multiplier,
    };
  }
}