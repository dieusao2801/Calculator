import 'package:calculator/core/log/app_log.dart';
import 'package:calculator/features/calculator/presentation/providers/calculator_controller.dart';
import 'package:calculator/features/converter/currency/data/providers/currency_repository_providers.dart';
import 'package:equatable/equatable.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'splash_controller.g.dart';

class SplashState extends Equatable {
  const SplashState({this.isReady = false});

  final bool isReady;

  SplashState copyWith({bool? isReady}) {
    return SplashState(isReady: isReady ?? this.isReady);
  }

  @override
  List<Object?> get props => [isReady];
}

@riverpod
class SplashController extends _$SplashController {
  // Thời lượng tối thiểu hiển thị splash để logo không bị nháy qua.
  static const Duration minSplashDuration = Duration(milliseconds: 2500);

  // Trần thời gian warmUp — nếu DB/init hang, vẫn cho user vào app.
  static const Duration warmUpTimeout = Duration(seconds: 10);

  // Chặn start() chạy lại nếu overlay gọi lặp (rebuild bất thường).
  bool _started = false;

  @override
  SplashState build() => const SplashState();

  /// Gọi từ overlay sau frame đầu. Chạy song song với Home build phía sau.
  /// Asset image đã precache trong overlay → đây chỉ pre-warm DB + state Calculator.
  Future<void> start() async {
    if (_started) return;
    _started = true;
    try {
      await Future.wait([_warmUp(), Future<void>.delayed(minSplashDuration)]);
    } finally {
      // Luôn set isReady=true để không block user ở splash dù có lỗi.
      state = state.copyWith(isReady: true);
    }
  }

  Future<void> _warmUp() async {
    // Kick off currency init fire-and-forget — splash KHÔNG block do currency.
    // Controller `build()` ở màn Currency sẽ `await ref.watch(...future)`:
    // đang load → đợi resolve, đã xong → resolve ngay, chưa kick off → bắt đầu.
    ref.read(currencyInitializerProvider);

    try {
      await ref.read(calculatorControllerProvider.notifier).init().timeout(warmUpTimeout);
    } catch (e) {
      AppLog.e('SplashController warmup: $e');
    }
  }
}
