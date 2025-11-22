import 'package:drift/drift.dart';
import 'package:drift/web.dart';

QueryExecutor getDatabase() {
  // ignore: deprecated_member_use
  return WebDatabase.withStorage(DriftWebStorage.volatile());
}