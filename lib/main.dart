import 'package:flutter/material.dart';
import 'database.dart';
import 'screens/main_menu_page.dart'; // ★変更: 新しいメニュー画面をインポート
import 'package:flutter_localizations/flutter_localizations.dart';

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
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.black,
        useMaterial3: true,
        // フォントを明示的に指定する場合（オプション）
        // fontFamily: 'Hiragino Kaku Gothic ProN', // Mac/iOS向け
      ),

      // ▼▼▼ ② ここから追加 ▼▼▼

      // アプリの言語を強制的に日本語に設定
      locale: const Locale('ja', 'JP'),

      // 多言語対応のデリゲート（翻訳機能の本体）
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // サポートする言語リスト
      supportedLocales: const [
        Locale('ja', 'JP'), // 日本語
      ],

      // ▲▲▲ 追加ここまで ▲▲▲
      home: const GameSelectionPage(), // (ここは既存のまま)
    );
  }
}

// ※元の main.dart から PrecisionInputPage クラスの定義は削除済みである前提です。
