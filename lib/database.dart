import 'package:drift/drift.dart';
// ★以下の import を connection.dart に置き換えます
import 'database/connection.dart' as connection; 

part 'database.g.dart';

// ---------------------------------------------------------
// 1. テーブル定義 (そのまま)
// ---------------------------------------------------------
class Games extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime()();
  IntColumn get score => integer()();
  RealColumn get meanX => real()();
  RealColumn get meanY => real()();
  RealColumn get sdX => real()();
  RealColumn get sdY => real()();
  RealColumn get ringSizeMm => real()();
  RealColumn get ringLargeMm => real()();
  
  // ★追加: ゲームの種類を記録 (0: Center, 1: Count-Up)
  IntColumn get gameType => integer().withDefault(const Constant(0))(); 
  BoolColumn get isMasterOut => boolean().withDefault(const Constant(false))();
}

@DataClassName('Throw')
class Throws extends Table {
  IntColumn get id => integer().autoIncrement()();
  
  // 外部キー (どのゲームに属するか)
  IntColumn get gameId => integer().references(Games, #id)(); 

  // ダーツの位置 (mm)
  RealColumn get x => real()();
  RealColumn get y => real()();
  
  // 投擲順序
  IntColumn get orderIndex => integer()();
  
  // ★追加: リアルスコアのラベル (例: "T20", "S1", "OUT")
  TextColumn get segmentLabel => text().withDefault(const Constant(''))(); 
}

// ---------------------------------------------------------
// 2. データベースクラス
// ---------------------------------------------------------




@DriftDatabase(tables: [Games, Throws])
class AppDatabase extends _$AppDatabase {
  // ★修正: connection.getDatabase() を呼ぶように変更
  AppDatabase() : super(connection.getDatabase());

  @override
  int get schemaVersion => 1;
}

// ★追加: アプリ全体で共有するデータベースのインスタンス
late AppDatabase database;