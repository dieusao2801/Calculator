import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'shared_preferences_provider.g.dart';

/*
  Chức năng: Cung cấp instance [SharedPreferences] đã warm-up cho cây Riverpod.
  Throw UnimplementedError nếu chưa override — buộc caller phải warm-up trước
  để theme/settings load đồng bộ ở frame đầu (tránh flicker).
  Gọi tại: `main.dart` — `ProviderScope.overrides` truyền instance đã warm-up.
*/
@Riverpod(keepAlive: true)
SharedPreferences sharedPreferences(Ref ref) {
  throw UnimplementedError('must override sharedPreferencesProvider in main.dart');
}
