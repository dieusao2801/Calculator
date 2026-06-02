# Calculator AI — Design Plan (Master Document)

> **Version**: 2.0 · 2026-06-02
> **Platform**: Flutter · Android & iOS (Mobile-first)
> **Pattern**: MVVM + Repository trên Clean Architecture 3 tầng
> **State**: `flutter_bloc` (Cubit/Bloc làm ViewModel)
> **Navigation**: `go_router` v14+ với `StatefulShellRoute`
> **Storage**: `SharedPreferences` (AppConfig) + `Hive` (history/cache/favorites)

Tài liệu **tổng hợp** từ 13 file đặc tả riêng — dùng làm checkpoint baseline `spec-v1.0` cho dev/AI khác implement bám spec.

---

## Mục lục

1. [Executive Summary](#1-executive-summary)
2. [Document Source-of-Truth](#2-document-source-of-truth)
3. [Spec Confirmed / Assumptions / Open Questions](#3-spec-confirmed--assumptions--open-questions)
4. [Product Structure](#4-product-structure)
5. [End-to-End Flows](#5-end-to-end-flows)
6. [Feature-by-Feature Design](#6-feature-by-feature-design)
7. [Screen Design Summary](#7-screen-design-summary)
8. [Domain / Data Design](#8-domain--data-design)
9. [Engine & Conversion Logic](#9-engine--conversion-logic)
10. [State Management](#10-state-management)
11. [Navigation](#11-navigation)
12. [Permissions](#12-permissions)
13. [Technical Architecture](#13-technical-architecture)
14. [Acceptance Criteria Coverage](#14-acceptance-criteria-coverage)
15. [Implementation Roadmap](#15-implementation-roadmap)
16. [Dev Handoff Checklist](#16-dev-handoff-checklist)
17. [Recommended File Implementation Order](#17-recommended-file-implementation-order)
18. [Open Questions](#18-open-questions)

---

## 1. Executive Summary

Calculator AI là **Flutter mobile app (Android + iOS)** offline-first, đơn người dùng, không tài khoản. Gồm 4 tab: **AI Tutor** (placeholder), **Converter** (Currency / Percentage / World Time), **Calculator (default)**, **Settings**.

### Đặc điểm cốt lõi
- **Offline 100%** trừ Currency refresh (cache 1h).
- **Đa ngôn ngữ** hot-reload qua `intl + flutter_localizations`.
- **Reactive Settings**: `numberFormat / decimalDigits / language` re-render tức thì toàn app.
- **Đơn người dùng**: không backend, không sync, không đăng nhập.

### Điểm nóng kiến trúc
| # | Hạng mục | Giải pháp |
|---|---|---|
| 1 | Calculator Engine (parse infix → RPN, DEG/RAD/GRA) | Custom Tokenizer → Shunting-Yard → Evaluator |
| 2 | Currency cache + API + offline | Hive TTL 1h + fallback cache + Dio |
| 3 | Percentage bidirectional (tính ngược từ field bất kỳ) | Custom formula engine + 2-slot modified queue |
| 4 | World Time DST + Reference Mode | `timezone` package + `flutter_timezone` resume detect |
| 5 | Calculator Overlay shared (Currency + Percentage) | Semi-modal dialog với dynamic title = field name |
| 6 | Reactive Settings | `AppConfigCubit` global + `BlocSelector` |

### Trạng thái baseline
**Sẵn sàng Phase 0 (Foundation)** sau khi đóng 3 Open Questions 🔴: email mailto đích (OQ1), list preset Feedback issues (OQ2), Currency API endpoint (OQ10).

---

## 2. Document Source-of-Truth

### 2.1 Bộ tài liệu hoàn chỉnh (13 file)

| File | Vai trò |
|---|---|
| `CLAUDE.md` | Coding guidelines, platform target, kiến trúc gọn |
| `feature_spec.md` | Đặc tả tổng quan tất cả tính năng |
| `architecture.md` | Cấu trúc thư mục, data models, ngưỡng scientific |
| `ui_notes.md` | Design tokens, keyboard layouts, Share template per tool |
| `navigation_flow.md` | Route map, back stack, deep links, tab preservation |
| `permission_system_flow.md` | Permission Android/iOS, rationale, fallback |
| `feature_calculator.md` | Calculator chi tiết (Basic + Scientific + History) |
| `feature_converter.md` | Converter List + Currency Converter + Feedback Screen |
| `feature_percentage_calculator_screen.md` | Percentage Calculator chi tiết |
| `feature_world_time.md` | World Time Converter chi tiết |
| `feature_setting.md` | Settings chi tiết (System + Chat + Developer) |
| `technical_design.md` | Technical design + roadmap chi tiết |
| `solution_architecture_review.md` | Cross-cutting review + AC coverage |

### 2.2 Quy ước ưu tiên khi xung đột

`feature_*.md` (chi tiết) **>** `feature_spec.md` (tổng quan) **>** `architecture.md` **>** `technical_design.md` (kỹ thuật) **>** `ui_notes.md` (UI tokens).
Khi conflict với acceptance criteria đã confirmed → giữ AC.

---

## 3. Spec Confirmed / Assumptions / Open Questions

### 3.1 Confirmed (25 quyết định đã đóng)

| # | Hạng mục | Quyết định |
|---|---|---|
| C1 | Bottom Nav tab thứ 1 | AI Tutor (không phải Recent) |
| C2 | Default tab | Calculator |
| C3 | Framework | Flutter only |
| C4 | State management | flutter_bloc (Cubit/Bloc) làm ViewModel trong MVVM |
| C5 | Nhóm Settings thứ 3 | **DEVELOPER SETTINGS** |
| C6 | Nhãn Rating | **Rate us 5 stars** |
| C7 | Keep Calculator Record clear time | Cả thoát app **và** chuyển tab |
| C8 | Percentage keypad | **5 rows × 4 cols** |
| C9 | Scientific keyboard hàng 2 | Không có DEG/RAD/GRA; cycle qua tap nhãn header; `rand` 1 ô riêng; dec/hex/bin out of scope |
| C10 | Favorites sort | Theo addedOrder; không drag-drop; không giới hạn số lượng |
| C11 | World Time format | 24h cố định |
| C12 | Chat Settings vị trí | Trong Tab Settings |
| C13 | Currency Caution Dialog | Chỉ khi tap menu (không auto lần đầu) |
| C14 | Feedback offline submit | Báo lỗi Snackbar, không queue |
| C15 | Feedback backend | mailto deep-link |
| C16 | Calculator Overlay | Shared Currency + Percentage; ẨN ở World Time; title = field name |
| C17 | World Time History | Bỏ hoàn toàn MVP |
| C18 | Ads / dec/hex/bin / IAP Themes | Out of scope MVP |
| C19 | Scientific notation threshold | `|x| ≥ 1e15` hoặc `0 < |x| < 1e-6` |
| C20 | History capacity | 100 FIFO (Calculator / Currency / Percentage) |
| C21 | Hot-reload language | `intl` + `flutter_localizations` qua `MaterialApp.locale` |
| C22 | Đồng bộ đa thiết bị | Out of scope MVP |
| C23 | Add Shortcut | Android only |
| C24 | Simple→Advanced fallback currencies | USD → JPY → AUD → CAD |
| C25 | Reference Mode persistence | Giữ qua app restart |

### 3.2 Assumption (đang dùng làm baseline)

| # | Assumption | Risk |
|---|---|---|
| A1 | Currency cache TTL = 1 giờ | Thấp |
| A2 | Calculator expression max 50 ký tự (UI cap) | Thấp |
| A3 | `favoriteCurrency` auto-update theo FROM cuối | Thấp |
| A4 | Help → link web ngoài (ẩn khi rỗng) | Trung |
| A5 | App Widget = ô nhập nhanh Basic | **Cao** |
| A6 | Notification Shortcut = mở Calculator | **Cao** |
| A7 | Themes Light/Dark only MVP, không IAP | Thấp |
| A8 | Email mailto đích `support@tohsoft.com` | **Cao** |
| A9 | List Feedback issues 6 items mẫu | **Cao** |
| A10 | Percentage History commit khi Share/toggle/back | Trung |
| A11 | Currency flag từ asset bundle local | Thấp |

### 3.3 Open Questions còn lại (cần stakeholder)

| # | Câu hỏi | Block Phase | Priority |
|---|---|---|---|
| OQ1 | Email mailto đích | Phase 7 | 🔴 |
| OQ2 | List preset Feedback issues đầy đủ | Phase 7 | 🔴 |
| OQ10 | Currency API endpoint + auth | Phase 4 | 🔴 |
| OQ5 | Help link URL | Phase 1 | 🟡 |
| OQ6 | Startup Calculator options đầy đủ | Phase 1 | 🟡 |
| OQ7 | App Widget nội dung + kích thước | Phase 7 | 🟡 |
| OQ8 | Notification Shortcut dẫn tới đâu | Phase 7 | 🟡 |
| OQ9 | Launcher Shortcut scope | Phase 7 | 🟡 |
| OQ11 | Percentage History commit timing xác nhận | Phase 5 | 🟢 |
| OQ12 | Chat History xoá theo khoảng thời gian | Phase 8 | 🟢 |

---

## 4. Product Structure

```
Calculator AI (Flutter)
└── Splash
    └── HomeShell (StatefulShellRoute — Bottom Nav 4 tab)
        ├── [0] AI Tutor                 placeholder
        ├── [1] Converter
        │   ├── ConverterList            search + Favorites grid + categories
        │   ├── Currency Converter       Simple/Advanced + History
        │   │   ├── History
        │   │   └── Calculator Overlay (shared)
        │   ├── Percentage Calculator    Mode 1/2 + History
        │   │   ├── History
        │   │   └── Calculator Overlay (shared)
        │   └── World Time Converter     Now/Reference mode + Add City
        │       └── Add City
        ├── [2] Calculator (default)
        │   └── History
        └── [3] Settings
            ├── Themes                   Light/Dark placeholder
            ├── Chat History             AI Tutor logs
            └── Feedback (route shared)  từ menu mọi tool
```

**Categories Converter List**: `Converter / Consume / Health / Money`.
**Default tab**: Calculator. **Back**: tab khác → về Calculator; tại Calculator → Exit dialog.

---

## 5. End-to-End Flows

### 5.1 App Startup
```
Splash
  ↓ Load AppConfig (SharedPreferences)
  ↓ Init Hive boxes (lazy)
  ↓ Provide global Cubits: AppConfigCubit, FavoritesCubit, ThemesCubit
  ↓ Check Battery Optimization (Android only)
  → HomeShell @ tab Calculator
     → CalculatorCubit: load draft nếu keepCalculatorRecord
     → CurrencyConverterCubit defer init
     → WorldTimeCubit defer init
```

### 5.2 Settings Change Propagation
```
User toggle/picker change
  → AppConfigCubit.update(field)
  → persist SharedPreferences → emit state mới
  ⤵ subscribers rebuild qua BlocSelector:
     • Calculator: re-format result (raw → format mới)
     • Currency: re-format values
     • Percentage: re-format fields
     • World Time: re-format display time
     • MaterialApp.locale: rebuild tree với language mới
```

### 5.3 Currency Flow
```
Mở Currency Converter
  → check Hive cache → timestamp < 1h?
     ✓ Loaded(fromCache=true)
     ✗ fetch API
        ✓ thành công → cache + Loaded(fromCache=false)
        ✗ có cache cũ → LoadedOffline(staleCache)
        ✗ không cache → Error(retryable=true)

Refresh thủ công → bypass TTL → fetch
Nhập số ô A → cascade tính tất cả ô khác đồng bộ
```

### 5.4 Calculator Flow
```
KeyPress(key)
  → Engine.append(key, currentExpression)
     → Tokenize → Validate (auto-replace operator, length cap)
     → Preview evaluate (nếu hợp lệ)
  → emit state(expression, previewResult, angleMode)

Nhấn =
  → Engine.evaluate(expression, angleMode)
     ✓ NumericResult(raw, display)
        → HistoryRepo.add (push, evict nếu > 100)
        → emit result trên Expression Line
     ✗ Error(InvalidSyntax | OutOfRange)
        → Snackbar event, không lưu history
```

### 5.5 Percentage Bidirectional
```
onFieldChanged(field, value)
  → modifiedFieldsQueue.push(field)    // FIFO 2 slots
  → resolve formula:
     • Mode 1: đủ 2/3 field → solve thứ 3
     • Mode 2: Initial + 1 field khác → solve còn lại
     • Conflict (3+ filled, vừa sửa 1) → keep 2 modified gần nhất, recompute còn lại
  → emit derived fields (flag isDerived)

Toggle +/− (Mode 2)
  → flip sign → recompute Change & Final
  → KHÔNG commit History

Commit History trigger:
  • Share menu
  • Toggle mode % ↔ ±%
  • Rời màn
```

### 5.6 World Time Reference Mode
```
Now Mode (default):
  Timer 1s → emit cities với T = DateTime.now()

Tap card C:
  → SetReferenceTimeDialog(city: C)
  → OK → setReference(city, refTime)
     → cancel timer
     → for each city: T = T_ref + (offset_target − offset_ref) DST-aware
     → emit ReferenceMode + header banner + nút `Now`

Tap nút Now (header):
  → clearReference() → restart timer

App resume:
  → check OS timezone diff → update device card
  → re-evaluate DST cho mọi city
```

### 5.7 Feedback (mailto)
```
Mở Feedback (từ menu tool)
  → FeedbackCubit.init(context: toolId)
  → dropdown auto = toolId

Submit
  → validate (≥1 issue OR Other text)
  → online?
     ✓ build mailto URI:
        to: <support_email> (OQ1)
        subject: [Calculator AI] Feedback - {feature}
        body: issue + other + metadata (app_version, os, device, language)
        attachment: ảnh (nếu platform hỗ trợ)
        → url_launcher.launchUrl(uri)
     ✗ Snackbar "Không có kết nối" → không queue
```

---

## 6. Feature-by-Feature Design

### 6.1 Calculator

| Aspect | Design |
|---|---|
| ViewModel | `CalculatorBloc` (event-driven) |
| State | `expression, previewResult, angleMode, isScientific, showAngleIndicator, rollbackStack, historyPreview` |
| Engine | Tokenizer → Validator → Shunting-Yard → Evaluator → NumberFormatter |
| Keypad Basic | 7×4 — `^`, `x²`, `↺`, `±`, `%`, `1/x`, `⌫`, `C`, `()`, `000`, `÷×−+=`, số |
| Keypad Scientific | 7×4 — `fx` toggle, `π e φ`, `rand`, `eˣ 10ˣ √ ∛`, `log ln |x| !`, lượng giác + nghịch + hyperbolic |
| Angle mode | Tap nhãn header cycle DEG → RAD → GRA; chỉ hiện khi có lượng giác |
| Long-press `()` | Bao toàn bộ expression |
| Limits | Expression 50 ký tự (UI cap); decimal 10 chữ số/số |
| Draft | SharedPreferences khi `keepCalculatorRecord` bật; clear khi tắt + rời tab/exit |
| History | Hive `calculator_history` cap 100 FIFO; lưu `{expression, resultRaw, resultDisplay, angleMode, timestamp}` |
| Error | InvalidSyntax → Snackbar; OutOfRange (NaN/Inf, div/0, sqrt(-x)) → Snackbar |
| Scientific notation | `|x| ≥ 1e15` hoặc `0 < |x| < 1e-6` |

### 6.2 Currency Converter

| Aspect | Design |
|---|---|
| ViewModel | `CurrencyConverterBloc` |
| State | `mode (simple/advanced), currencies[], values[], focusedIndex, rateData, loadStatus, lastUpdated` |
| Modes | Simple (1 cặp + footer rate) / Advanced (4 hàng, ẩn footer) |
| Toggle Simple→Advanced | Fill default EUR, GBP; nếu trùng → fallback USD → JPY → AUD → CAD |
| Conversion | Normalize qua USD base: `value_B = value_A × rate_B / rate_A` |
| Keypad | 4×4 — số, `.`/`,`, `⌫`, `↓↑` swap (Simple) / `↓` next focus (Advanced), `±=` Overlay, `C` |
| Cache | Hive `currency_cache` TTL 1h; manual refresh bypass; offline + cache vẫn chạy |
| Menu | Add Shortcut (Android) · Favorite · Refresh · Simple/Advanced · History · Share · Caution · Help · Feedback · Settings |
| Caution | CHỈ khi tap menu (không auto lần đầu) |
| Picker | Bottom-sheet RadioGroup, sort A→Z theo localized name; search match localized + English + ISO; flag từ asset local |
| History | Hive `currency_history` cap 100 FIFO; lưu `{mode, currencyList[], inputValue, outputValues, rateTimestamp, timestamp}` |

### 6.3 Percentage Calculator

| Aspect | Design |
|---|---|
| ViewModel | `PercentageCubit` |
| State | `mode (percentOfNumber/percentChange), fields{}, signIsPositive, focusedField, modifiedFieldsQueue (FIFO 2), modeState{}` |
| Modes | `%` (3 fields: Number, Percentage, Result) / `±%` (4 fields: Initial Value, Percentage, Change, Final Value) |
| Bidirectional | Mode 1: cần ≥ 2/3; Mode 2: cần Initial + 1 khác |
| Conflict | Field vừa sửa ưu tiên + 1 field sửa trước đó; recompute còn lại |
| Decimal cap | Percentage 3 dp; field khác 6 dp |
| Sign | Luôn hiện `+/−` explicit ở Mode 2; phím `+/−` disable ở Mode 1 |
| Keypad | 5×4 — `C/←/→/⌫`, số, `↓↑` swap (Number⇄Result hoặc Initial⇄Final), `±=` Overlay, `−/+` sign |
| Cho phép | `Percentage > 100%` hoặc `< −100%` |
| Calculation Formula Dialog | Info-only, đóng bằng Cancel/Close |
| History | Hive `percentage_history` cap 100 FIFO; lưu `{mode, numberVal?, percentageVal, signIsPositive, changeVal?, resultVal?, initialVal?, finalVal?, timestamp}` |
| Commit trigger | Share / toggle mode (form hợp lệ) / rời màn |

### 6.4 World Time Converter

| Aspect | Design |
|---|---|
| ViewModel | `WorldTimeCubit` |
| State | `cities[], referenceCity?, referenceTime?, sortCriteria, sortAscending, isEditMode, selectedForDelete{}` + getter `isReferenceMode` |
| Modes | Now (timer 1s) / Reference (anchor = card tap) |
| Reference indicator | Banner mỏng dưới header `Reference: HH:mm — <CityName>` + nút `Now` |
| DST | `timezone` package; offset từ `tz.TZDateTime`; suffix `(DST)` cố định không localize |
| OS TZ change | `flutter_timezone` check on resume |
| Device card | Always pinned top, không xoá; long-press = no-op |
| Add City | Full-screen modal; search match localized + English; sort A→Z localized; flag từ asset |
| Set Time Dialog | GMT badge read-only; Date Picker year range ±100; Time Picker 24h; CANCEL/OK |
| Edit Mode | Vào qua menu hoặc long-press user card; tap card toggle checkbox; delete confirm |
| Sort | Bottom-sheet 4 options (Name A↑/↓, Time ↑/↓); device card luôn top |
| Bottom Bar | **KHÔNG có icon Calculator** (đã ẩn) |
| Persistence | Hive `world_time_state` (selectedCityIds[], referenceCity?, referenceTimeMs?, sort) |
| History | **Không có** |

### 6.5 Settings

| Aspect | Design |
|---|---|
| ViewModel | `AppConfigCubit` (global) + `SettingsCubit` (local) |
| Quick action header | Themes (placeholder Light/Dark) + Help (link URL — OQ5) |
| System group | Language, Startup Calculator, Measurement Unit, Number Format, Decimal Digits (0–10, default 2), Vibration, Sound, Always On Screen, Keep Calculator Record, Battery Optimization (Android, ẩn khi exempt), App Widget / Notification / Launcher Shortcut (MVP placeholder) |
| Chat group | Chat History, Clear Chat History (confirm, không undo) |
| Developer group | Privacy, Report Problem (→ Feedback), Rate us 5 stars, Share, More Apps, App Version (`v2.1.0 (build 412)`) |
| Instant apply | Mỗi update → persist + emit; subscribers rebuild |
| Hidden items | Ẩn URL row khi `AppConfig.<url>` null/empty |
| Battery Opt recheck | On app resume |

### 6.6 Feedback (shared)

| Aspect | Design |
|---|---|
| Route | `/feedback?source=<toolId>` (ngoài shell) |
| ViewModel | `FeedbackCubit` |
| State | `context, selectedIssue?, otherText, imagePath?` |
| Submit | Build `mailto:` URI → `url_launcher` → email client |
| Metadata | `package_info_plus` (app_version) + `device_info_plus` (os_version, device_model) + language + locale |
| Offline | Snackbar lỗi, không queue |
| Validate | ≥ 1 issue OR Other text non-empty |
| Image attach | Max 1 ảnh (camera / gallery); permission xem §12 |

### 6.7 Calculator Overlay (shared component)

| Aspect | Design |
|---|---|
| Component | `CalculatorOverlayDialog(fieldName, initialValue, onResult)` |
| UI | Semi-modal dialog đè màn dưới; Display nhỏ + Basic Keyboard |
| Title | Dynamic = `fieldName` (vd `Initial Value`, `Number`, `FROM CURRENCY`) |
| Result | Tap `=` hoặc đóng → callback `onResult(value)` inject vào field cha |
| History | KHÔNG lưu vào Calculator History |
| Usage | Currency keypad `±=` + Percentage keypad `±=`; World Time KHÔNG dùng |

---

## 7. Screen Design Summary

| Screen | Route | ViewModel(s) | Persistent State |
|---|---|---|---|
| Splash | `/splash` | AppConfigCubit (init) | AppConfig |
| HomeShell | `/home` | HomeShellCubit | tabIndex |
| AI Tutor | `/home/ai-tutor` | (placeholder) | — |
| Converter List | `/home/converter` | ConverterListCubit, FavoritesCubit | favorites[] |
| Currency Converter | `/home/converter/currency` | CurrencyConverterBloc | last currencies, cache |
| Currency History | `/home/converter/currency/history` | CurrencyHistoryCubit | history[] (cap 100) |
| Percentage Calculator | `/home/converter/percentage` | PercentageCubit | last mode + state |
| Percentage History | `/home/converter/percentage/history` | PercentageHistoryCubit | history[] (cap 100) |
| World Time | `/home/converter/world-time` | WorldTimeCubit | state (cities, ref, sort) |
| Add City | `/home/converter/world-time/add` | WorldTimeCubit (shared) | — |
| Calculator | `/home/calculator` | CalculatorBloc | draft expression |
| Calculator History | `/home/calculator/history` | CalculatorHistoryCubit | history[] (cap 100) |
| Settings | `/home/settings` | AppConfigCubit, SettingsCubit | AppConfig |
| Themes | `/home/settings/themes` | ThemesCubit | theme |
| Chat History | `/home/settings/chat-history` | ChatHistoryCubit | chat[] |
| Feedback | `/feedback?source=<toolId>` | FeedbackCubit | — |

---

## 8. Domain / Data Design

### 8.1 Domain Entities

`AppConfig` · `ConverterTool` · `FavoriteItem` · `CurrencyRate` · `CurrencyHistoryItem` · `PercentageHistoryItem` · `WorldTimeCity` · `WorldTimeState` · `CityTimeEntry` (runtime) · `CalculatorHistoryItem` · `FeedbackPayload` (transient).

### 8.2 Repository Interfaces

| Repository | Storage | Cap / TTL |
|---|---|---|
| `IAppConfigRepository` | SharedPreferences | — |
| `ICurrencyRepository` | Hive `currency_cache` + Dio | 1h soft TTL |
| `ICalculatorHistoryRepository` | Hive `calculator_history` | 100 FIFO |
| `ICurrencyHistoryRepository` | Hive `currency_history` | 100 FIFO |
| `IPercentageHistoryRepository` | Hive `percentage_history` | 100 FIFO |
| `IWorldTimeRepository` | Hive `world_time_state` + asset bundle | — |
| `IFavoritesRepository` | Hive `favorites` | unlimited |
| `IFeedbackService` | mailto deep-link (no storage) | — |
| `IChatHistoryRepository` | Hive `chat_history` (placeholder) | — |

### 8.3 AppConfig Fields

```
language, measurementUnit, numberFormat, decimalDigits,
vibrationEnabled, soundEnabled, alwaysOnScreen, keepCalculatorRecord,
startupCalculator, favoriteCurrency, favoriteTools[],
privacyUrl?, storeUrl?, moreAppsUrl?, helpUrl?
```

### 8.4 Number Format Enum

`system | grouped_comma_dot (1,234.56) | grouped_dot_comma (1.234,56) | grouped_apostrophe_dot (1'234.56) | grouped_apostrophe_comma (1'234,56)`.

### 8.5 Hive TypeIDs đề xuất

| TypeID | Model |
|---|---|
| 0 | CurrencyRateCacheModel |
| 1 | CalculatorHistoryModel |
| 2 | CurrencyHistoryModel |
| 3 | PercentageHistoryModel |
| 4 | WorldTimeStateModel |
| 5 | FavoriteModel |
| 6 | ChatHistoryModel (placeholder) |

---

## 9. Engine & Conversion Logic

### 9.1 Calculator Engine

**Pipeline**: `Raw → Tokenizer → Validator → Shunting-Yard (infix→RPN) → Evaluator → NumberFormatter → Display`.

**Tokens**: Number (double), Operator (`+−×÷^`), Function (sin/cos/log/...), Constant (π/e/φ), Paren, Unary (`±`, `1/x`, `x²`, `√`, `∛`, `|x|`, `!`).

**Precedence** (cao → thấp): `^` (right-assoc) > unary > `× ÷` > `+ −`.

**Angle conversion**:
- `DEG → RAD`: `rad = deg × π / 180`
- `GRA → RAD`: `rad = gra × π / 200`

**Error mapping**: NaN/Inf → `OutOfRange`; tokenize/validate fail → `InvalidSyntax`; length > 50 → block input.

**Precision**: `double` IEEE 754; làm tròn cuối qua `NumberFormatter`.

### 9.2 Currency Conversion

Rate model: base = USD, `rates[CODE] = double` (số đơn vị `CODE` per 1 USD).
Convert: `value_target = value_source × (rates[target] / rates[source])`.
Cache TTL: 1h soft; manual refresh bypass; background fetch khi mở màn nếu hết hạn (non-blocking nếu có cache).

### 9.3 Percentage Bidirectional

**Mode 1**:
- `Result = Number × Percentage / 100`
- `Number = Result × 100 / Percentage`
- `Percentage = Result × 100 / Number`

**Mode 2**:
- `Change = Initial × Percentage / 100`
- `Final = Initial + sign × Change`
- `Percentage = |Change| × 100 / Initial`
- `Initial = Change × 100 / Percentage`

**Conflict resolution**: queue `modifiedFields` FIFO 2-slot; field vừa sửa + slot trước = fixed; recompute còn lại.

### 9.4 World Time DST & Conversion

Source: `timezone` package (IANA tzdata bundled).

```
tz.Location loc = tz.getLocation(timezoneId)
tz.TZDateTime now = tz.TZDateTime.now(loc)
Duration offset = now.timeZoneOffset
bool isDST = loc.currentTimeZone.isDst
```

**Reference Mode**:
```
T_anchor_utc = referenceTime − offset_anchor
T_target_local = T_anchor_utc + offset_target
```

**OS TZ change**: `flutter_timezone.getLocalTimezone()` on resume; so sánh với device card.

### 9.5 NumberFormatter Pipeline

```
NumberFormatter.format(value, config):
  if |value| ≥ 1e15 OR (0 < |value| < 1e-6) → scientific notation
  else:
    apply grouping separator (numberFormat)
    apply decimal separator (numberFormat)
    truncate/round (decimalDigits)
    if |value| < 10^(-decimalDigits) → mở rộng decimalDigits để giữ ≥ 3 chữ số có nghĩa
```

---

## 10. State Management

### 10.1 MVVM Mapping

| MVVM | Flutter |
|---|---|
| Model | Domain Entities + Repository Interfaces |
| View | Widget tree (`presentation/screens/*.dart`) |
| ViewModel | `Cubit` (đơn giản) / `Bloc` (event-driven phức tạp) |

**Lý do chọn Cubit/Bloc**: stream-based reactive tốt hơn `ChangeNotifier`; tooling (`BlocObserver`, `BlocSelector`, `BlocListener`); community standard.

### 10.2 Provider Tree

```
MaterialApp
└── MultiBlocProvider (root)
    ├── AppConfigCubit       global
    ├── ThemesCubit          global
    ├── FavoritesCubit       global
    └── Router (go_router)
        ├── HomeShellCubit         shell scoped
        ├── CalculatorBloc         Calculator branch
        ├── ConverterListCubit     Converter branch
        ├── CurrencyConverterBloc  lazy
        ├── PercentageCubit        lazy
        ├── WorldTimeCubit         lazy + Timer
        ├── SettingsCubit          Settings branch
        └── FeedbackCubit          route scoped
```

### 10.3 Persistence Strategy

| ViewModel | Persistence | Trigger |
|---|---|---|
| `AppConfigCubit` | SharedPreferences | Mỗi emit (debounce 100ms) |
| `CalculatorBloc` | SharedPreferences `calc_draft` | Mỗi change (debounce 200ms) khi `keepCalculatorRecord=true` |
| `CurrencyConverterBloc` | SharedPreferences `currency_last_*` | Khi đổi currencies |
| `WorldTimeCubit` | Hive `world_time_state` | Khi add/remove/sort/reference change |
| `FavoritesCubit` | Hive `favorites` | Mỗi mutation |
| History repos | Hive (per box) | `add()` / `delete()` |

### 10.4 Reactive Settings Best Practices
- Dùng `BlocSelector<AppConfigCubit, AppConfigState, T>` để **chỉ rebuild khi field cần**.
- `MaterialApp.locale` bind trực tiếp với `AppConfigCubit.state.language` → Flutter rebuild widget tree khi đổi.

---

## 11. Navigation

### 11.1 Route Structure

`go_router v14+` với `StatefulShellRoute`:
- `/splash`, `/feedback?source=*` (no shell)
- HomeShell có 4 branches, giữ Navigator stack độc lập per tab.
- Calculator tab là `initialLocation`.

### 11.2 Back Behavior Matrix

| Vị trí | System Back | Kết quả |
|---|---|---|
| `/home/calculator` (root, default) | — | Exit Confirmation Dialog |
| Sub-screen Calculator | pop | Về Calculator |
| Tab khác (root) | switch | Về Calculator tab (giữ stack tab phụ) |
| Sub-screen tool | pop | Về screen cha |
| Feedback | pop | Về source tool |
| Dialog đang mở | đóng dialog | Giữ nguyên screen |

### 11.3 Deep Links

| Trigger | Scheme |
|---|---|
| Launcher Shortcut (Android) | `/home/calculator` hoặc `/home/converter/<tool>` |
| Notification Shortcut | `/home/calculator` (placeholder OQ8) |
| Privacy / Rating / More Apps | `https://...` (`url_launcher`) |
| Feedback Submit | `mailto:<email>?subject=...&body=...&attachment=...` |
| Battery Optimization Android | `ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` intent |
| Add Shortcut Android | `ShortcutManager.requestPinShortcut()` |

### 11.4 Tab State Preservation

`StatefulShellRoute.indexedStack` giữ Navigator stack + state mỗi branch. Switch tab không dispose Bloc.

**Exceptions** (reset state khi rời tab):
- Calculator Draft (khi `keepCalculatorRecord = false`).
- Currency Converter focus + bàn phím.
- World Time Edit Mode (bỏ chọn).

---

## 12. Permissions

### 12.1 Android Manifest

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />          <!-- API 33+ -->
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"
    android:maxSdkVersion="32" />
<uses-permission android:name="android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />          <!-- API 33+ -->
```

### 12.2 iOS Info.plist

```xml
<key>NSCameraUsageDescription</key>
<string>Cho phép Calculator AI truy cập camera để chụp ảnh đính kèm phản hồi.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Cho phép Calculator AI chọn ảnh từ thư viện để đính kèm phản hồi.</string>
```

### 12.3 Just-in-Time Request Flow

```
User trigger action
  → Check permission status
     ✓ Granted    → thực thi action
     ✗ Denied chưa hỏi → System Dialog
        ✓ Allow   → thực thi
        ✗ Deny    → Snackbar fallback + đóng action
     ✗ Permanently denied → Rationale Dialog → Open Settings
```

### 12.4 Permission Matrix

| Permission | Trigger | Fallback |
|---|---|---|
| Camera | Feedback chụp ảnh | Snackbar "Cần quyền Camera"; submit không ảnh |
| Photos | Feedback chọn ảnh | Snackbar; submit không ảnh |
| Internet | Currency refresh | Cache fallback + Snackbar |
| Battery Opt (Android) | Settings → tap row | Row vẫn hiển thị, không nhắc |
| Notification (Android 13+) | Notification Shortcut toggle | Toggle revert OFF + Snackbar |
| Launcher Shortcut (Android) | Add Shortcut menu/Settings | Snackbar "Launcher không hỗ trợ" |

**iOS**: Battery Opt + Launcher Shortcut + Add Shortcut **ẩn hoàn toàn**.

**Recheck timing**: Battery Opt recheck mỗi `AppLifecycleState.resumed`; permissions khác chỉ check khi action trigger.

---

## 13. Technical Architecture

### 13.1 Folder Structure

```
lib/
├── core/                  utils, theme, constants, error
├── features/
│   ├── calculator/        domain/ data/ presentation/
│   ├── converter/         list/ currency/ percentage/ world_time/
│   ├── settings/
│   ├── feedback/
│   └── ai_tutor/          placeholder
├── shared/                widgets/ blocs/ services/
├── l10n/                  ARB files
├── app.dart
└── main.dart
```

### 13.2 DI

`get_it + injectable`:
- **Singleton**: `AppConfigRepository`, `CurrencyRepository` (Dio), Hive box refs.
- **LazySingleton**: Use cases.
- **Factory**: ViewModels (Cubit/Bloc).

### 13.3 Package List

| Concern | Package |
|---|---|
| State | `flutter_bloc`, `equatable` |
| Navigation | `go_router` ^14 |
| DI | `get_it`, `injectable` (+ build_runner) |
| Local DB | `hive_flutter` |
| Prefs | `shared_preferences` |
| HTTP | `dio` |
| Timezone | `timezone`, `flutter_timezone` |
| I18n | `intl`, `flutter_localizations` |
| Wakelock | `wakelock_plus` |
| Battery | `battery_optimization` hoặc native channel |
| Share | `share_plus` |
| URL | `url_launcher` |
| Image | `image_picker` |
| Files | `path_provider` |
| Metadata | `package_info_plus`, `device_info_plus` |
| Permission | `permission_handler` ^11 |
| Connectivity | `connectivity_plus` |
| App Settings | `app_settings` |

### 13.4 I18n

ARB files (`app_en.arb`, `app_vi.arb`, ...) → `flutter gen-l10n` → `AppLocalizations.of(context).key`.
`MaterialApp.locale` bind với `AppConfigCubit.state.language`; rebuild tree khi đổi.
Khi `language = system` → `Platform.localeName`.
City/country names tra qua `cityNameKey` (ARB), tzid IANA cố định.

### 13.5 Theme

`AppTheme.light / .dark` (`ColorScheme.fromSeed`). `ThemesCubit` emit `ThemeMode` → `MaterialApp.themeMode`. MVP chỉ Light/Dark.

---

## 14. Acceptance Criteria Coverage

### 14.1 Status Summary

| Area | Total | Covered | Partial | Open |
|---|---|---|---|---|
| Navigation & Shell | 5 | 5 | 0 | 0 |
| Calculator | 12 | 12 | 0 | 0 |
| Currency Converter | 11 | 11 | 0 | 0 |
| Percentage Calculator | 7 | 7 | 0 | 0 |
| World Time | 12 | 12 | 0 | 0 |
| Settings | 7 | 7 | 0 | 0 |
| Feedback | 5 | 4 | 0 | 1 (email đích) |
| Permissions | 9 | 9 | 0 | 0 |

### 14.2 Key AC Mappings

**Calculator**: real-time preview, lưu/không lưu history theo validity, auto-replace operator, auto-close bracket, long-press wrap, draft persist, limit 50 ký tự, format Settings, DEG/RAD/GRA indicator, Scientific→Basic sau insert, scientific notation, history 100 FIFO.

**Currency**: cache TTL 1h, manual refresh bypass, offline+cache → vẫn quy đổi, offline-no-cache → màn lỗi + Retry, real-time calc, Caution chỉ khi tap menu, Simple/Advanced toggle, fallback chain USD/JPY/AUD/CAD, Add Shortcut Android only, history restore, ẩn footer Advanced.

**Percentage**: bidirectional, mode state preserve, trường rỗng không lỗi, decimal cap 3/6, history 100 FIFO, title overlay = field name, commit timing (Share/toggle/back).

**World Time**: device pinned top, không xoá device, DST đúng, không trùng, sort device top, reference mode, nút Now header, indicator banner, long-press → Edit, long-press device = no-op, OS TZ change, persistence Reference mode.

**Settings**: instant apply, Number Format re-render, Battery Opt Android only, ẩn khi exempt, ẩn link rỗng, Clear Chat confirm, Themes Light/Dark MVP.

**Feedback**: mailto submit, single-select issue, image attach, offline → Snackbar, metadata gồm app/os/device/lang; ⚠️ email đích pending (OQ1).

**Permissions**: just-in-time, từ chối graceful, rationale → Settings, Battery Opt ẩn khi exempt + recheck on resume, iOS ẩn Battery/Shortcut, iOS Limited Photo Access OK, Android 13+ POST_NOTIFICATIONS, state luôn fresh.

---

## 15. Implementation Roadmap

### Phase 0 — Foundation (1–2 ngày)
- Flutter project scaffold + `pubspec.yaml`.
- Clean Architecture folder structure.
- DI (`get_it + injectable`).
- `go_router` skeleton (placeholder screens).
- Hive init + adapters.
- I18n ARB (EN + VI base).
- `AppTheme` Light/Dark.
- `AppConfigCubit` + Repository.
- `NumberFormatter` utility + **≥ 20 unit tests**.

### Phase 1 — Shell + Settings (2–3 ngày)
- HomeShell 4-tab `StatefulShellRoute`.
- Back behavior (`PopScope`).
- Settings screen đầy đủ (System + Chat + Developer).
- Themes screen.
- Reactive language switch.
- Battery Optimization (Android).

### Phase 2 — Calculator (3–4 ngày)
- `CalculatorEngine` (Tokenizer + Shunting-Yard + Evaluator).
- `CalculatorBloc` (state machine, draft persist, rollback stack).
- Basic & Scientific Keyboard (7×4) widgets.
- Display Panel + Angle indicator + History preview.
- Calculator History Screen.
- **≥ 30 unit tests** `CalculatorEngine`.

### Phase 3 — Converter List + Favorites (1–2 ngày)
- `ConverterListCubit` (search debounce, categories).
- `FavoritesCubit` + Hive Repo.
- Favorites Grid + Manage Favorites mode.
- Empty state.

### Phase 4 — Currency Converter (3–4 ngày)
- `CurrencyRepository` (Dio + Hive cache, TTL 1h).
- `CurrencyConverterBloc` (Simple/Advanced, fallback USD/JPY/AUD/CAD).
- Currency Picker (search localized + English + ISO).
- Custom keypad 4×4 + `±=` Overlay launcher.
- Offline states.
- Caution dialog (manual only).
- Share / Add Shortcut / History.
- Footer rate (ẩn Advanced).

### Phase 5 — Percentage Calculator (2–3 ngày)
- `PercentageFormulaEngine` (bidirectional, 2-slot queue).
- `PercentageCubit` (state preserve per mode).
- Form Mode 1 (3 fields) + Mode 2 (4 fields).
- Keypad 5×4 (+/− disable Mode 1).
- Calculator Overlay integration.
- Calculation Formula dialog.
- History + Share.
- **≥ 15 unit tests** formula engine.

### Phase 6 — World Time (3–4 ngày)
- Integrate `timezone` + `flutter_timezone`.
- `WorldTimeCubit` (live ticker, reference mode, DST, sort, edit).
- Device card pinning.
- Add City Screen.
- Set Reference Time dialog + Date/Time Picker wheels (year ±100).
- Now button + Reference banner.
- Sort bottom-sheet 4 options.
- Edit mode multi-select.
- OS TZ change detect on resume.
- Persistence Reference qua restart.

### Phase 7 — Cross-cutting + Feedback (2–3 ngày)
- `HapticService`, `SoundService`, `WakelockService`.
- Permission flows (camera, photos, notification, battery opt).
- Feedback Screen (dropdown, single-select issues, textarea, image, mailto Submit).
- Metadata builder (`package_info_plus + device_info_plus`).
- Error UX (Snackbar helper, global handler).
- App Widget / Notification Shortcut / Launcher Shortcut (placeholder).

### Phase 8 — AI Tutor Placeholder + Chat (1 ngày)
- AI Tutor tab UI placeholder.
- Chat History screen.
- Clear Chat History (confirm + Hive clear).

### Phase 9 — QA & Polish (3–5 ngày)
- Unit tests đầy đủ.
- Widget tests key screens.
- Integration tests happy paths.
- Accessibility audit.
- Performance check 60fps.
- Edge cases (offline, OS TZ, rapid toggle, large numbers).
- Localization review EN + VI.
- Build release APK + IPA.

**Tổng**: ~21–28 ngày dev cho team 1 mid-senior + 1 junior.

---

## 16. Dev Handoff Checklist

### Trước khi code 1 feature
- [ ] Đọc `feature_*.md` tương ứng (source of truth chi tiết nhất).
- [ ] Đọc `ui_notes.md` cho design tokens.
- [ ] Đọc `technical_design.md` cho engine/data design.
- [ ] Đọc `navigation_flow.md` cho route + back stack.
- [ ] Đọc `permission_system_flow.md` nếu feature đụng permission.
- [ ] Đọc `solution_architecture_review.md` cho cross-cutting concerns.
- [ ] Kiểm tra Open Questions §18 — không tự assume thêm.
- [ ] Xác nhận data model trong `architecture.md` trước khi viết Hive model.

### Conventions
- Tên biến/hàm: `camelCase`; class/widget: `PascalCase`; hằng số: `UPPER_SNAKE_CASE`.
- Không hardcode string hiển thị → `AppLocalizations`.
- Mọi số hiển thị phải qua `NumberFormatter.format()`.
- Mọi async I/O phải try-catch → map sang `Failure`.
- ViewModel KHÔNG import Flutter widgets (chỉ `flutter_bloc` base).

### Testing Targets
| Component | Min tests |
|---|---|
| `CalculatorEngine` | 30 (gồm chia 0, overflow, trig DEG/RAD/GRA) |
| `NumberFormatter` | 20 (gồm scientific 2 ngưỡng) |
| `PercentageFormulaEngine` | 15 (mode 1, mode 2, conflict) |
| `CurrencyRepository` cache | 10 (TTL, offline, force refresh) |
| `WorldTimeCubit` DST + reference | 10 (DST switch, OS TZ change, day boundary) |

---

## 17. Recommended File Implementation Order

```
1.  core/utils/number_formatter.dart            ← dùng khắp nơi, test trước
2.  core/utils/expression_validator.dart
3.  core/utils/timezone_utils.dart
4.  shared/blocs/app_config/                    ← global state
5.  shared/blocs/theme/
6.  app.dart + main.dart + go_router scaffold
7.  features/settings/                          ← test reactive settings sớm
8.  features/calculator/domain/engine/          ← logic phức tạp nhất
9.  features/calculator/data/
10. features/calculator/presentation/
11. features/converter/list/ + favorites
12. features/converter/currency/                ← Dio + cache
13. shared/widgets/calculator_overlay.dart      ← Currency cần overlay
14. features/converter/percentage/              ← dùng overlay
15. features/converter/world_time/              ← timezone package
16. shared/widgets/ (keyboard, dialogs, snackbar)
17. shared/services/ (haptic, sound, wakelock, permission)
18. features/feedback/                          ← cần mailto + permission
19. features/ai_tutor/ + chat history          ← placeholder
20. Phase 7 cross-cutting (widget, notification, shortcut)
21. QA pass
```

---

## 18. Open Questions

### 18.1 🔴 High — Block Phase tương ứng

| # | Câu hỏi | Block Phase |
|---|---|---|
| OQ1 | Email mailto đích (vd `support@tohsoft.com`?) | Phase 7 |
| OQ2 | List preset Feedback issues đầy đủ — nội dung từng item | Phase 7 |
| OQ10 | Currency API endpoint + auth scheme cụ thể | Phase 4 |

### 18.2 🟡 Medium

| # | Câu hỏi | Block Phase |
|---|---|---|
| OQ5 | Help link URL — nội bộ hay ngoài? | Phase 1 |
| OQ6 | Startup Calculator option list đầy đủ | Phase 1 |
| OQ7 | App Widget nội dung + kích thước | Phase 7 |
| OQ8 | Notification Shortcut dẫn tới tính năng nào | Phase 7 |
| OQ9 | Launcher Shortcut scope (icon đơn vs widget) | Phase 7 |

### 18.3 🟢 Low

| # | Câu hỏi | Block Phase |
|---|---|---|
| OQ11 | Percentage History commit timing xác nhận | Phase 5 |
| OQ12 | Chat History xoá theo khoảng thời gian | Phase 8 |

### 18.4 Architectural decision còn open

| # | Decision | Recommendation |
|---|---|---|
| AD1 | MVVM ViewModel: Cubit/Bloc vs ChangeNotifier | **Cubit/Bloc** (community standard, tooling tốt) |
| AD2 | Currency cache TTL configurable? | **1h cố định MVP** |
| AD3 | History capacity 100 hard cap? | **100 hard cap** |
| AD4 | Themes: chỉ Light/Dark? | **Light/Dark only MVP** |

---

## 19. Next Steps

1. **Stakeholder review session** đóng OQ1, OQ2, OQ10 (🔴 còn lại) trong ≤ 1 buổi.
2. **Khoá baseline** → tag `spec-v1.0` → bắt đầu Phase 0.
3. Phase 0 → Phase 9 theo roadmap §15.

---

## 20. Tham chiếu nhanh

- Chi tiết feature: `feature_calculator.md`, `feature_converter.md`, `feature_percentage_calculator_screen.md`, `feature_world_time.md`, `feature_setting.md`.
- Chi tiết kỹ thuật: `technical_design.md`.
- Navigation: `navigation_flow.md`.
- Permission: `permission_system_flow.md`.
- Cross-cutting review: `solution_architecture_review.md`.
- Design system / UI tokens: `ui_notes.md`.
- Coding conventions: `CLAUDE.md`.

---

*Tài liệu này là single-source baseline `spec-v1.0`. Khi có mâu thuẫn với file đặc tả riêng, ưu tiên file chi tiết (`feature_*.md`); khi conflict với AC đã confirmed, giữ AC.*
