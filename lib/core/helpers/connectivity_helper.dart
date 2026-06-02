import 'package:calculator/core/log/app_log.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'connectivity_helper.g.dart';

/// Helper kiểm tra kết nối mạng, wrap plugin `connectivity_plus`.
///
/// ⚠️ Lưu ý: helper chỉ check connection type (wifi/mobile/ethernet),
/// KHÔNG ping internet thật. "Có wifi" ≠ "có internet thật".
/// Nếu cần kiểm chứng internet thật, gọi API ping ở caller.
class ConnectivityHelper {
  ConnectivityHelper._();

  static final Connectivity _connectivity = Connectivity();

  /// Stream phát bool mỗi khi đổi trạng thái: true = có mạng, false = mất mạng.
  /// Caller chịu trách nhiệm cancel subscription khi không dùng.
  static Stream<bool> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged.map(_hasConnection);

  /// Check 1 lần.
  static Future<bool> get isConnected async {
    try {
      final result = await _connectivity.checkConnectivity();
      return _hasConnection(result);
    } catch (e) {
      AppLog.e('ConnectivityHelper.isConnected: $e');
      return false;
    }
  }

  /// Trả về list type kết nối thô (wifi/mobile/ethernet/none/...).
  static Future<List<ConnectivityResult>> getTypes() async {
    try {
      return await _connectivity.checkConnectivity();
    } catch (e) {
      AppLog.e('ConnectivityHelper.getTypes: $e');
      return const [ConnectivityResult.none];
    }
  }

  static bool _hasConnection(List<ConnectivityResult> results) {
    return results.any(
      (r) =>
          r == ConnectivityResult.wifi ||
          r == ConnectivityResult.mobile ||
          r == ConnectivityResult.ethernet ||
          r == ConnectivityResult.vpn,
    );
  }
}

/// Provider phát stream kết nối mạng — dùng trong UI để watch trạng thái online.
///
/// Ví dụ: `final online = ref.watch(connectivityStreamProvider).value ?? true;`
@riverpod
Stream<bool> connectivityStream(Ref ref) {
  return ConnectivityHelper.onConnectivityChanged;
}

/// Provider check 1 lần (async). Dùng cho FutureBuilder hoặc init flow.
@riverpod
Future<bool> isConnected(Ref ref) {
  return ConnectivityHelper.isConnected;
}