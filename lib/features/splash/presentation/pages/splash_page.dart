import 'package:calculator/core/styles/app_colors.dart';
import 'package:calculator/core/styles/app_dimens.dart';
import 'package:calculator/core/styles/app_text_styles.dart';
import 'package:calculator/features/splash/presentation/providers/splash_controller.dart';
import 'package:calculator/gen/assets.gen.dart';
import 'package:calculator/gen/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Bootstrap overlay phủ lên Home đã mount sẵn. Khi bootstrap xong → fade out
/// → Home đã build hoàn tất → hand-off không gap, không giật.
class SplashOverlay extends ConsumerStatefulWidget {
  const SplashOverlay({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<SplashOverlay> createState() => _SplashOverlayState();
}

class _SplashOverlayState extends ConsumerState<SplashOverlay> {
  // Sau khi fade-out xong, gỡ hẳn overlay khỏi cây — tránh giữ layer ảnh splash
  // đè lên Home suốt vòng đời app.
  bool _overlayRemoved = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      // Precache image vào Flutter ImageCache TRƯỚC khi gỡ native splash —
      // đảm bảo Flutter overlay đã có ảnh khi xuất hiện, không chớp đen.
      // Try-catch: ảnh fail (asset path sai / OOM) vẫn phải cho qua, không
      // được block app ở native splash.
      try {
        await Future.wait([
          precacheImage(Assets.images.bgSplash.provider(), context),
          precacheImage(Assets.images.bgBackgroundClassic.provider(), context),
        ]);
      } catch (_) {}
      if (!mounted) return;
      FlutterNativeSplash.remove();
      ref.read(splashControllerProvider.notifier).start();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_overlayRemoved) return widget.child;

    final isReady = ref.watch(splashControllerProvider.select((s) => s.isReady));

    // Chặn back button Android khi overlay đang hiện — tránh user thoát app
    // trước khi bootstrap xong.
    return PopScope(
      canPop: isReady,
      child: Stack(
        children: [
          widget.child,
          IgnorePointer(
            ignoring: isReady,
            child: AnimatedOpacity(
              opacity: isReady ? 0 : 1,
              duration: const Duration(milliseconds: 250),
              onEnd: () {
                if (isReady && mounted) setState(() => _overlayRemoved = true);
              },
              // RepaintBoundary: tách paint layer overlay khỏi Home → khi fade
              // animate opacity, Home không bị invalidate paint theo.
              child: const RepaintBoundary(child: _SplashContent()),
            ),
          ),
        ],
      ),
    );
  }
}

class _SplashContent extends StatelessWidget {
  const _SplashContent();

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Material(
      // Khớp native splash bg (#ffffff trong pubspec.yaml) — tránh chớp xám lúc hand-off.
      color: Colors.white,
      child: Stack(
        children: [
          Positioned.fill(
            child: Assets.images.bgSplash.image(
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(color: Colors.white),
            ),
          ),
          Positioned(
            top: screenHeight * 0.23,
            left: 0,
            right: 0,
            child: Center(
              child: Text(t.splash.app_name, style: AppTextStyles.splashAppName.copyWith(color: AppColors.brandOrange)),
            ),
          ),
          Positioned(
            top: screenHeight * 0.8,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColors.textOnDark)),
                const SizedBox(height: AppDimens.gap16),
                Text(
                  t.splash.loading,
                  style: AppTextStyles.splashLoading.copyWith(color: AppColors.textOnDark),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
