# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 1. Product context

Flutter app `calculator` (**Calculator AI**) — máy tính đa tiện ích theo design Figma `Calc_v1`, hỗ trợ đa ngôn ngữ VN/EN.

App gồm 4 tab: **AI Tutor**, **Converter**, **Calculator** (mặc định), **Settings**.

- Đơn người dùng, không đăng nhập, dữ liệu lưu **cục bộ**.
- **Offline 100%** trừ **Currency Converter** (cần mạng để cập nhật tỷ giá).
- Đa ngôn ngữ; mọi định dạng số/ngày/giờ theo locale + cấu hình app.

Phạm vi đặc tả chi tiết: **Converter (Currency, Percentage, World Time), Calculator, Settings**. AI Tutor chỉ ghi nhận sự tồn tại.

## 2. Tech stack (actual implementation)

- **Platform**: Android & iOS (mobile-first), Flutter, Dart SDK `^3.11.3`, Material 3.
- **State management**: **Riverpod** (`@riverpod` notifier).
- **Navigation**: **AutoRoute**.
- **I18n**: **Slang** (base locale: `vi`).
- **Asset codegen**: **FlutterGen**.
- **Codegen runner**: `build_runner` (Riverpod, AutoRoute, json_serializable, Retrofit).
- **Storage** (declared, chưa dùng): `sqflite`, `shared_preferences`.
- **Network** (declared, chưa dùng): `dio` + `retrofit` — dành cho Currency rate API.

> **Lưu ý**: Một số file spec trong `docs/` (viết ở giai đoạn đầu) đề cập `flutter_bloc`, `go_router`, `intl`, `get_it/injectable`. **Implementation thực tế đã chốt Riverpod + AutoRoute + Slang** — khi spec mâu thuẫn với code, ưu tiên file này; cập nhật spec docs/ khi có dịp.

## 3. Common commands

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

## 4. Architecture

### 4.1 Tổ chức thư mục

- `lib/core/` — hạ tầng dùng chung: `router/` (AutoRoute), `theme/` (colors, dimens, text styles, theme builder), `widgets/` (widget tái sử dụng).
- `lib/features/<feature>/{domain,presentation}` — feature-first. `domain/` chứa pure logic + state model; `presentation/` chứa pages, controllers (Riverpod), widgets.
- `lib/gen/` — code sinh bởi FlutterGen (assets) và Slang (`strings.g.dart`).
- `assets/i18n/` — file dịch JSON cho Slang (`base_locale: vi`).

### 4.2 Pipeline tính toán (calculator feature)

Tách 3 lớp rõ ràng — khi sửa cần giữ ranh giới này:

1. **`CalculatorEngine`** (`features/calculator/domain/calculator_engine.dart`) — pure logic, không phụ thuộc Flutter. Quản lý chuyển đổi giữa biểu thức **UI** (`+ − × ÷` Unicode, dấu phẩy thập phân `,`, phân cách nghìn `.`) và **toán học** (`+ - * /`, dấu chấm thập phân). Có parser đệ quy riêng (`_Parser`) — không dùng library `math_expressions`.
2. **`CalculatorController`** (`presentation/controllers/calculator_controller.dart`) — Riverpod `@riverpod` notifier, là entry point duy nhất từ UI. Mỗi action gọi engine rồi `state = state.copyWith(...)`.
3. **Widgets** (`presentation/widgets/`) — `DisplayPanel`, `CalcGrid`, `MenuTabs`, `CalcButton` — chỉ đọc state qua `ref.watch(calculatorControllerProvider)` và gọi method controller.

`CalculatorState` (Equatable, immutable) gồm: `expression`, `display`, `history`, `errorMessage`, `justEvaluated`.

### 4.3 Quy ước hiển thị số

- Toán tử UI là Unicode: `displayPlus '+'`, `displayMinus '−'` (U+2212, KHÔNG phải `-`), `displayTimes '×'`, `displayDivide '÷'`.
- Dấu thập phân hiển thị: `.` (chuẩn US). Phân cách hàng nghìn: `,`.
- Khi đẩy ra engine để parse luôn dùng `engine.toMathExpression(...)`. Khi format kết quả gọi `engine.formatNumberForDisplay(...)`.

### 4.4 Hành vi tinh tế (đừng đổi mà không hiểu)

- `justEvaluated == true` (vừa nhấn `=`): digit tiếp theo **replace** chứ không append; operator tiếp theo dùng kết quả làm operand đầu; backspace = clear toàn bộ.
- `appendOperator` thay thế operator nếu expression kết thúc bằng operator; cho phép `−` đứng đầu (số âm) nhưng không cho phép operator khác đứng đầu.
- `equals()` bỏ qua nếu `justEvaluated` (tránh eval lặp) hoặc `expression` rỗng.
- `evaluate` trả `EvalResult` với `errorKey`: `'divide_by_zero'` hoặc `'generic'`. Controller set vào `errorMessage` (key thô). UI map sang i18n: `error_divide_by_zero` → `t.calculator.error_divide_by_zero`, `generic` → `t.calculator.error_generic`.

### 4.5 Routing (AutoRoute)

- Khai báo routes trong `lib/core/router/app_router.dart` (`@AutoRouterConfig(replaceInRouteName: 'Page,Route')`).
- Mọi page mới phải có `@RoutePage()` rồi chạy `build_runner` để sinh `app_router.gr.dart`.
- Initial route: `HomeRoute` (4 tab). Splash **không** là route — xem §4.9.

### 4.9 Splash (overlay-based)

- Không dùng route splash. `main.dart` gọi `FlutterNativeSplash.preserve` rồi precache ảnh + warm `SharedPreferences` trước `runApp`; `MaterialApp.router.builder` bọc `SplashOverlay` phủ lên Home đã mount sẵn.
- `SplashOverlay` (`features/splash/.../splash_page.dart`): postFrame đầu → `FlutterNativeSplash.remove()` + `splashController.start()`. Home build song song phía sau → khi overlay fade-out (`AnimatedOpacity` 250ms) thì Home đã ready → hand-off không gap. Fade xong → overlay tự gỡ khỏi cây.
- `SplashController` (`@riverpod`): `start()` chạy `Future.wait([_warmUp(), delay minSplashDuration])` rồi set `isReady`. `minSplashDuration = 2500ms` chống nháy logo; `_warmUp` pre-warm Calculator state, lỗi chỉ log (không chặn vào app).

### 4.6 I18n (Slang)

- Sửa `assets/i18n/vi.i18n.json` (base) và `en.i18n.json` rồi chạy `dart run slang` để sinh `lib/gen/strings.g.dart`.
- Dùng qua biến global `t.<scope>.<key>` (ví dụ `t.splash.app_name`).
- App init Slang trong `main.dart` (`LocaleSettings.useDeviceLocale()` + `TranslationProvider`).
- String resource giữ **normal case** trong JSON; nếu UI cần uppercase dùng `.toUpperCase()` trong Dart.

### 4.7 Theme

- V1 hiện tại: chỉ light theme, seed = `AppColors.brandOrange`, Material 3.
- TODO `theming-v2` (đã đánh dấu trong `app_colors.dart`/`app_theme.dart`): chuyển sang `ThemeExtension` khi triển khai 24 themes Figma — khi mở rộng theme, dùng pattern này thay vì hardcode thêm vào `AppColors`.

### 4.8 Assets

Dùng FlutterGen: `Assets.images.<name>`, `Assets.svg.<name>` (import `package:calculator/gen/assets.gen.dart`). Khi thêm asset mới vào `assets/images/` hoặc `assets/svg/`, chạy `build_runner` để regen.

## 5. Business rules cốt lõi

Các rule cross-cutting, áp dụng cho mọi feature:

- **I18n bắt buộc**: KHÔNG hardcode chuỗi UI. Mọi text đi qua Slang `t.<scope>.<key>`.
- **Format số**: theo `Number Format` + `Decimal Digits` trong Settings; luôn qua formatter, không print số trực tiếp.
- **Reactive settings**: thay đổi Settings (language, number format, decimal digits) có hiệu lực **tức thì** toàn app — KHÔNG có nút Save / Restore default.
- **Lưu cục bộ**: mọi dữ liệu local; không backend (ngoại lệ duy nhất: Currency rate API).
- **Lỗi async**: try-catch cho tỷ giá / I/O local; thông báo user qua **Snackbar/Toast** thân thiện.
- **Accessibility**: nhãn rõ cho screen reader; tương phản đạt chuẩn.
- **Đặt tên**: biến/hàm `camelCase`, class/widget `PascalCase`, hằng số `UPPER_SNAKE_CASE`.

## 6. Working principles

- Bám các file đặc tả trong `docs/` cho phạm vi tính năng và UI rules (xem §7 Spec reference index).
- KHÔNG phát sinh tính năng ngoài phạm vi tài liệu; nếu cần, ghi vào mục "Câu hỏi mở" của file spec liên quan.
- Khi tạo file spec mới cho 1 tính năng, đặt cạnh feature spec gốc trong `docs/` và cập nhật `docs/feature_spec.md`.
- KHÔNG sửa tay các file generated (`*.g.dart`, `*.gr.dart`, `lib/gen/*`) — chạy `build_runner` để regen.
- Khi spec ↔ implementation lệch nhau (xem warning ở §2), ưu tiên file này.

## 7. Spec reference index

Tài liệu thiết kế/đặc tả trong `docs/`:

| File | Nội dung |
|---|---|
| `feature_spec.md` | Đặc tả tính năng tổng quát + danh mục file chi tiết |
| `architecture.md` | Kiến trúc tổng quan, phân lớp, luồng dữ liệu |
| `ui_notes.md` | Quy ước UI/UX, điều hướng, lỗi, accessibility |
| `navigation_flow.md` | Route map, back stack, deep links, tab preservation |
| `permission_system_flow.md` | Permission Android/iOS, rationale dialog, fallback |
| `technical_design.md` | Thiết kế kỹ thuật chi tiết, Clean Architecture, roadmap |
| `solution_architecture_review.md` | Review tổng hợp + acceptance criteria + roadmap |
| `design_plan.md` | Master design plan (v2.0, baseline `spec-v1.0`) |
| `feature_calculator.md` | Calculator (Basic + Scientific + History) |
| `feature_converter.md` | Converter List + Currency Converter + Feedback |
| `feature_percentage_calculator_screen.md` | Percentage Calculator |
| `feature_world_time.md` | World Time Converter |
| `feature_setting.md` | Settings (System + Chat + Developer) |

## 8. Stack đã add nhưng chưa dùng

`dio` + `retrofit`, `sqflite`, `shared_preferences`, `audioplayers`, `video_player` + `chewie`, `image_picker`, `flutter_spinkit` đã được khai báo trong `pubspec.yaml` cho roadmap, **chưa có code sử dụng**. Khi bắt đầu dùng, đặt vào `core/` (cross-cutting) hoặc feature tương ứng theo cấu trúc feature-first hiện có.
