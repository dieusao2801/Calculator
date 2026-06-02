import 'package:auto_route/auto_route.dart';
import 'package:calculator/core/router/app_router.gr.dart';
import 'package:calculator/core/styles/app_colors.dart';
import 'package:calculator/core/styles/app_dimens.dart';
import 'package:calculator/core/styles/app_text_styles.dart';
import 'package:calculator/features/splash/presentation/providers/splash_controller.dart';
import 'package:calculator/gen/assets.gen.dart';
import 'package:calculator/gen/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@RoutePage()
class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // Gỡ native splash ngay sau frame Flutter đầu tiên để tránh nháy đen.
      FlutterNativeSplash.remove();
      ref.read(splashControllerProvider.notifier).start(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    // Khi controller báo sẵn sàng thì replace sang HomeRoute (đúng một lần).
    ref.listen<SplashState>(splashControllerProvider, (prev, next) {
      final wasReady = prev?.isReady ?? false;
      if (next.isReady && !wasReady && mounted) {
        context.router.replace(const HomeRoute());
      }
    });

    return Scaffold(
      backgroundColor: Colors.black, // Khớp với background đen của native splash
      body: Stack(
        children: [
          // 1. Background Image (Sử dụng Assets từ flutter_gen)
          Positioned.fill(
            child: Assets.images.bgSplash.image(
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(color: Colors.black),
            ),
          ),

          // 2. App Name (Vị trí bias 0.23 -> 23% màn hình)
          Positioned(
            top: screenHeight * 0.23,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                t.splash.app_name,
                style: AppTextStyles.splashAppName.copyWith(color: AppColors.brandOrange),
              ),
            ),
          ),

          // 3. Loading Message & ProgressBar (Vị trí bias 0.85 -> 85% màn hình)
          Positioned(
            top: screenHeight * 0.8,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.textOnDark),
                ),
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