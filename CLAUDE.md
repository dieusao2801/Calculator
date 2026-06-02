# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Flutter app `calculator` (Calculator AI) — máy tính theo design Figma `Calc_v1`, hỗ trợ đa ngôn ngữ VN/EN. Dart SDK `^3.11.3`, Material 3.

## Common commands

```bash
# Cài / sync dependencies
flutter pub get

# Code generation (Riverpod, AutoRoute, json_serializable, Retrofit, FlutterGen)
dart run build_runner build --delete-conflicting-outputs
dart run build_runner watch --delete-conflicting-outputs
dart run build_runner clean

# Sinh code i18n Slang (khi sửa assets/i18n/*.json)
dart run slang

# Lint / phân tích static
flutter analyze

# Chạy test
flutter test
flutter test test/widget_test.dart                 # 1 file
flutter test --plain-name "tên test"               # 1 test theo tên

# Chạy app
flutter run

# Sinh launcher icons / native splash (khi đổi assets nguồn)
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

Output `build_runner` sinh ra các file `*.g.dart` (Riverpod, json), `*.gr.dart` (AutoRoute) và `lib/gen/*` (FlutterGen). **Không sửa tay** các file này — chúng sẽ bị ghi đè.

## Architecture

### Tổ chức thư mục

- `lib/core/` — hạ tầng dùng chung: `router/` (AutoRoute), `theme/` (colors, dimens, text styles, theme builder), `widgets/` (widget tái sử dụng).
- `lib/features/<feature>/{domain,presentation}` — feature-first. `domain/` chứa pure logic + state model; `presentation/` chứa pages, controllers (Riverpod), widgets.
- `lib/gen/` — code sinh bởi FlutterGen (assets) và Slang (`strings.g.dart`).
- `assets/i18n/` — file dịch JSON cho Slang (`base_locale: vi`).

### Pipeline tính toán (calculator feature)

Tách 3 lớp rõ ràng — khi sửa cần giữ ranh giới này:

1. **`CalculatorEngine`** (`features/calculator/domain/calculator_engine.dart`) — pure logic, không phụ thuộc Flutter. Quản lý chuyển đổi giữa biểu thức **UI** (`+ − × ÷` Unicode, dấu phẩy thập phân `,`, phân cách nghìn `.`) và **toán học** (`+ - * /`, dấu chấm thập phân). Có parser đệ quy riêng (`_Parser`) — không dùng library `math_expressions`.
2. **`CalculatorController`** (`presentation/controllers/calculator_controller.dart`) — Riverpod `@riverpod` notifier, là entry point duy nhất từ UI. Mỗi action gọi engine rồi `state = state.copyWith(...)`.
3. **Widgets** (`presentation/widgets/`) — `DisplayPanel`, `CalcGrid`, `MenuTabs`, `CalcButton` — chỉ đọc state qua `ref.watch(calculatorControllerProvider)` và gọi method controller.

`CalculatorState` (Equatable, immutable) gồm: `expression`, `display`, `history`, `errorMessage`, `justEvaluated`.

### Quy ước hiển thị số

- Toán tử UI là Unicode: `displayPlus '+'`, `displayMinus '−'` (U+2212, KHÔNG phải `-`), `displayTimes '×'`, `displayDivide '÷'`.
- Dấu thập phân hiển thị: `,` (chuẩn VN). Phân cách hàng nghìn: `.`.
- Khi đẩy ra engine để parse luôn dùng `engine.toMathExpression(...)`. Khi format kết quả gọi `engine.formatNumberForDisplay(...)`.

### Hành vi tinh tế (đừng đổi mà không hiểu)

- `justEvaluated == true` (vừa nhấn `=`): digit tiếp theo **replace** chứ không append; operator tiếp theo dùng kết quả làm operand đầu; backspace = clear toàn bộ.
- `appendOperator` thay thế operator nếu expression kết thúc bằng operator; cho phép `−` đứng đầu (số âm) nhưng không cho phép operator khác đứng đầu.
- `equals()` bỏ qua nếu `justEvaluated` (tránh eval lặp) hoặc `expression` rỗng.
- `evaluate` trả `EvalResult` với `errorKey`: `'divide_by_zero'` hoặc `'generic'`. Controller set vào `errorMessage` (key thô). UI map sang i18n: `error_divide_by_zero` → `t.calculator.error_divide_by_zero`, `generic` → `t.calculator.error_generic`.

### Routing (AutoRoute)

- Khai báo routes trong `lib/core/router/app_router.dart` (`@AutoRouterConfig(replaceInRouteName: 'Page,Route')`).
- Mọi page mới phải có `@RoutePage()` rồi chạy `build_runner` để sinh `app_router.gr.dart`.
- Initial route: `SplashRoute` → tự `replace` sang `CalculatorRoute` sau 3 s.

### I18n (Slang)

- Sửa `assets/i18n/vi.i18n.json` (base) và `en.i18n.json` rồi chạy `dart run slang` để sinh `lib/gen/strings.g.dart`.
- Dùng qua biến global `t.<scope>.<key>` (ví dụ `t.splash.app_name`).
- App init Slang trong `main.dart` (`LocaleSettings.useDeviceLocale()` + `TranslationProvider`).
- String resource giữ **normal case** trong JSON; nếu UI cần uppercase dùng `.toUpperCase()` trong Dart.

### Theme

- V1 hiện tại: chỉ light theme, seed = `AppColors.brandOrange`, Material 3.
- TODO `theming-v2` (đã đánh dấu trong `app_colors.dart`/`app_theme.dart`): chuyển sang `ThemeExtension` khi triển khai 24 themes Figma — khi mở rộng theme, dùng pattern này thay vì hardcode thêm vào `AppColors`.

### Assets

Dùng FlutterGen: `Assets.images.<name>`, `Assets.svg.<name>` (import `package:calculator/gen/assets.gen.dart`). Khi thêm asset mới vào `assets/images/` hoặc `assets/svg/`, chạy `build_runner` để regen.

## Stack đã add nhưng chưa dùng

`dio` + `retrofit`, `sqflite`, `shared_preferences`, `audioplayers`, `video_player` + `chewie`, `image_picker`, `flutter_spinkit` đã được khai báo trong `pubspec.yaml` cho roadmap, **chưa có code sử dụng**. Khi bắt đầu dùng, đặt vào `core/` (cross-cutting) hoặc feature tương ứng theo cấu trúc feature-first hiện có.