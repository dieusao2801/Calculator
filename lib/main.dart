import 'dart:async';

import 'package:calculator/core/helpers/platform_info.dart';
import 'package:calculator/core/prefs/shared_preferences_provider.dart';
import 'package:calculator/core/router/app_router.dart';
import 'package:calculator/core/theme/app_theme.dart';
import 'package:calculator/core/theme/theme_manager.dart';
import 'package:calculator/features/calculator/presentation/providers/calculator_controller.dart';
import 'package:calculator/features/settings/presentation/providers/settings_controller.dart';
import 'package:calculator/features/splash/presentation/pages/splash_page.dart';
import 'package:calculator/gen/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  LocaleSettings.useDeviceLocale();

  // Warm-up SharedPreferences trước runApp để theme load đồng bộ ở build đầu.
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: TranslationProvider(child: const MyApp()),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  static final _appRouter = AppRouter();
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onPause: _persistExpression);
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  /*
    Chức năng: Snapshot expression hiện tại vào prefs khi app rời foreground —
    đảm bảo lần mở sau khôi phục đúng biểu thức đang dở. Delegate xuống
    controller để giữ entry point UI duy nhất.
  */
  void _persistExpression() {
    unawaited(ref.read(calculatorControllerProvider.notifier).persistExpression());
  }

  @override
  Widget build(BuildContext context) {
    final themeId = ref.watch(themeManagerProvider);
    // Warm-up SettingsController để sync flag sound/vibration vào helpers
    // ngay từ frame đầu, trước khi user tap nút bất kỳ.
    ref.watch(settingsControllerProvider);
    return MaterialApp.router(
      title: t.splash.app_name,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.fromId(themeId),
      // Cấu hình AutoRoute
      routerConfig: _appRouter.config(),
      // Cấu hình Đa ngôn ngữ (Slang + Flutter Localizations)
      locale: TranslationProvider.of(context).flutterLocale,
      supportedLocales: AppLocaleUtils.supportedLocales,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      // Bootstrap overlay phủ lên Home đã mount sẵn. Home build song song với splash
      // → khi overlay fade out, Home đã ready → hand-off không gap.
      builder: (context, child) => SplashOverlay(child: child ?? const SizedBox.shrink()),
    );
  }
}
