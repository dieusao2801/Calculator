import 'package:calculator/core/router/app_router.dart';
import 'package:calculator/core/theme/app_theme.dart';
import 'package:calculator/core/theme/theme_manager.dart';
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

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  static final _appRouter = AppRouter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeId = ref.watch(themeManagerProvider);
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
    );
  }
}
