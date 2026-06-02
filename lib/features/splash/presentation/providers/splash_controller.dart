import 'package:calculator/core/log/app_log.dart';
import 'package:calculator/gen/assets.gen.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'splash_controller.g.dart';

class SplashState extends Equatable {
  const SplashState({this.isReady = false, this.errorKey});

  final bool isReady;
  final String? errorKey;

  SplashState copyWith({bool? isReady, String? errorKey, bool clearError = false}) {
    return SplashState(
      isReady: isReady ?? this.isReady,
      errorKey: clearError ? null : (errorKey ?? this.errorKey),
    );
  }

  @override
  List<Object?> get props => [isReady, errorKey];
}

@riverpod
class SplashController extends _$SplashController {
  // Thời lượng tối thiểu hiển thị splash, đảm bảo logo không bị nháy qua.
  static const Duration minSplashDuration = Duration(milliseconds: 2500);

  @override
  SplashState build() => const SplashState();

  // UI gọi sau frame đầu tiên với context hợp lệ để precache.
  Future<void> start(BuildContext context) async {
    await Future.wait([_warmUp(context), Future<void>.delayed(minSplashDuration)]);
    state = state.copyWith(isReady: true);
  }

  Future<void> _warmUp(BuildContext context) async {
    try {
      await precacheImage(Assets.images.bgBackgroundClassic.provider(), context);
    } catch (e) {
      AppLog.e(e);
    }
    // TODO: khi DB/prefs có init thật, đặt thêm await tại đây.
  }
}
