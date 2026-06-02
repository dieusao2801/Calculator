import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'app_database.dart';

part 'database_provider.g.dart';

/// Provider cung cấp instance duy nhất của AppDatabase toàn app.
@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  final db = AppDatabase();
  // Đảm bảo đóng database khi provider không còn dùng (nếu cần)
  ref.onDispose(() => db.close());
  return db;
}
