import 'package:flutter/material.dart';
import 'database.dart';
import 'screens/main_menu_page.dart'; // ★変更: 新しいメニュー画面をインポート

void main() {
  // データベースの初期化
  database = AppDatabase();
  
  runApp(const DartsAnalyzerApp());
}

class DartsAnalyzerApp extends StatelessWidget {
  const DartsAnalyzerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bull Master',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
      ),
      // ★変更: ホーム画面をメニュー画面に設定
      home: const GameSelectionPage(), 
    );
  }
}

// ※元の main.dart から PrecisionInputPage クラスの定義は削除済みである前提です。