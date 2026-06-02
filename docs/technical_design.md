# Technical Design Document — Calculator AI (Flutter Android/iOS)

> **Trạng thái**: Draft v1.0 — 2026-06-01
> **Phạm vi**: Phân tích spec, thiết kế kỹ thuật, Clean Architecture, Implementation Roadmap
> **Không bao gồm**: Mô tả UI vi mô (đã có Figma/ui_notes.md), code snippets

---

## 1. Executive Summary

Calculator AI là ứng dụng mobile Flutter (Android + iOS) offline-first, đơn người dùng, không tài khoản. Gồm 4 module chính: **AI Tutor** (out-of-scope chi tiết), **Converter** (Currency, Percentage, World Time), **Calculator** (Basic, Scientific), **Settings**.

Điểm kỹ thuật nổi bật cần kiến trúc cẩn thận:
- **Reactive settings**: Thay đổi Number Format / Decimal Digits phải re-render tức thì toàn app.
- **Currency API + offline cache**: Cần chiến lược cache rõ ràng với TTL.
- **Calculator engine**: Phải parse biểu thức infix, hỗ trợ hàm khoa học, DEG/RAD/GRA.
- **World Time + DST**: Phụ thuộc IANA timezone database, phải bundle offline.
- **Bi-directional calculation** (Percentage): Tính ngược từ bất kỳ trường nào.

**Kiến trúc đề xuất**: Clean Architecture 3 tầng (Presentation → Domain → Data), State Management bằng **flutter_bloc (Cubit)**, Navigation bằng **go_router**, Local storage bằng **SharedPreferences** (config) + **Hive** (history/favorites).

---

## 2. Document / Source-of-Truth Review

| File | Vai trò | Trạng thái |
|---|---|---|
| `CLAUDE.md` | Coding guidelines, platform target | ✅ Đã chuẩn hóa |
| `architecture.md` | Cấu trúc thư mục, data models | ✅ Đã chuẩn hóa |
| `feature_spec.md` | Đặc tả tổng quan tất cả tính năng | ✅ Đã chuẩn hóa |
| `ui_notes.md` | Design system, màu sắc, typography | ✅ Không thay đổi |
| `feature_calculator.md` | Đặc tả chi tiết Calculator | ✅ Đã sửa hàng 2 Scientific |
| `feature_converter.md` | Đặc tả chi tiết Converter list + Currency + Feedback | ✅ Source of truth |
| `feature_percentage_calculator_screen.md` | Đặc tả chi tiết Percentage | ✅ Source of truth |
| `feature_world_time.md` | Đặc tả chi tiết World Time | ✅ Đã sửa format 24h |
| `feature_setting.md` | Đặc tả chi tiết Settings | ✅ Đã đóng Open Questions |

**Quy ước ưu tiên khi xung đột**: File tính năng chi tiết (`feature_*.md`) > `feature_spec.md` > `architecture.md`, với điều kiện không mâu thuẫn với acceptance criteria đã confirmed.

---

## 3. Spec Conflicts & Assumptions

### Đã giải quyết (Confirmed)

| # | Xung đột | Quyết định |
|---|---|---|
| C1 | Tên nhóm Settings thứ 3 | **DEVELOPER SETTINGS** |
| C2 | Nhãn mục Rating | **"Rate us 5 stars"** |
| C3 | Keep Calculator Record: xóa draft khi thoát app hay cả chuyển tab | **Cả hai: thoát app VÀ chuyển tab** |
| C4 | Percentage keyboard 4x4 vs 4x5 | **4x5** (theo feature_percentage) |
| C5 | `vibration` vs `vibrationEnabled` field name | **`vibrationEnabled`** |
| C6 | World Time format 12h/24h | **24h cố định** |
| C7 | Vị trí Chat Settings | **Trong Tab Settings** |
| C8 | Bàn phím Scientific hàng 2 | **Không có DEG/RAD/GRA trên keypad — cycle qua tap nhãn header. `rand` đặt ở 1 ô riêng. dec/hex/bin out of scope MVP.** |
| C9 | Favorites sort | **Theo thứ tự thêm vào, không drag-drop, không giới hạn số lượng** |
| C10 | Currency Caution Dialog auto-show lần đầu | **Không auto-show — chỉ mở khi tap menu `Caution`** |
| C11 | Feedback submit offline | **Báo lỗi Snackbar, không queue** |
| C12 | Backend Feedback | **mailto (deep-link `mailto:`), không HTTP submit** |
| C13 | Calculator Overlay | **Shared giữa Currency + Percentage. World Time ẩn icon Calculator ở Bottom Bar. Title overlay = tên field gọi. Không lưu Calculator History.** |
| C14 | World Time History | **Bỏ hoàn toàn trong MVP** |
| C15 | Ads (banner/interstitial/IAP) | **Out of scope MVP** |
| C16 | Ngưỡng scientific notation toàn app | **`|x| ≥ 1e15` hoặc `0 < |x| < 1e-6`** |
| C17 | Bottom Bar tool icon Calculator | **Giữ ở Currency + Percentage; ẨN ở World Time** |

### Assumptions (chưa có stakeholder confirm)

| # | Assumption | Lý do |
|---|---|---|
| A1 | ✅ Themes không có IAP, chưa cần implement | Defer — chỉ cần placeholder button trong Settings |
| A2 | ✅ Đổi ngôn ngữ hot-reload dùng `intl` + `flutter_localizations` | **Confirmed** — AppConfigCubit emit locale mới → MaterialApp.locale rebuild toàn widget tree |
| A3 | Currency cache TTL = 1 giờ | Không có spec — dùng 1h là chuẩn ngành |
| A4 | Giới hạn biểu thức Calculator = 50 ký tự | Theo feature_calculator.md |
| A5 | `favoriteCurrency` tự động cập nhật theo FROM currency cuối cùng chọn | Không có UI picker riêng |
| A6 | Help → link web ngoài (áp dụng quy tắc ẩn nếu URL rỗng) | Consistent với Privacy/Rating |
| A7 | App Widget hiển thị ô nhập nhanh Basic Calculator | Chưa xác nhận chi tiết |
| A8 | Notification Shortcut → shortcut mở Calculator tab | Chưa xác nhận |

### Open Questions còn lại

| # | Câu hỏi | Ảnh hưởng |
|---|---|---|
| OQ1 | Themes: bao nhiêu theme? IAP không? | Architecture payment module |
| OQ2 | Startup Calculator: danh sách đầy đủ các option? | Settings picker |
| OQ3 | App Widget: kích thước, loại widget? | Native Android widget code |
| OQ4 | Notification Shortcut: dẫn tới tính năng nào? | Intent handling |
| OQ5 | Đồng bộ đa thiết bị: có roadmap không? | Data layer design |
| OQ6 | Xóa chat history theo khoảng thời gian? | AI Tutor data model |

---

## 4. Product Structure

```
Calculator AI
├── Shell (4-tab bottom nav)
│   ├── [0] AI Tutor        — out-of-scope
│   ├── [1] Converter
│   │   ├── List Screen      (search, favorites grid, categorized list)
│   │   ├── Currency Converter Screen
│   │   │   └── History Screen
│   │   ├── Percentage Calculator Screen
│   │   │   └── History Screen
│   │   └── World Time Converter Screen
│   │       └── Add City Screen
│   ├── [2] Calculator       ← default tab
│   │   └── History Screen
│   └── [3] Settings
│       ├── Themes Screen     (TBD scope)
│       ├── Chat History Screen
│       └── Feedback Screen   (shared, routed từ bất kỳ tool nào)
└── Splash Screen
```

**Default tab**: Calculator (index 2).
**Back behavior**: Bất kỳ tab nào ≠ Calculator → về Calculator. Tại Calculator → Exit Dialog.

---

## 5. End-to-End Flows

### 5.1 App Startup Flow

```
Splash
  → Load AppConfig từ SharedPreferences
  → Khởi tạo global BLoC (AppConfigCubit, FavoritesCubit)
  → Kiểm tra Battery Optimization (Android only)
  → Navigate to Home
      → Restore Calculator draft (nếu keepCalculatorRecord = true)
      → Currency: kiểm tra cache TTL → auto-fetch nếu hết hạn
```

### 5.2 Settings Change Propagation Flow

```
User thay đổi Number Format / Decimal Digits
  → AppConfigCubit.updateConfig()
  → Persist to SharedPreferences
  → AppConfigCubit emit state mới
  → Mọi widget đang lắng nghe AppConfigCubit rebuild
      → Calculator display: re-format kết quả hiện tại
      → Currency Converter: re-format tất cả ô giá trị
      → Percentage Calculator: re-format tất cả trường
```

### 5.3 Currency Converter Data Flow

```
Mở Currency Converter
  → CurrencyConverterCubit.init()
      → Check local cache (Hive): timestamp còn hạn? (< 1h)
          → Có: emit CurrencyLoaded(fromCache: true)
          → Không: gọi CurrencyRepository.fetchRates()
              → Thành công: lưu cache Hive → emit CurrencyLoaded(fromCache: false)
              → Thất bại + có cache cũ: emit CurrencyLoadedOffline(cachedData)
              → Thất bại + không có cache: emit CurrencyError()

User nhập số
  → CurrencyConverterCubit.onInputChanged(value, focusedIndex)
  → Tính toán đồng bộ (synchronous) tất cả ô còn lại
  → emit CurrencyConverterState mới với values đã tính
```

### 5.4 Calculator Computation Flow

```
User nhập ký tự
  → CalculatorCubit.onKeyPress(key)
  → CalculatorEngine.appendToExpression(key, currentExpression)
      → Validate syntax (auto-replace operator, auto-close bracket)
      → Preview evaluate nếu biểu thức hợp lệ
  → emit CalculatorState(expression, previewResult)

User nhấn =
  → CalculatorEngine.evaluate(expression, angleMode)
      → Parse infix → postfix (Shunting-yard)
      → Evaluate postfix
      → Nếu lỗi: return ErrorResult
      → Nếu ok: return NumericResult
  → Nếu NumericResult: thêm vào HistoryRepository → emit result
  → Nếu ErrorResult: emit CalculatorError (Snackbar)
```

### 5.5 World Time Reference Mode Flow

```
Chế độ mặc định: Live Time
  → Timer tick mỗi giây
  → WorldTimeCubit emit danh sách thành phố với T = DateTime.now()

User chạm vào thẻ thành phố
  → Mở EditReferenceDialog(city)
  → User chọn ngày/giờ → OK
  → WorldTimeCubit.setReferenceTime(city, dateTime)
      → Cancel live timer
      → Tính T_target = T_reference + (offset_target - offset_reference)
      → emit WorldTimeState(referenceMode: true, cities: [...computed times])

User muốn quay lại Live
  → WorldTimeCubit.clearReferenceTime()
  → Restart timer
```

---

## 6. Feature-by-Feature Design

### 6.1 Calculator

**State model:**
```
CalculatorState {
  expression: String          // biểu thức đang nhập
  previewResult: String       // kết quả nháp (empty nếu invalid)
  angleMode: AngleMode        // DEG | RAD | GRA
  isScientificMode: bool      // bàn phím scientific đang mở?
  showAngleIndicator: bool    // true khi expression chứa trig func
  historyPreview: String?     // phép tính gần nhất
}
```

**Key behaviors:**
- Auto-replace: Nhập toán tử liên tiếp → thay thế, không append.
- Auto-close bracket khi nhấn `=`.
- Long-press `()` → wrap toàn bộ expression.
- Sau khi chèn scientific func → auto về basic keyboard.
- Draft: persist khi `keepCalculatorRecord = true`, xóa khi false + (tab change hoặc app close).
- Rollback stack: lưu stack expression states trong phiên, reset khi app khởi động.

**Error states:**
- Invalid syntax → Snackbar, không lưu history.
- Division by 0, sqrt(-x), overflow → hiển thị `"giá trị tính vượt phạm vi"`.
- Expression length ≥ 50 ký tự → block input.

### 6.2 Currency Converter

**State model:**
```
CurrencyConverterState {
  mode: ConversionMode        // simple | advanced
  currencies: List<String>    // 2 hoặc 4 mã ISO
  values: List<String>        // giá trị hiển thị từng ô
  focusedIndex: int
  rateData: CurrencyRateData? // null nếu chưa load
  loadStatus: LoadStatus      // loading | loaded | offline | error
  lastUpdated: DateTime?
  // KHÔNG có showCautionOnFirstOpen — Caution chỉ mở khi tap menu (per C10)
}
```

**Conversion logic:**
- Tất cả tỷ giá normalize về USD base.
- `value_B = value_A * (rate_B / rate_A)`
- Khi nhập ô A: tính tất cả ô còn lại đồng bộ.

**Cache strategy:**
- Key: `currency_rates_cache` trong Hive.
- TTL: 1 giờ. Nếu hết hạn → auto fetch background.
- Manual refresh: bypass TTL.

### 6.3 Percentage Calculator

**State model:**
```
PercentageState {
  mode: PercentageMode        // percentOfNumber | percentChange
  isPositiveChange: bool      // chỉ dùng ở mode 2
  fields: Map<FieldKey, String>  // giá trị các trường
  focusedField: FieldKey
  modeOneState: Map<FieldKey, String>  // preserved state mode 1
  modeTwoState: Map<FieldKey, String>  // preserved state mode 2
}
```

**Bi-directional logic:**
- Mode 1: 3 trường (Number, Percentage, Result) — bất kỳ 2 trường có giá trị → tính trường thứ 3.
- Mode 2: 4 trường (Initial, Percentage, Change, Final) — 2 trường có giá trị → tính 2 trường còn lại.
- Khi tất cả trường đầy và user sửa 1 trường → giữ nguyên trường vừa sửa + trường được sửa gần nhất, tính lại trường còn lại.
- Trường rỗng → không báo lỗi, để trống trường kết quả.

**Decimal constraints:**
- Trường Percentage: max 3 chữ số thập phân khi nhập.
- Các trường còn lại: max 6 chữ số thập phân khi nhập.
- Hiển thị tuân theo `decimalDigits` từ AppConfig.

### 6.4 World Time Converter

**State model:**
```
WorldTimeState {
  cities: List<CityTimeEntry>  // bao gồm device timezone ở index 0
  referenceCity: String?       // IANA ID anchor của card được tap mở Set Time
  referenceTime: DateTime?     // null = Now mode
  sortCriteria: SortCriteria   // name | time
  sortAscending: bool
  isEditMode: bool
  selectedForDelete: Set<String>

  bool get isReferenceMode => referenceTime != null;
}

CityTimeEntry {
  timezoneId: String           // IANA ID
  cityName: String             // localized
  countryName: String          // localized
  displayTime: DateTime        // computed
  gmtOffset: Duration
  isDST: bool
  isDeviceTimezone: bool
}
```

**DST handling:**
- Dùng `timezone` package (bundle IANA tzdata offline).
- Mỗi khi compute `displayTime`, lấy offset tại thời điểm đó (không dùng static offset).
- `isDST = location.isDstActive(referenceTime ?? DateTime.now())`.

**Timezone change detection:**
- Lắng nghe `SystemChannels.platform` (hoặc package `flutter_timezone`) khi app resume.
- So sánh timezone ID mới với device card hiện tại.

### 6.5 Settings

**State model:**
```
AppConfigState {
  language: String
  measurementUnit: MeasurementUnit
  numberFormat: NumberFormat
  decimalDigits: int
  vibrationEnabled: bool
  soundEnabled: bool
  alwaysOnScreen: bool
  keepCalculatorRecord: bool
  startupCalculator: StartupCalculator
  favoriteCurrency: String          // auto-update theo FROM currency cuối cùng chọn
  favoriteTools: List<String>       // tool IDs theo addedOrder
  privacyUrl: String?               // ẩn item nếu null/empty
  storeUrl: String?
  moreAppsUrl: String?
  helpUrl: String?
}
```

**Instant apply mechanism:**
- AppConfigCubit là global singleton (provided ở root).
- Mọi màn hình dùng `BlocBuilder<AppConfigCubit, AppConfigState>` để rebuild khi config thay đổi.
- `alwaysOnScreen`: gọi `WakelockPlus.enable/disable()` ngay khi toggle.
- `language`: rebuild toàn bộ widget tree qua `MaterialApp.locale`.

**Battery Optimization (Android only):**
- Check bằng `battery_optimization_android` package khi `initState` và khi app resume.
- Hiển thị mục nếu `!isIgnoringBatteryOptimizations`.

---

## 7. Screen Design Summary

| Screen | Route | Cubit(s) | Persistent State |
|---|---|---|---|
| Splash | `/splash` | AppConfigCubit (init) | — |
| Home Shell | `/home` | — | Tab index |
| Calculator | `/home/calculator` | CalculatorCubit | Draft expression |
| Calculator History | `/home/calculator/history` | CalculatorHistoryCubit | — |
| Converter List | `/home/converter` | ConverterListCubit, FavoritesCubit | — |
| Currency Converter | `/home/converter/currency` | CurrencyConverterCubit | Last currencies used |
| Currency History | `/home/converter/currency/history` | CurrencyHistoryCubit | — |
| Percentage Calc | `/home/converter/percentage` | PercentageCubit | — |
| Percentage History | `/home/converter/percentage/history` | PercentageHistoryCubit | — |
| World Time | `/home/converter/world-time` | WorldTimeCubit | Cities list, sort |
| Add City | `/home/converter/world-time/add` | WorldTimeCubit (shared) | — |
| Settings | `/home/settings` | AppConfigCubit, SettingsCubit | — |
| Chat History | `/home/settings/chat-history` | ChatHistoryCubit | — |
| Feedback | `/feedback?source=<toolId>` | FeedbackCubit | — |
| Themes | `/home/settings/themes` | ThemesCubit | — |

---

## 8. Domain / Data Design

### 8.1 Entity Layer (Domain)

```dart
// Entities thuần túy, không phụ thuộc Flutter/package
AppConfig, CurrencyRate, CurrencyHistoryItem,
PercentageHistoryItem, WorldTimeCity, CalculatorHistoryItem,
ConverterTool, FavoriteItem
```

### 8.2 Repository Interfaces (Domain)

```
IAppConfigRepository       — get/save AppConfig
ICurrencyRepository        — fetchRates(), getCachedRates(), saveRates()
ICalculatorHistoryRepository — getAll(), add(), delete(), clear()
ICurrencyHistoryRepository — getAll(), add(), delete(), clear()
IPercentageHistoryRepository — getAll(), add(), delete(), clear()
IWorldTimeRepository       — getCities(), saveCities(), getSortState()
IFavoritesRepository       — getAll(), add(), remove(), reorder()
IFeedbackService           — buildMailtoUri(feedback) → Uri (mailto deep-link, không HTTP submit, không repository)
```

### 8.3 Data Layer Mapping

| Repository | Storage | Key/Box |
|---|---|---|
| AppConfig | SharedPreferences | `app_config_*` keys |
| CurrencyRate cache | Hive Box | `currency_cache` |
| Calculator History | Hive Box | `calculator_history` |
| Currency History | Hive Box | `currency_history` |
| Percentage History | Hive Box | `percentage_history` |
| World Time Cities | Hive Box | `world_time_cities` |
| Favorites | Hive Box | `favorites` |

### 8.4 Data Models (Hive)

```dart
@HiveType() class CurrencyRateCacheModel {
  String base;
  Map<String, double> rates;
  int timestamp; // Unix ms
}

@HiveType() class CalculatorHistoryModel {
  String id;
  String expression;
  String result;
  String angleMode; // 'deg' | 'rad' | 'gra'
  int timestamp;
}

@HiveType() class CurrencyHistoryModel {
  String id;
  bool isAdvancedMode;
  List<String> currencyList;
  double inputValue;
  Map<String, double> outputValues;
  int rateTimestamp;
  int timestamp;
}

@HiveType() class PercentageHistoryModel {
  String id;
  String mode; // 'percentOfNumber' | 'percentChange'
  double? numberVal;
  double? percentageVal;
  double? changeVal;
  double? resultVal;
  bool isAddition;
  int timestamp;
}

@HiveType() class WorldTimeCityModel {
  String timezoneId;
  int addedOrder;
}

@HiveType() class WorldTimeStateModel {
  List<String> selectedCityIds;  // user-added (chưa gồm device)
  String? referenceCity;          // IANA ID anchor
  int? referenceTimeMs;           // Unix ms; null = Now mode
  String sortCriteria;            // 'name' | 'time'
  bool sortAscending;
}
// KHÔNG còn WorldTimeHistoryModel — bỏ trong MVP (per C14)
```

---

## 9. Calculator Engine Design

**Thư viện**: Không dùng thư viện parse bên ngoài — implement custom parser để kiểm soát hoàn toàn behavior.

### 9.1 Pipeline

```
Raw input string
  → Tokenizer: tách thành List<Token> (số, operator, func, paren, constant)
  → Validator: kiểm tra syntax (báo lỗi early)
  → Shunting-Yard: infix → RPN (Reverse Polish Notation)
  → Evaluator: tính RPN với AngleMode context
  → Formatter: áp dụng NumberFormat + DecimalDigits
  → Display string
```

### 9.2 Supported Operations

| Nhóm | Phép tính |
|---|---|
| Cơ bản | +, −, ×, ÷, ^ |
| Tiện ích | %, 1/x, x², √x, ∛x, \|x\|, x! |
| Logarit | log, ln, eˣ, 10ˣ |
| Lượng giác | sin, cos, tan, asin, acos, atan |
| Hyperbolic | sinh, cosh, tanh, asinh, acosh, atanh |
| Hằng số | π, e, φ (golden ratio) |
| Đặc biệt | random (0–1) |

### 9.3 Angle Mode

- State lưu trong `CalculatorCubit`.
- Khi evaluate: các hàm trig nhận input theo `angleMode`.
- DEG → RAD conversion: `rad = deg × π / 180`.
- GRA → RAD conversion: `rad = gra × π / 200`.

### 9.4 Precision

- Dùng `double` (64-bit IEEE 754) cho tính toán.
- Overflow / NaN / Infinity → catch và map sang `"giá trị tính vượt phạm vi"`.
- Hiển thị: làm tròn theo `decimalDigits`, bỏ trailing zero không cần thiết trừ khi `decimalDigits` fixed.

### 9.5 Number Formatter

Shared utility class `NumberFormatter` dùng trên toàn app:

```
NumberFormatter.format(value, config)
  → Nếu |value| ≥ 1e15 hoặc (0 < |value| < 1e-6) → scientific notation
  → Ngược lại:
      → Áp dụng grouping separator (theo numberFormat)
      → Áp dụng decimal separator (theo numberFormat)
      → Truncate/round theo decimalDigits
      → Nếu |value| < 10^(-decimalDigits) → mở rộng decimalDigits để giữ ≥ 3 chữ số có nghĩa
```

---

## 10. State Management

**Thư viện**: `flutter_bloc` (Cubit variant cho các case đơn giản, Bloc cho Calculator và Currency).

### 10.1 Cubit/Bloc Tree

```
MaterialApp
└── MultiBlocProvider
    ├── AppConfigCubit         (global — language, format, toggles)
    ├── ThemesCubit            (global — light/dark)
    ├── FavoritesCubit         (global — favorites list)
    └── HomeShellCubit         (tab index)
        ├── CalculatorBloc     (scoped to Calculator tab)
        ├── ConverterListCubit (scoped to Converter tab)
        ├── CurrencyConverterBloc (scoped, recreate khi navigate vào)
        ├── PercentageCubit    (scoped)
        ├── WorldTimeCubit     (scoped, có Timer)
        └── SettingsCubit      (scoped to Settings tab)
```

### 10.2 Persistence Strategy

- **AppConfigCubit**: Mỗi `emit()` → async persist to SharedPreferences.
- **CalculatorBloc**: Draft persist khi `keepCalculatorRecord = true`. Restore khi init.
- **WorldTimeCubit**: Cities persist khi add/remove/sort. Restore khi init.
- **CurrencyConverterBloc**: Last selected currencies persist to SharedPreferences.
- **History Cubits**: Hive tự động persist, không cần manual save.

### 10.3 Reactive Settings Update

```dart
// Trong mỗi screen widget:
BlocListener<AppConfigCubit, AppConfigState>(
  listenWhen: (prev, curr) => prev.numberFormat != curr.numberFormat
      || prev.decimalDigits != curr.decimalDigits,
  listener: (ctx, state) => ctx.read<CalculatorBloc>().add(ReformatDisplay()),
)
```

---

## 11. Navigation

**Thư viện**: `go_router` v14+.

### 11.1 Route Structure

```dart
GoRouter(
  initialLocation: '/home/calculator',
  routes: [
    GoRoute(path: '/splash', ...),
    StatefulShellRoute(   // 4-tab shell, preserve state per tab
      branches: [
        StatefulShellBranch(routes: [GoRoute('/home/ai-tutor', ...)]),
        StatefulShellBranch(routes: [
          GoRoute('/home/converter', builder: ConverterListScreen,
            routes: [
              GoRoute('currency', routes: [GoRoute('history', ...)]),
              GoRoute('percentage', routes: [GoRoute('history', ...)]),
              GoRoute('world-time', routes: [GoRoute('add', ...)]),
            ])
        ]),
        StatefulShellBranch(routes: [
          GoRoute('/home/calculator', routes: [GoRoute('history', ...)])
        ]),
        StatefulShellBranch(routes: [
          GoRoute('/home/settings', routes: [
            GoRoute('chat-history', ...),
            GoRoute('themes', ...),
          ])
        ]),
      ]
    ),
    GoRoute('/feedback', builder: (ctx, state) => FeedbackScreen(
      source: state.uri.queryParameters['source'],
    )),
  ],
)
```

### 11.2 Back Behavior

```dart
// Trong HomeShell:
PopScope(
  canPop: false,
  onPopInvoked: (didPop) {
    if (currentTabIndex != calculatorTabIndex) {
      shellNavigator.goBranch(calculatorTabIndex);
    } else {
      showExitConfirmationDialog();
    }
  },
)
```

### 11.3 Tab State Preservation

- Dùng `StatefulShellRoute` của go_router → mỗi branch giữ Navigator stack riêng.
- Input state giữ trong Cubit/Bloc tương ứng (không bị dispose khi chuyển tab).

---

## 12. Technical Architecture

### 12.1 Clean Architecture Layers

```
lib/
├── core/
│   ├── constants/          — app_constants.dart, route_paths.dart
│   ├── error/              — failures.dart, exceptions.dart
│   ├── usecase/            — usecase.dart (abstract base)
│   ├── utils/
│   │   ├── number_formatter.dart
│   │   ├── timezone_utils.dart
│   │   └── expression_validator.dart
│   └── theme/              — app_theme.dart, color_scheme.dart
│
├── features/
│   ├── calculator/
│   │   ├── domain/
│   │   │   ├── entities/calculator_history_item.dart
│   │   │   ├── repositories/i_calculator_history_repository.dart
│   │   │   └── usecases/evaluate_expression.dart
│   │   ├── data/
│   │   │   ├── models/calculator_history_model.dart
│   │   │   ├── repositories/calculator_history_repository_impl.dart
│   │   │   └── datasources/calculator_history_local_datasource.dart
│   │   └── presentation/
│   │       ├── bloc/calculator_bloc.dart
│   │       ├── screens/calculator_screen.dart
│   │       └── screens/calculator_history_screen.dart
│   │
│   ├── converter/
│   │   ├── currency/        — (tương tự structure)
│   │   ├── percentage/
│   │   └── world_time/
│   │
│   ├── settings/
│   └── ai_tutor/           — placeholder
│
├── shared/
│   ├── widgets/            — custom keyboard, snackbar helper, dialogs
│   ├── blocs/
│   │   ├── app_config/app_config_cubit.dart
│   │   ├── favorites/favorites_cubit.dart
│   │   └── theme/theme_cubit.dart
│   └── services/
│       ├── haptic_service.dart
│       └── wakelock_service.dart
│
├── app.dart                — MaterialApp + providers
└── main.dart
```

### 12.2 Dependency Injection

**Thư viện**: `get_it` + `injectable`.

```dart
// Singleton: AppConfigRepository, CurrencyRepository (với Dio)
// Factory: Use cases
// LazySingleton: Hive boxes
```

### 12.3 Key Packages

| Package | Mục đích |
|---|---|
| `flutter_bloc` | State management |
| `go_router` | Navigation |
| `get_it` + `injectable` | DI |
| `hive_flutter` | Local DB (history, cache, favorites) |
| `shared_preferences` | AppConfig key-value |
| `dio` | HTTP client cho Currency API |
| `timezone` | IANA timezone database (offline) |
| `intl` | Number/Date formatting, I18n — **hot-reload confirmed** |
| `flutter_localizations` | Delegate cho built-in widgets (DatePicker, etc.) |
| `wakelock_plus` | Always on screen |
| `battery_optimization_android` | Battery optimization check |
| `share_plus` | System share sheet |
| `url_launcher` | Mở link ngoài |
| `image_picker` | Feedback screen — attach screenshot |
| `path_provider` | File paths |
| `package_info_plus` | Feedback metadata — `app_version` |
| `device_info_plus` | Feedback metadata — `device_model`, `os_version` |
| `flutter_timezone` | Phát hiện đổi timezone hệ thống (World Time) |

### 12.4 I18n Strategy

**Confirmed**: Hot-reload dùng `intl` + `flutter_localizations` (không restart app).

- **ARB files**: `lib/l10n/app_en.arb`, `app_vi.arb`, ... — generate bởi `flutter gen-l10n`.
- **Không hardcode** bất kỳ string hiển thị nào — dùng `AppLocalizations.of(context).xxx`.
- **Khi đổi language**:
  1. `AppConfigCubit.setLanguage(locale)` → persist SharedPreferences → emit state mới.
  2. `MaterialApp.locale` bind với `AppConfigCubit` state → Flutter rebuild toàn bộ widget tree với locale mới.
  3. Không cần restart app, không cần Navigator.pop/push.
- **Package**: `intl` cho date/number formatting theo locale; `flutter_localizations` cho widget built-ins (DatePicker, etc.).
- City/Country names trong World Time: dùng `cityNameKey` tra `app_*.arb` — không hardcode tên thành phố.
- **Lưu ý**: Khi `language = "system"`, lấy `Platform.localeName` làm locale active.

---

## 13. Acceptance Criteria Coverage

### 13.1 Navigation & Shell

| Criterion | Covered by | Status |
|---|---|---|
| Default tab là Calculator | go_router `initialLocation` | ✅ |
| Back từ tab phụ → về Calculator | PopScope trong HomeShell | ✅ |
| Back tại Calculator → Exit dialog | PopScope + dialog | ✅ |
| Tab switch không mất input state | StatefulShellRoute + Cubit | ✅ |
| Tab switch ẩn bàn phím | FocusScope.unfocus() khi switch | ✅ |

### 13.2 Calculator

| Criterion | Covered by | Status |
|---|---|---|
| Real-time preview | CalculatorBloc preview evaluate | ✅ |
| Lưu history khi = | CalculatorHistoryRepository | ✅ |
| Không lưu khi invalid | CalculatorBloc error handling | ✅ |
| Auto-replace operator | CalculatorEngine validator | ✅ |
| Auto-close bracket | CalculatorEngine preprocess | ✅ |
| Draft persist | SharedPreferences + BlocObserver | ✅ |
| Draft xóa khi tab switch (setting off) | BlocObserver onTransition | ✅ |
| Rollback (undo) | Expression history stack trong Bloc | ✅ |
| Giới hạn 50 ký tự | CalculatorBloc guard | ✅ |
| Format theo Settings | NumberFormatter reactive | ✅ |
| DEG/RAD/GRA indicator | Hiện khi có trig func trong expression | ✅ |
| Scientific → về Basic sau insert | CalculatorBloc state | ✅ |

### 13.3 Currency Converter

| Criterion | Covered by | Status |
|---|---|---|
| Cache TTL 1h | CurrencyRepository timestamp check | ✅ (A3) |
| Auto-fetch khi hết cache | CurrencyConverterBloc.init() | ✅ |
| Offline + có cache: hiển thị cảnh báo | CurrencyLoadedOffline state | ✅ |
| Offline + không cache: màn hình lỗi + Retry | CurrencyError state | ✅ |
| Simple/Advanced mode switch | CurrencyConverterBloc | ✅ |
| Real-time calc tất cả ô | CurrencyConverterBloc.onInputChanged | ✅ |
| Caution dialog chỉ khi tap menu (không auto) | CurrencyConverterBloc on menu tap | ✅ C10 |
| History restore | CurrencyHistoryRepository + Cubit | ✅ |
| Swap currencies (Simple mode) | CurrencyConverterBloc.swap() | ✅ |
| Focus navigation (Advanced mode) | CurrencyConverterBloc.focusNext() | ✅ |

### 13.4 Percentage Calculator

| Criterion | Covered by | Status |
|---|---|---|
| Bi-directional calc | PercentageCubit formula engine | ✅ |
| Mode switch giữ state riêng | PercentageCubit modeOneState/modeTwoState | ✅ |
| Trường rỗng không báo lỗi | PercentageCubit: result = '' nếu input incomplete | ✅ |
| Max 3 decimal Percentage | Input validator | ✅ |
| Max 6 decimal các trường khác | Input validator | ✅ |
| History restore | PercentageHistoryRepository | ✅ |

### 13.5 World Time

| Criterion | Covered by | Status |
|---|---|---|
| Device timezone ghim đầu, không xóa được | WorldTimeCubit guard | ✅ |
| DST label + offset đúng | `timezone` package | ✅ |
| Không thêm trùng lặp | WorldTimeCubit check by timezoneId | ✅ |
| Sort giữ device card ở đầu | WorldTimeCubit sort logic | ✅ |
| Reference mode dừng live timer | WorldTimeCubit.setReferenceTime() | ✅ |
| Quay về live mode | WorldTimeCubit.clearReferenceTime() | ✅ |
| Cơ chế quay về Now trực quan | Nút `Now` ở header + indicator banner mỏng | ✅ |
| Long-press card → Edit Mode | WorldTimeCubit.enterEditMode() (trừ device card = no-op) | ✅ |
| World Time KHÔNG lưu history | Loại WorldTimeHistory model | ✅ C14 |
| Bottom Bar World Time KHÔNG có icon Calculator | UI guard | ✅ C17 |
| OS timezone change detection | App lifecycle + flutter_timezone | ✅ |
| Day boundary +1/-1 | DateTime arithmetic | ✅ |
| Tên trùng hiển thị kèm vùng | WorldTimeCity.displayName full | ✅ |
| Offline hoàn toàn | `timezone` package bundle local | ✅ |

### 13.6 Settings

| Criterion | Covered by | Status |
|---|---|---|
| Instant apply tất cả config | AppConfigCubit global + reactive | ✅ |
| Number Format re-render toàn app | BlocListener trên mỗi màn hình | ✅ |
| Battery Optimization Android only | Platform.isAndroid guard | ✅ |
| Battery Opt ẩn khi đã cấp quyền | Check on resume | ✅ |
| Ẩn link khi URL rỗng | Conditional render | ✅ |
| Clear Chat History có confirm | AlertDialog trước khi xóa | ✅ |
| Themes | ThemesCubit (scope TBD) | ⚠️ A1 |

---

## 14. Implementation Roadmap

### Phase 0 — Foundation (1–2 ngày)

**Mục tiêu**: Project scaffold đầy đủ, không có logic nghiệp vụ.

- [ ] Khởi tạo Flutter project, cấu hình `pubspec.yaml` với tất cả packages
- [ ] Thiết lập Clean Architecture folder structure
- [ ] Cấu hình `get_it` + `injectable` DI
- [ ] Cấu hình `go_router` với tất cả routes (màn hình placeholder)
- [ ] Cấu hình `hive_flutter`: khởi tạo boxes, register adapters
- [ ] Cài đặt I18n: ARB files (EN + VI), `flutter_gen` cho localization
- [ ] Implement `AppTheme` (Light/Dark), cấu hình `MaterialApp`
- [ ] Implement `AppConfigCubit` + `AppConfigRepository` (SharedPreferences)
- [ ] Implement `NumberFormatter` utility class với unit tests

### Phase 1 — Shell + Settings (2–3 ngày)

**Mục tiêu**: App chạy được với navigation và settings hoạt động.

- [ ] HomeShell với Bottom Navigation 4 tab
- [ ] Tab state preservation (StatefulShellRoute)
- [ ] Back behavior (PopScope) — về Calculator tab + Exit dialog
- [ ] Settings screen đầy đủ:
  - System Settings: tất cả Picker + Toggle
  - DEVELOPER SETTINGS: links, App Version
  - Battery Optimization (Android)
- [ ] `ThemesCubit`: Light/Dark toggle
- [ ] Reactive language switch

### Phase 2 — Calculator (3–4 ngày)

**Mục tiêu**: Calculator hoạt động hoàn chỉnh.

- [ ] `CalculatorEngine`: Tokenizer → Shunting-Yard → Evaluator
  - Phép toán cơ bản + ngoặc
  - Hàm khoa học (trig, log, root, hyperbolic)
  - Hằng số (π, e, φ)
  - AngleMode (DEG/RAD/GRA)
  - Error handling (div/0, sqrt(-x), overflow, NaN)
- [ ] `CalculatorBloc`: expression state, preview, `=` handling
  - Auto-replace operator
  - Auto-close bracket
  - Rollback stack
  - Giới hạn 50 ký tự
- [ ] Basic Keyboard widget (7×4)
- [ ] Scientific Keyboard widget (7×4) + auto-switch behavior
- [ ] Display Panel (expression, preview, angle indicator, history preview)
- [ ] `CalculatorHistoryRepository` (Hive)
- [ ] History Screen (restore, share, delete)
- [ ] Draft persistence (keep calculator record)
- [ ] Unit tests: CalculatorEngine (ít nhất 30 test cases)

### Phase 3 — Converter List + Favorites (1–2 ngày)

**Mục tiêu**: Màn hình Converter List hoạt động.

- [ ] `ConverterListCubit`: search (debounce), filter, categories
- [ ] `FavoritesCubit` + `FavoritesRepository` (Hive)
- [ ] Favorites Grid (4 cột)
- [ ] Manage Favorites mode (+/× buttons)
- [ ] Search empty state
- [ ] Category list với các groups: Convert, Consume, Health, Money

### Phase 4 — Currency Converter (3–4 ngày)

**Mục tiêu**: Currency Converter hoàn chỉnh online + offline.

- [ ] `CurrencyRepository`: Dio HTTP client, cache Hive
- [ ] `CurrencyConverterBloc`: Simple/Advanced mode, real-time calc, focus management
- [ ] Currency Picker Screen (search, select)
- [ ] Custom numeric keyboard (4×4) — Converter variant
- [ ] Simple mode UI (2 rows + reference line)
- [ ] Advanced mode UI (4 rows card)
- [ ] Offline states (với cache / không cache)
- [ ] Caution dialog (first time flag)
- [ ] Share dialog
- [ ] Add Shortcut dialog (Launcher Shortcut API)
- [ ] `CurrencyHistoryRepository` + History Screen
- [ ] Footer "Rates as of..."

### Phase 5 — Percentage Calculator (2–3 ngày)

**Mục tiêu**: Percentage Calculator hoàn chỉnh.

- [ ] `PercentageCubit`: bi-directional formula engine
  - Mode 1: Result = Number × Percentage / 100
  - Mode 2: Change = Initial × Percentage / 100; Final = Initial ± Change
  - State preservation khi switch mode
- [ ] Form UI: Mode 1 (3 fields) + Mode 2 (4 fields)
- [ ] Custom keyboard 5 rows × 4 cols
- [ ] Advanced Calculator overlay (popup)
- [ ] Calculation Formula dialog
- [ ] `PercentageHistoryRepository` + History Screen
- [ ] Share dialog

### Phase 6 — World Time Converter (3–4 ngày)

**Mục tiêu**: World Time hoàn chỉnh với DST và reference mode.

- [ ] Integrate `timezone` package + IANA tzdata
- [ ] `WorldTimeCubit`: live timer, reference mode, sort, edit mode
- [ ] City list với Device Timezone card ghim
- [ ] Add City Screen (search, filter by name/country)
- [ ] Edit Reference Time Dialog (Date Picker + Time Picker wheels)
- [ ] "Return to live" banner khi đang ở reference mode
- [ ] Sort menu (name A→Z, Z→A, GMT ↑↓)
- [ ] Edit mode (checkbox + delete)
- [ ] DST label + correct offset calculation
- [ ] OS timezone change detection (App lifecycle)
- [ ] Share modal
- [ ] Persistence (Hive)

### Phase 7 — Cross-cutting Concerns (2–3 ngày)

**Mục tiêu**: Hoàn thiện các tính năng xuyên suốt.

- [ ] `HapticService`: rung khi bấm phím (theo `vibrationEnabled`)
- [ ] `SoundService`: âm thanh khi bấm phím (theo `soundEnabled`)
- [ ] `WakelockService`: giữ màn hình sáng (theo `alwaysOnScreen`)
- [ ] Feedback Screen (dropdown, single-select preset issues, textarea, image attach, Submit → mailto)
- [ ] Offline submit: Snackbar lỗi "không có kết nối", **không queue** (per C11)
- [ ] Error UX: Snackbar helper, global error handler
- [ ] App Widget (Android) — placeholder hoặc basic
- [ ] Notification Shortcut
- [ ] Launcher Shortcut

### Phase 8 — AI Tutor Placeholder + Chat Settings (1 ngày)

- [ ] AI Tutor tab: UI placeholder
- [ ] Chat History screen (empty state + danh sách)
- [ ] Clear Chat History (confirm dialog, Hive clear)

### Phase 9 — QA & Polish (3–5 ngày)

- [ ] Unit tests: tất cả engine, formatter, repository
- [ ] Widget tests: key screens
- [ ] Integration test: happy path flows
- [ ] Accessibility: content descriptions, contrast check
- [ ] Performance: scroll lists, debounce check, animation 60fps
- [ ] Edge cases: offline, OS timezone change, rapid toggle, large numbers
- [ ] Localization review (EN/VI)
- [ ] Build release APK + IPA

---

## 15. Dev Handoff Checklist

### Trước khi bắt đầu code từng feature

- [ ] Đọc file `feature_*.md` tương ứng — đây là source of truth chi tiết nhất
- [ ] Đọc UI notes trong `ui_notes.md` cho design tokens (màu, typography)
- [ ] Kiểm tra Open Questions liên quan — không tự assume thêm
- [ ] Xác nhận data model trong `architecture.md` trước khi viết Hive model

### Conventions

- Tên biến/hàm: `camelCase`
- Tên class/widget: `PascalCase`
- Hằng số: `UPPER_SNAKE_CASE`
- Không hardcode string hiển thị — dùng `AppLocalizations`
- Mọi số hiển thị phải qua `NumberFormatter.format()`
- Mọi async I/O phải có try-catch → map sang `Failure`

### Testing Requirements

- `CalculatorEngine`: ≥ 30 unit tests (bao gồm edge cases chia 0, overflow, trig)
- `NumberFormatter`: ≥ 20 unit tests (tất cả format combinations)
- `PercentageCubit formula engine`: ≥ 15 unit tests
- `CurrencyRepository cache logic`: ≥ 10 unit tests
- `WorldTimeCubit DST + reference mode`: ≥ 10 unit tests

---

## 16. Recommended File Implementation Order

```
1.  core/utils/number_formatter.dart            ← dùng khắp nơi, test trước
2.  core/utils/expression_validator.dart
3.  shared/blocs/app_config/                    ← global state
4.  shared/blocs/theme/
5.  app.dart + main.dart + go_router config
6.  features/settings/                          ← test reactive settings sớm
7.  features/calculator/domain/ (engine)        ← logic phức tạp nhất
8.  features/calculator/data/
9.  features/calculator/presentation/
10. features/converter/ (list + favorites)
11. features/converter/currency/
12. features/converter/percentage/
13. features/converter/world_time/
14. shared/widgets/ (keyboard, dialogs, snackbar)
15. shared/services/ (haptic, sound, wakelock)
16. features/settings/feedback/
17. features/ai_tutor/ (placeholder)
18. Phase 7 cross-cutting (widget, notification, shortcut)
19. QA pass
```

---

## 17. Open Questions (Cần xác nhận trước khi implement)

| # | Câu hỏi | Block feature | Priority |
|---|---|---|---|
| OQ1 | ✅ Themes: không IAP — placeholder Light/Dark + `ThemesScreen` | Settings Phase 1 | Closed |
| OQ2 | Startup Calculator: danh sách option đầy đủ? | Settings Phase 1 | 🟡 Medium |
| OQ3 | App Widget: nội dung, kích thước? | Phase 7 | 🟡 Medium |
| OQ4 | Notification Shortcut: dẫn tới tính năng nào? | Phase 7 | 🟡 Medium |
| OQ5 | ✅ Đổi ngôn ngữ: hot-reload `intl` + `flutter_localizations` | Phase 1 | Closed |
| OQ6 | ✅ Đồng bộ đa thiết bị: **out of scope MVP** | — | Closed |
| OQ7 | Xóa chat history theo khoảng thời gian? | Phase 8 | 🟢 Low |
| OQ8 | ✅ Currency API endpoint: team cung cấp | Phase 4 | Closed |
| OQ9 | ✅ Feedback submit = **mailto** (per C12) — không cần endpoint | — | Closed |
| OQ10 | Help link URL? | Phase 1 Settings | 🟡 Medium |
| OQ11 | Email đích mailto Feedback? | Phase 7 | 🔴 High |
| OQ12 | List preset Feedback issues đầy đủ (nội dung từng item) | Phase 7 | 🔴 High |
| OQ13 | Percentage History commit timing (khi nào trigger ghi) | Phase 5 | 🟡 Medium |
