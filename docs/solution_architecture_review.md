# Calculator AI — Solution Architecture Review

> **Version**: 1.0 · 2026-06-02
> **Vai trò**: Solution architect + Senior engineer + Product-minded analyst
> **Phạm vi**: Đối chiếu chéo toàn bộ tài liệu, chuẩn hóa thiết kế, đề xuất technical design (Flutter + MVVM + Repository), implementation roadmap, acceptance criteria mapping.

---

## 1. Executive Summary

Calculator AI là Flutter mobile app (Android + iOS) offline-first, đơn người dùng, không tài khoản. Gồm 4 tab: AI Tutor (placeholder), Converter (Currency / Percentage / World Time), **Calculator (default)**, Settings.

**Trạng thái spec**: 11 file tài liệu đã chuẩn hóa qua nhiều vòng review; phần lớn xung đột đã đóng. Còn **2 file đề cập trong yêu cầu chưa tồn tại**: `navigation_flow.md`, `permission_system_flow.md` — cần tạo trước Phase 1.

**Điểm nóng kiến trúc**:
1. **Reactive Settings**: thay đổi `numberFormat` / `decimalDigits` / `language` phải re-render tức thì toàn app.
2. **Calculator Engine**: parse infix → RPN; hỗ trợ DEG/RAD/GRA; precision edge cases.
3. **Currency cache + API**: TTL chiến lược; offline fallback; refresh thủ công.
4. **Percentage bidirectional**: tính ngược từ bất kỳ 2 trường (mode 1) / `Initial + 1 trường` (mode 2).
5. **World Time DST**: tzdata IANA bundled local; detect đổi timezone hệ thống.
6. **Calculator Overlay shared**: dùng chung giữa Currency + Percentage; ẩn ở World Time.

**Kiến trúc đề xuất**: **MVVM + Repository** trên nền Clean Architecture 3 tầng. ViewModels implement bằng `flutter_bloc Cubit/Bloc` (Cubit ≈ ViewModel idiomatic cho Flutter; preserve được toàn bộ technical_design.md hiện có). DI bằng `get_it + injectable`. Navigation `go_router` v14+ với `StatefulShellRoute`.

**Sẵn sàng cho Phase 0 (Foundation)** sau khi đóng 6 Open Questions còn lại (xem §17).

---

## 2. Document / Source-of-Truth Review

### 2.1 Trạng thái file hiện có

| File | Vai trò | Trạng thái | Ghi chú |
|---|---|---|---|
| `CLAUDE.md` | Coding guidelines, platform target | ✅ Synced | Flutter only, Clean Arch + Bloc + go_router + Hive |
| `architecture.md` | Cấu trúc thư mục, data models | ✅ Synced | Đã bỏ `WorldTimeHistory`, thêm enum NumberFormat, ngưỡng scientific |
| `feature_spec.md` | Đặc tả tổng quan | ✅ Synced | Themes/Help quick action, History 100 FIFO, mailto Feedback |
| `ui_notes.md` | Design tokens, UI conventions | ✅ Synced | Bottom Bar tool, Calculator Overlay shared, Share template per tool |
| `feature_calculator.md` | Calculator chi tiết | ✅ Synced | Scientific keypad 7×4 đều, History raw+display |
| `feature_converter.md` | List + Currency + Feedback | ✅ Synced | Fallback Simple→Advanced chốt USD/JPY/AUD/CAD |
| `feature_percentage_calculator_screen.md` | Percentage chi tiết | ✅ Synced | Schema History rõ, commit timing |
| `feature_world_time.md` | World Time chi tiết | ✅ Synced | Ẩn icon Calculator Bottom Bar, long-press device = no-op |
| `feature_setting.md` | Settings chi tiết | ✅ Synced | App Widget/Notif/Launcher Shortcut = MVP placeholder |
| `technical_design.md` | Technical design + roadmap | ✅ Synced | Đã gỡ Caution flag, queue Feedback, bổ sung packages |
| `design_plan.md` | Plan cũ | ⚠️ Deprecated | Đã đánh dấu DEPRECATED, trỏ về `technical_design.md` |

### 2.2 File mới tạo (bổ sung sau review)

| File | Vai trò | Trạng thái |
|---|---|---|
| `navigation_flow.md` | Route map + back stack matrix + deep links + tab preservation | ✅ Created |
| `permission_system_flow.md` | Permission inventory Android/iOS + rationale dialog + fallback graceful | ✅ Created |

### 2.3 Quy ước ưu tiên khi xung đột
`feature_*.md` (chi tiết) > `feature_spec.md` (tổng quan) > `architecture.md` > `technical_design.md` (kỹ thuật) > `ui_notes.md` (UI tokens).
Khi conflict với acceptance criteria đã confirmed → giữ AC.

---

## 3. Spec Conflicts and Assumptions

### 3.1 Confirmed (đã đóng)

| # | Hạng mục | Quyết định |
|---|---|---|
| C1 | Bottom Nav tab thứ 1 | AI Tutor (không phải Recent) |
| C2 | Default tab | Calculator |
| C3 | Framework | Flutter only |
| C4 | State management | flutter_bloc (Cubit/Bloc) — đóng vai ViewModel trong MVVM |
| C5 | Nhóm Settings thứ 3 | **DEVELOPER SETTINGS** |
| C6 | Nhãn Rating | **Rate us 5 stars** |
| C7 | Keep Calculator Record clear time | Cả thoát app **và** chuyển tab |
| C8 | Percentage keypad | **5 rows × 4 cols** |
| C9 | Bàn phím Scientific hàng 2 | Không có DEG/RAD/GRA; cycle qua tap nhãn header; `rand` 1 ô riêng; dec/hex/bin out of scope MVP |
| C10 | Favorites sort | Theo addedOrder; không drag-drop; không giới hạn số lượng |
| C11 | World Time format | 24h cố định |
| C12 | Chat Settings vị trí | Trong Tab Settings |
| C13 | Currency Caution Dialog | Chỉ mở khi tap menu, không auto lần đầu |
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
| C25 | Reference Mode persistence | Giữ qua app restart (không auto reset) |

### 3.2 Assumption (chưa stakeholder confirm — đang dùng làm baseline)

| # | Assumption | Lý do | Risk |
|---|---|---|---|
| A1 | Currency cache TTL = 1 giờ | Chuẩn ngành | Thấp |
| A2 | Calculator expression max = 50 ký tự (UI cap) | Theo spec | Thấp |
| A3 | `favoriteCurrency` auto-update theo FROM cuối cùng chọn | Không có UI picker riêng | Thấp |
| A4 | Help → link web ngoài (theo quy tắc ẩn nếu URL rỗng) | Consistent với Privacy/Rating | Trung bình |
| A5 | App Widget = ô nhập nhanh Basic Calculator | Inferred từ tên | **Cao** — cần stakeholder |
| A6 | Notification Shortcut = mở Calculator tab | Inferred | **Cao** |
| A7 | Themes = chỉ Light/Dark toggle trong MVP, không IAP | Đã chốt placeholder | Thấp |
| A8 | Email mailto đích = `support@tohsoft.com` | Inferred từ Play Store URL ở Share content | **Cao** |
| A9 | List preset Feedback issues 6 items mẫu (xem `feature_converter.md` §3.2) | Inferred từ screenshot | **Cao** |
| A10 | Percentage History commit khi rời màn + tap Share | Inferred | Trung bình |
| A11 | Currency picker flag từ asset bundle local | Không có CDN | Thấp |

### 3.3 Open Questions (chưa giải quyết — block phase tương ứng)

Xem §17.

---

## 4. Product Structure

```
Calculator AI (Flutter)
└── Splash
    └── HomeShell (Bottom Nav 4 tab, StatefulShellRoute)
        ├── [0] AI Tutor                  ─ placeholder
        ├── [1] Converter
        │   ├── ConverterList             ─ search + Favorites grid + categories
        │   ├── Currency Converter        ─ Simple/Advanced + History
        │   │   ├── History
        │   │   └── Calculator Overlay (shared)
        │   ├── Percentage Calculator     ─ Mode 1/2 + History
        │   │   ├── History
        │   │   └── Calculator Overlay (shared)
        │   └── World Time Converter      ─ Now/Reference mode + Add City
        │       └── Add City
        ├── [2] Calculator (default)
        │   └── History
        └── [3] Settings
            ├── Themes (placeholder Light/Dark)
            ├── Chat History (AI Tutor logs)
            └── Feedback (route shared, từ menu mọi tool)
```

**Back behavior**:
- Tab ≠ Calculator → Back về Calculator tab (giữ stack tab phụ).
- Calculator → Back = Exit Confirmation Dialog.
- Trong sub-screen tool → Back về screen cha (Bottom Bar tool back).

**Tab state preservation**: dùng `StatefulShellRoute` — mỗi branch giữ Navigator stack độc lập. Input state nằm trong Cubit (scoped đến screen lifecycle).

---

## 5. End-to-End Flows

### 5.1 App Startup Flow

```
Splash
  ↓ Load AppConfig (SharedPreferences)
  ↓ Initialize Hive boxes (lazy)
  ↓ Provide global Cubits: AppConfigCubit, FavoritesCubit, ThemesCubit
  ↓ Check Battery Optimization (Android only) → set flag
  ↓ Restore last route (nếu có)
  → HomeShell @ tab Calculator (default)
     → CalculatorCubit init: load draft nếu keepCalculatorRecord
     → CurrencyConverterCubit defer init (lazy khi user vào tab)
     → WorldTimeCubit defer init
```

### 5.2 Settings Change Propagation (Reactive)

```
User toggle/picker change ở Settings
  → AppConfigCubit.update(field)
  → persist SharedPreferences
  → emit AppConfigState mới
  ⤵ subscribers rebuild:
     • Calculator display: re-format result (raw → format mới)
     • Currency Converter: re-format các ô values
     • Percentage Calculator: re-format các field values
     • World Time: re-format display time (nếu cần)
     • MaterialApp.locale: rebuild toàn widget tree với language mới
```

**Key**: dùng `BlocSelector` hoặc `select<>` để hạn chế rebuild scope.

### 5.3 Currency Converter Data Flow

```
Mở Currency Converter
  → CurrencyConverterCubit.init()
     ↓ check Hive cache → timestamp < 1h?
        • Có → emit CurrencyLoaded(fromCache: true)
        • Không → fetch API
           ✓ thành công → cache + emit CurrencyLoaded(fromCache: false)
           ✗ có cache cũ → emit CurrencyLoadedOffline(staleCache)
           ✗ không cache → emit CurrencyError(retryable: true)

User nhập số ô A
  → CurrencyConverterCubit.onValueChanged(index, value)
  → compute tất cả ô khác đồng bộ qua rate normalize về USD base
  → emit state mới

User tap Refresh menu
  → bypass TTL → fetch API → cập nhật cache + state
  → request đang chạy: cancel + restart

User tap Caution menu
  → mở Dialog (không cần state flag, không lưu lần đầu)
```

### 5.4 Calculator Computation Flow

```
User nhấn phím
  → CalculatorBloc.add(KeyPress(key))
  → CalculatorEngine.append(key, currentExpression)
     ↓ Tokenize → Validate (auto-replace operator, length cap)
     ↓ Preview evaluate (nếu hợp lệ về syntax) → previewResult
  → emit state(expression, previewResult, angleMode)

User nhấn =
  → CalculatorEngine.evaluate(expression, angleMode)
     ✓ NumericResult(raw, display)
        → CalculatorHistoryRepo.add(item) (push, evict nếu > 100)
        → emit state(result on Expression Line, clear preview)
     ✗ ErrorResult(InvalidSyntax | OutOfRange)
        → emit Snackbar event, không lưu history

User tap History item
  → emit state(expression = item.expression, angleMode = item.angleMode)
```

### 5.5 Percentage Bidirectional Flow

```
User nhập value vào field X
  → PercentageCubit.onFieldChanged(field, value)
  → state.modifiedFields.push(field)  // FIFO 2 slots
  → resolve formula:
     • Đủ 2 field (mode 1) hoặc Initial + 1 field (mode 2) → tính field còn lại
     • Mâu thuẫn (3+ field filled, user vừa sửa 1) → giữ 2 field gần nhất, recompute còn lại
  → emit state mới (derived fields có flag isDerived)

User toggle +/− (mode 2)
  → flip signIsPositive → recompute Change & Final → emit
  → KHÔNG commit History

Commit History trigger:
  • User tap Share menu
  • User toggle mode (% ↔ ±%) khi form hợp lệ
  • User back/rời màn khi form hợp lệ
```

### 5.6 World Time Reference Mode Flow

```
Mặc định: Now Mode
  → Timer tick mỗi giây
  → WorldTimeCubit emit cities với T = DateTime.now()

User tap card C
  → showDialog(SetReferenceTimeDialog(city: C))
  → user chọn date + time → OK
  → WorldTimeCubit.setReference(city: C, refTime: T_ref)
     ↓ cancel timer
     ↓ for each city: T_target = T_ref + (offset_target − offset_ref) (DST-aware)
     ↓ emit ReferenceMode state + header banner

User tap nút Now (header)
  → WorldTimeCubit.clearReference()
  → restart timer
  → ẩn banner

App backgrounded → foreground (resume)
  → check OS timezone diff → update device card
  → re-evaluate DST cho mọi city (kể cả Reference Mode)
  → persist state qua Hive
```

### 5.7 Feedback Submit Flow (mailto)

```
User mở Feedback (từ menu tool)
  → FeedbackCubit.init(context: toolId)
  → dropdown auto-fill = toolId

User chọn issue + nhập text + (optional) attach image
User tap Submit
  → validate (cần ≥ 1 issue OR Other text)
  → online?
     ✓ build mailto URI:
        - to: support@tohsoft.com (A8)
        - subject: "[Calculator AI] Feedback - {feature_name}"
        - body: issue + other + metadata (app_version, os, device, language)
        - attachment: ảnh (nếu platform hỗ trợ)
       → launchUrl(mailtoUri)
     ✗ Snackbar "Không có kết nối Internet" → không queue
```

---

## 6. Feature-by-Feature Design

### 6.1 Calculator

| Aspect | Design |
|---|---|
| ViewModel | `CalculatorBloc` (Event-driven do số state transition cao) |
| State fields | `expression, previewResult, angleMode, isScientific, showAngleIndicator, rollbackStack, historyPreview` |
| Engine | Custom Tokenizer → Validator → Shunting-Yard → Evaluator → NumberFormatter |
| Persistence | Draft → SharedPreferences (khi `keepCalculatorRecord` bật); History → Hive box `calculator_history` (cap 100 FIFO) |
| Edge handling | Invalid syntax, div by 0, sqrt(-x), NaN/Inf → Snackbar `"giá trị tính vượt phạm vi"` / `"biểu thức không đúng định dạng"` |
| Scientific keypad | 7×4, hàng 7 chỉ 1 ô `atanh` + 3 ô placeholder disabled |
| Angle mode | Tap nhãn header để cycle DEG → RAD → GRA → DEG |
| Long-press `()` | Bao toàn bộ expression |
| Rollback | Stack action-based; reset khi `C` hoặc `=` |

### 6.2 Currency Converter

| Aspect | Design |
|---|---|
| ViewModel | `CurrencyConverterBloc` |
| State fields | `mode (simple/advanced), currencies[], values[], focusedIndex, rateData, loadStatus, lastUpdated` |
| Conversion | Normalize tất cả tỷ giá về USD base; `value_B = value_A × (rate_B / rate_A)` |
| Cache | Hive `currency_cache` (TTL 1h); manual refresh bypass; offline + cache → vẫn quy đổi |
| Mode toggle | Simple → Advanced fill default EUR, GBP (fallback USD → JPY → AUD → CAD nếu trùng) |
| Keypad | 4×4 custom; `±=` mở Calculator Overlay |
| Menu | Add Shortcut (Android only) / Favorite / Refresh / Simple-Advanced / History / Share / Caution / Help / Feedback / Settings |
| History | Hive `currency_history` (cap 100 FIFO) |

### 6.3 Percentage Calculator

| Aspect | Design |
|---|---|
| ViewModel | `PercentageCubit` |
| State fields | `mode (percentOfNumber/percentChange), fields{}, signIsPositive, focusedField, modifiedFieldsQueue, modeState{}` |
| Formula engine | Bidirectional: solve cho field thiếu khi đủ điều kiện (2/3 fields ở mode 1, Initial+1/4 fields ở mode 2) |
| Conflict resolution | Khi tất cả filled + user sửa 1 field → keep 2 modified gần nhất (FIFO 2-slot), recompute còn lại |
| Decimal cap | `Percentage`: 3 dp; field khác: 6 dp |
| Sign | Luôn hiển thị explicit `+`/`−` ở mode 2 |
| Keypad | 5×4; `+/−` chỉ active ở mode 2 (disable ở mode 1); `↓↑` swap Number⇄Result (mode 1) hoặc Initial⇄Final (mode 2) |
| History | Hive `percentage_history` (cap 100 FIFO); commit khi Share/toggle mode/rời màn |

### 6.4 World Time Converter

| Aspect | Design |
|---|---|
| ViewModel | `WorldTimeCubit` |
| State fields | `cities[], referenceCity?, referenceTime?, sortCriteria, sortAscending, isEditMode, selectedForDelete{}` |
| Live ticker | Timer 1s khi `referenceTime == null`; emit lại state |
| DST | `timezone` package; offset lấy theo `tz.TZDateTime` tại thời điểm display |
| Conversion | `T_target = T_ref + (offset_target − offset_ref)` (cả 2 offset đã DST-adjusted) |
| OS timezone change detect | `flutter_timezone` lắng app resume |
| Device card | Always pinned top, không xoá; long-press = no-op |
| Edit mode | Multi-select checkbox; vào qua menu hoặc long-press user-card; không drag-drop |
| Sort | Bottom-sheet 4 options; device card luôn top |
| Persistence | Hive `world_time_state` (selectedCityIds[], referenceCity?, referenceTimeMs?, sort) |
| Bottom Bar | **KHÔNG có icon Calculator** (đã ẩn) |

### 6.5 Settings

| Aspect | Design |
|---|---|
| ViewModel | `AppConfigCubit` (global, root provider) + `SettingsScreenCubit` (local) |
| State | `AppConfigState` chứa toàn bộ field — xem `architecture.md` §5 |
| Instant apply | Mỗi `update*()` → persist + emit; subscribers rebuild |
| Battery Optimization | Check via `battery_optimization_android` khi initState + onResume |
| Themes | `ThemesScreen` riêng; chỉ Light/Dark toggle MVP |
| Quick actions | Themes + Help buttons ở đầu màn |
| URLs | Ẩn item nếu config URL = null/empty |

### 6.6 Feedback (shared)

| Aspect | Design |
|---|---|
| ViewModel | `FeedbackCubit` |
| State | `context, selectedIssue?, otherText, imagePath?` |
| Submit | Build `mailto:` URI → `url_launcher` → email client |
| Metadata | `package_info_plus` + `device_info_plus` (app_version, os_version, device_model, language) |
| Offline | Snackbar lỗi, không queue |
| Validation | ≥ 1 issue OR Other text non-empty |

### 6.7 Calculator Overlay (shared component)

| Aspect | Design |
|---|---|
| Component | `CalculatorOverlayDialog(fieldName, initialValue, onResult)` |
| State | Internal expression + preview (scoped to dialog) |
| UI | Display nhỏ + Basic Keyboard |
| Title | Dynamic = `fieldName` (vd `Initial Value`, `Number`, `FROM CURRENCY`) |
| Result | Tap `=` hoặc đóng (X) → callback `onResult(value)` để inject vào field cha |
| History | KHÔNG lưu vào Calculator History |
| Usage | Currency keypad `±=` + Percentage keypad `±=`; World Time KHÔNG dùng |

---

## 7. Screen Design Summary

| Screen | Route | ViewModel(s) | Persistent State (Hive/SharedPreferences) |
|---|---|---|---|
| Splash | `/splash` | AppConfigCubit (init) | AppConfig (SharedPreferences) |
| HomeShell | `/home` | HomeShellCubit (tab index) | tabIndex (SharedPreferences) |
| AI Tutor | `/home/ai-tutor` | (placeholder) | — |
| Converter List | `/home/converter` | ConverterListCubit, FavoritesCubit | favorites[] (Hive) |
| Currency Converter | `/home/converter/currency` | CurrencyConverterBloc | last currencies, cache (Hive) |
| Currency History | `/home/converter/currency/history` | CurrencyHistoryCubit | history[] (Hive, cap 100) |
| Percentage Calculator | `/home/converter/percentage` | PercentageCubit | last mode + state (optional) |
| Percentage History | `/home/converter/percentage/history` | PercentageHistoryCubit | history[] (Hive, cap 100) |
| World Time | `/home/converter/world-time` | WorldTimeCubit | state (Hive) |
| Add City | `/home/converter/world-time/add` | WorldTimeCubit (shared) | — |
| Calculator | `/home/calculator` | CalculatorBloc | draft expression (SharedPreferences) |
| Calculator History | `/home/calculator/history` | CalculatorHistoryCubit | history[] (Hive, cap 100) |
| Settings | `/home/settings` | AppConfigCubit, SettingsCubit | AppConfig (SharedPreferences) |
| Themes | `/home/settings/themes` | ThemesCubit | theme (SharedPreferences) |
| Chat History | `/home/settings/chat-history` | ChatHistoryCubit | chat[] (Hive) |
| Feedback | `/feedback?source=<toolId>` | FeedbackCubit | — |

---

## 8. Domain / Data Design

### 8.1 Domain Entities

```
AppConfig
ConverterTool, FavoriteItem
CurrencyRate, CurrencyHistoryItem
PercentageHistoryItem
WorldTimeCity, WorldTimeState, CityTimeEntry (runtime)
CalculatorHistoryItem
FeedbackPayload (transient, không persist)
```

### 8.2 Repository Interfaces (Domain)

| Repository | Methods | Storage |
|---|---|---|
| `IAppConfigRepository` | `load()`, `save()`, `watch()` | SharedPreferences |
| `ICurrencyRepository` | `fetchRates()`, `getCachedRates()`, `saveCache()` | Hive `currency_cache` + Dio |
| `ICalculatorHistoryRepository` | `getAll()`, `add(item)`, `delete(id)`, `clearAll()` | Hive `calculator_history` |
| `ICurrencyHistoryRepository` | (same shape) | Hive `currency_history` |
| `IPercentageHistoryRepository` | (same shape) | Hive `percentage_history` |
| `IWorldTimeRepository` | `getState()`, `saveState()`, `getCityCatalog()` | Hive `world_time_state` + asset bundle |
| `IFavoritesRepository` | `getAll()`, `add()`, `remove()` | Hive `favorites` |
| `IFeedbackService` | `buildMailtoUri(payload)` | (no storage; chỉ build URI) |
| `IChatHistoryRepository` | (placeholder AI Tutor) | Hive `chat_history` |

### 8.3 Hive Type IDs (đề xuất)

| TypeID | Model |
|---|---|
| 0 | CurrencyRateCacheModel |
| 1 | CalculatorHistoryModel |
| 2 | CurrencyHistoryModel |
| 3 | PercentageHistoryModel |
| 4 | WorldTimeStateModel |
| 5 | FavoriteModel |
| 6 | ChatHistoryModel (placeholder) |

### 8.4 Capacity & TTL Policy

| Box | Cap | Eviction | TTL |
|---|---|---|---|
| `calculator_history` | 100 items | FIFO | — |
| `currency_history` | 100 items | FIFO | — |
| `percentage_history` | 100 items | FIFO | — |
| `currency_cache` | 1 entry | overwrite | 1h soft TTL |
| `favorites` | unlimited | — | — |
| `world_time_state` | 1 entry | overwrite | — |

---

## 9. Engine & Conversion Logic Design

### 9.1 Calculator Engine

**Pipeline**:
```
Raw input → Tokenizer → Validator → Shunting-Yard (infix → RPN) → Evaluator → NumberFormatter → Display
```

**Tokens**: Number (double), Operator (`+−×÷^`), Function (sin/cos/.../log/ln/...), Constant (π/e/φ), Paren, Unary (`±`, `1/x`, `x²`, `√`, `∛`, `|x|`, `!`).

**Operator precedence** (cao → thấp): `^` (right-assoc) > unary > `× ÷` > `+ −`.

**Angle mode conversion**:
- `DEG → RAD`: `rad = deg × π / 180`
- `GRA → RAD`: `rad = gra × π / 200`
- Hàm trig nhận input RAD nội bộ.

**Error mapping**:
- `result.isNaN` → `OutOfRange`
- `result.isInfinite` → `OutOfRange`
- Tokenizer fail / Validator fail → `InvalidSyntax`
- Length > 50 → block input ở Bloc (không vào engine)

**Precision**: `double` (IEEE 754); làm tròn cuối qua `NumberFormatter`.

### 9.2 Currency Conversion

**Rate model**: base = `USD`, `rates[CODE] = double` (số đơn vị `CODE` per 1 USD).

**Convert**: `value_target = value_source × (rates[target] / rates[source])`.

**Normalize on input**:
- Ô đang focus = source.
- Compute tất cả ô còn lại đồng bộ.

**Refresh strategy**:
- TTL 1h soft.
- Manual `Refresh` bypass.
- Background fetch khi mở màn nếu hết hạn (non-blocking nếu có cache cũ).

### 9.3 Percentage Bidirectional

**Mode 1 (% of Number)** — 3 fields:
- `Result = Number × Percentage / 100`
- `Number = Result × 100 / Percentage`
- `Percentage = Result × 100 / Number`

Trigger: đủ 2/3 fields → solve field còn lại.

**Mode 2 (± % Change)** — 4 fields:
- `Change = Initial × Percentage / 100`
- `Final = Initial + sign × Change`
- `Percentage = |Change| × 100 / Initial`
- `Initial = Change × 100 / Percentage = Final − sign × Change`

Trigger: `Initial` + bất kỳ 1 field khác → solve toàn bộ.

**Conflict resolution** (3+ fields filled, user vừa sửa 1):
- Queue `modifiedFields` FIFO 2-slot.
- Field vừa sửa + field thứ 2 trong queue = "fixed".
- Các field khác được recompute.

### 9.4 World Time DST & Conversion

**Source of truth**: `timezone` package (bundled IANA tzdata, offline).

**Offset lookup**:
```
tz.Location loc = tz.getLocation(timezoneId)
tz.TZDateTime now = tz.TZDateTime.now(loc)
Duration offset = now.timeZoneOffset
bool isDST = loc.currentTimeZone.isDst    // hoặc check tại thời điểm cụ thể
```

**Reference Mode conversion**:
```
T_anchor_local = referenceTime (chọn bởi user)
T_anchor_utc = T_anchor_local − offset_anchor (DST-adjusted tại T_anchor_local)
For each target city:
  T_target_local = T_anchor_utc + offset_target (DST-adjusted tại T_anchor_utc + offset_target)
```

**DST flag**: append `(DST)` suffix vào tên city khi `loc.isDst(timestamp) == true`.

**Detect OS timezone change**: `flutter_timezone.getLocalTimezone()` mỗi lần app resume; so sánh với device card `timezoneId` lưu trong state.

---

## 10. State Management

### 10.1 Architectural pattern: **MVVM + Repository** (Cubit/Bloc as ViewModel)

| MVVM Term | Flutter Implementation |
|---|---|
| Model | Domain Entities + Repository Interfaces |
| View | Widget tree (presentation/screens/*.dart) |
| ViewModel | `Cubit` (simple state) hoặc `Bloc` (event-driven, complex state machine) |

**Lý do chọn Cubit/Bloc làm ViewModel**:
1. `flutter_bloc` đã là community standard cho MVVM trong Flutter — preserve toàn bộ technical_design.md hiện có.
2. Stream-based subscription tự nhiên hơn `ChangeNotifier` cho reactive settings.
3. Tooling tốt (BlocObserver, BlocSelector, BlocListener) — không phải reinvent.

**Alternative**: nếu team strict về MVVM classic, có thể dùng `ChangeNotifier` + `Provider` — chỉ cần đổi base class, không ảnh hưởng kiến trúc.

### 10.2 Provider Tree

```
MaterialApp
└── MultiBlocProvider (root)
    ├── AppConfigCubit         (global, persist SharedPreferences)
    ├── ThemesCubit            (global)
    ├── FavoritesCubit         (global, Hive)
    └── Router (go_router)
        ├── HomeShellCubit     (shell-scoped: tab index)
        ├── CalculatorBloc     (Calculator tab branch)
        ├── ConverterListCubit (Converter tab branch)
        ├── CurrencyConverterBloc (lazy, recreate khi navigate vào)
        ├── PercentageCubit    (lazy)
        ├── WorldTimeCubit     (lazy, có Timer)
        ├── SettingsCubit      (Settings tab branch)
        └── FeedbackCubit      (route-scoped)
```

### 10.3 Reactive Settings — Best Practices

- Dùng `BlocSelector<AppConfigCubit, AppConfigState, T>` để **chỉ rebuild khi field cần** thay đổi.
- Avoid `BlocBuilder` với selector lambda phức tạp — pre-compute và lưu trong state.
- `MaterialApp.locale` bind trực tiếp với `AppConfigCubit.state.language` → Flutter rebuild widget tree tự động khi language thay đổi.

### 10.4 Persistence Strategy

| ViewModel | Persistence | Trigger |
|---|---|---|
| `AppConfigCubit` | SharedPreferences | Mỗi `emit` (debounce ~100ms) |
| `CalculatorBloc` | SharedPreferences (`calc_draft`) | Mỗi expression change (debounce ~200ms) **khi keepCalculatorRecord = true** |
| `CurrencyConverterBloc` | SharedPreferences (`currency_last_*`) | Khi đổi currencies |
| `WorldTimeCubit` | Hive `world_time_state` | Khi add/remove/sort/reference change |
| `FavoritesCubit` | Hive `favorites` | Mỗi mutation |
| History repos | Hive (per box) | `add()` / `delete()` |

---

## 11. Navigation

### 11.1 Stack Structure (go_router StatefulShellRoute)

- **Root routes** (không trong shell): `/splash`, `/feedback`.
- **Shell branches** (giữ stack riêng per tab):
  - `/home/ai-tutor`
  - `/home/converter` + children
  - `/home/calculator` + children
  - `/home/settings` + children

### 11.2 Back Behavior Matrix

| Vị trí hiện tại | Action Back | Kết quả |
|---|---|---|
| Calculator tab (root) | System Back | Exit Confirmation Dialog |
| Tab khác (root) | System Back | Switch về Calculator tab |
| Sub-screen tool (vd Currency) | System Back / Bottom Bar `←` | Pop về screen cha (Converter List) |
| Calculator History | System Back | Pop về Calculator |
| Feedback (any source) | System Back | Pop về tool gọi Feedback |
| Settings sub-screen (Themes / Chat History) | System Back | Pop về Settings |

### 11.3 Deep Links

- `mailto:...` (Feedback) → external email client.
- `tel:`, `https://...` (Privacy, Rating, More Apps) → external browser/store.
- Launcher Shortcut (Android) → mở Calculator AI tại tool tương ứng (cần `navigation_flow.md` cụ thể hóa).

### 11.4 Tab State Preservation

`StatefulShellRoute.indexedStack` giữ Navigator stack mỗi branch. ViewModels theo branch → không bị dispose khi switch tab.

---

## 12. Technical Architecture

### 12.1 Folder Structure (Clean Architecture 3-layer)

```
lib/
├── core/
│   ├── constants/
│   ├── error/                  failures, exceptions
│   ├── utils/                  number_formatter, expression_validator, timezone_utils
│   └── theme/
│
├── features/
│   ├── calculator/
│   │   ├── domain/             entities, repositories (abstract), usecases
│   │   ├── data/               models (Hive), repository impls, datasources
│   │   └── presentation/       bloc, screens, widgets
│   ├── converter/
│   │   ├── list/
│   │   ├── currency/
│   │   ├── percentage/
│   │   └── world_time/
│   ├── settings/
│   ├── feedback/
│   └── ai_tutor/               (placeholder)
│
├── shared/
│   ├── widgets/                custom_keyboard, snackbar_helper, calculator_overlay
│   ├── blocs/                  app_config, favorites, theme
│   └── services/               haptic, sound, wakelock, mailto
│
├── l10n/                       ARB files
├── app.dart                    MaterialApp + providers + router
└── main.dart
```

### 12.2 DI (get_it + injectable)

- **Singleton**: `AppConfigRepository`, `CurrencyRepository` (with `Dio`), `Hive box` references.
- **LazySingleton**: Use cases (instances per feature).
- **Factory**: ViewModels (Cubit/Bloc) tạo mới mỗi screen.

### 12.3 Package List

| Concern | Package |
|---|---|
| State | `flutter_bloc`, `equatable` |
| Navigation | `go_router` ^14 |
| DI | `get_it`, `injectable` (+ build_runner) |
| Local DB | `hive_flutter` |
| Prefs | `shared_preferences` |
| HTTP | `dio` |
| Timezone | `timezone` |
| Detect TZ | `flutter_timezone` |
| I18n | `intl`, `flutter_localizations` |
| Wakelock | `wakelock_plus` |
| Battery | `battery_optimization_android` (Android only) |
| Share | `share_plus` |
| URL | `url_launcher` |
| Image | `image_picker` |
| Files | `path_provider` |
| Metadata | `package_info_plus`, `device_info_plus` |

### 12.4 I18n Architecture

- ARB files per locale (`app_en.arb`, `app_vi.arb`, ...).
- `flutter gen-l10n` → `AppLocalizations.of(context).key`.
- `MaterialApp.locale` bind với `AppConfigCubit.state.language`; rebuild tree khi đổi.
- Khi `language = system` → dùng `Platform.localeName`.
- City/country names tra qua `cityNameKey` trong ARB; tzid là IANA cố định.

### 12.5 Theme Architecture

- `AppTheme.light` / `AppTheme.dark` (`ColorScheme.fromSeed`).
- `ThemesCubit` emit `ThemeMode` → `MaterialApp.themeMode`.
- MVP chỉ có Light/Dark; nâng cấp tương lai có thể thêm `ColorScheme custom`.

---

## 13. Acceptance Criteria Coverage

### 13.1 Coverage Status

| Area | Total Criteria | Covered | Partial | Open |
|---|---|---|---|---|
| Navigation & Shell | 5 | 5 | 0 | 0 |
| Calculator | 12 | 12 | 0 | 0 |
| Currency Converter | 11 | 11 | 0 | 0 |
| Percentage Calculator | 7 | 7 | 0 | 0 |
| World Time | 12 | 11 | 1 (OS TZ change detect — `flutter_timezone` API surface) | 0 |
| Settings | 7 | 6 | 1 (Themes scope) | 0 |
| Feedback | 5 | 4 | 0 | 1 (email đích) |
| Permissions | — | 0 | — | All (cần `permission_system_flow.md`) |

### 13.2 Detailed Map (highlights)

#### Calculator
| AC | Covered by |
|---|---|
| Real-time preview | `CalculatorBloc.previewResult` |
| `=` lưu History | `CalculatorHistoryRepo.add` |
| Invalid syntax → Snackbar | `ErrorResult(InvalidSyntax)` event |
| Auto-replace operator | `CalculatorEngine.append` validator |
| Auto-close bracket | `evaluate()` preprocess |
| Long-press `()` wrap | Widget gesture handler |
| Draft persist | SharedPreferences via BlocObserver |
| Limit 50 chars | Guard ở `KeyPress` handler |
| DEG/RAD/GRA indicator | `state.showAngleIndicator` |
| Scientific → Basic sau insert hàm | `CalculatorBloc` state transition |
| Scientific notation `|x|≥1e15 / <1e-6` | `NumberFormatter` |
| History cap 100 FIFO | `CalculatorHistoryRepo.add` evict |

#### Currency Converter
| AC | Covered by |
|---|---|
| Cache TTL 1h | `CurrencyRepository.timestamp + 1h` |
| Manual refresh bypass | `fetchRates(forceRefresh: true)` |
| Offline + cache | `CurrencyLoadedOffline` state |
| Offline + no cache | `CurrencyError` + Retry |
| Real-time calc | `onValueChanged` cascade |
| Caution chỉ khi tap menu | Không có flag auto-show |
| Simple/Advanced toggle | `state.mode` |
| Simple→Advanced fallback | USD/JPY/AUD/CAD chain |
| Add Shortcut Android only | `Platform.isAndroid` guard |
| History restore | `CurrencyHistoryRepo` + Cubit |
| Footer ẩn Advanced | UI guard `state.mode == advanced` |

#### Percentage
| AC | Covered by |
|---|---|
| Bidirectional | `PercentageFormulaEngine` |
| Mode state preserve | `state.modeState[]` |
| Trường rỗng không lỗi | Engine returns `null` for unresolved |
| Decimal cap 3/6 | Input validator |
| History capacity | Repo evict |
| Title overlay = field name | `CalculatorOverlayDialog(fieldName)` |
| Commit timing (Share/toggle/back) | `PercentageCubit` lifecycle hooks |

#### World Time
| AC | Covered by |
|---|---|
| Device pinned top | `WorldTimeCubit` sort guard |
| Không xoá device | UI hide checkbox cho device card |
| DST + offset đúng | `timezone` package |
| Không thêm trùng | `WorldTimeCubit.add()` check |
| Sort device top | Sort logic exclude device |
| Reference mode | `referenceTime != null` |
| Nút Now ở header | UI conditional render |
| Indicator banner | UI conditional render |
| Long-press → Edit | GestureDetector + Cubit |
| Long-press device = no-op | Skip device card |
| OS TZ change | `flutter_timezone` on resume |
| Persistence Reference mode | Hive `world_time_state` |

#### Settings
| AC | Covered by |
|---|---|
| Instant apply | `AppConfigCubit` emit |
| Number Format re-render | BlocSelector ở mọi màn hình |
| Battery Opt Android only | `Platform.isAndroid` guard |
| Battery Opt ẩn khi exempt | Check on resume |
| Ẩn link nếu URL rỗng | Conditional render |
| Clear Chat confirm | Dialog |
| Themes Light/Dark | `ThemesCubit` ✅ MVP scope |

#### Feedback
| AC | Covered by |
|---|---|
| Mailto submit | `IFeedbackService.buildMailtoUri` |
| Single-select issue | UI radio behavior |
| Image attach | `image_picker` |
| Offline → Snackbar | Connectivity check |
| Metadata gồm app/os/device/lang | `package_info_plus + device_info_plus` |
| Email đích | ⚠️ Open (A8) |

### 13.3 Permissions Coverage — **GAP**

Chưa có `permission_system_flow.md`. Cần định nghĩa:
- Camera (Feedback image capture) — Android `CAMERA`, iOS `NSCameraUsageDescription`.
- Photo Library (Feedback image pick) — `READ_MEDIA_IMAGES` / `NSPhotoLibraryUsageDescription`.
- Battery Optimization (Android) — `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS`.
- Notification (Notification Shortcut — TBD).
- Internet (`INTERNET` permission Android, default trên iOS).

→ Block Phase 7 (Feedback) + Phase 1 (Settings Battery Opt).

---

## 14. Implementation Roadmap

### Phase 0 — Foundation (1–2 ngày)
- Project scaffold + `pubspec.yaml` packages.
- Folder structure Clean Architecture.
- DI setup (`get_it + injectable`).
- `go_router` skeleton (placeholder screens).
- Hive init + register adapters.
- I18n ARB (EN + VI base).
- `AppTheme` Light/Dark.
- `AppConfigCubit` + Repository.
- `NumberFormatter` utility + **unit tests ≥ 20**.

### Phase 1 — Shell + Settings (2–3 ngày)
- `HomeShell` 4-tab `StatefulShellRoute`.
- Back behavior (PopScope).
- Settings screen đầy đủ (System + Chat + Developer).
- Themes screen (Light/Dark toggle).
- Reactive language switch (hot-reload).
- Battery Optimization (Android).

### Phase 2 — Calculator (3–4 ngày)
- `CalculatorEngine` (Tokenizer + Shunting-Yard + Evaluator).
- `CalculatorBloc` (state machine, draft persist, rollback stack).
- Basic Keyboard (7×4) + Scientific Keyboard (7×4) widgets.
- Display Panel + Angle indicator + History preview.
- Calculator History Screen.
- **Unit tests ≥ 30** trên `CalculatorEngine`.

### Phase 3 — Converter List + Favorites (1–2 ngày)
- `ConverterListCubit` (search debounce, filter, categories).
- `FavoritesCubit` + Hive Repo.
- Favorites Grid + Manage Favorites mode.
- Empty state.

### Phase 4 — Currency Converter (3–4 ngày)
- `CurrencyRepository` (Dio + Hive cache, TTL 1h).
- `CurrencyConverterBloc` (Simple/Advanced, real-time calc, focus management, fallback chain USD/JPY/AUD/CAD).
- Currency Picker (search localized + English + ISO).
- Custom keypad 4×4 + `±=` Overlay launcher.
- Offline states (cache / no cache).
- Caution dialog (manual menu only).
- Share / Add Shortcut / History.
- Footer rate (ẩn Advanced).

### Phase 5 — Percentage Calculator (2–3 ngày)
- `PercentageFormulaEngine` (bidirectional, 2-slot modified queue).
- `PercentageCubit` (state preserve per mode, commit history at Share/toggle/back).
- Form Mode 1 (3 fields) + Mode 2 (4 fields).
- Keypad 5×4 (+/− disable ở Mode 1).
- Calculator Overlay (shared) integration.
- Calculation Formula dialog.
- History Screen + Share.
- **Unit tests ≥ 15** formula engine.

### Phase 6 — World Time (3–4 ngày)
- Integrate `timezone` + `flutter_timezone`.
- `WorldTimeCubit` (live ticker, reference mode, DST, sort, edit mode, long-press).
- Device card pinning.
- Add City Screen.
- Set Reference Time dialog + Date/Time Picker wheels (year range ± 100).
- Now button + Reference banner.
- Sort bottom-sheet 4 options.
- Edit mode multi-select delete.
- OS TZ change detection on resume.
- Persistence Reference mode qua restart.

### Phase 7 — Cross-cutting + Feedback (2–3 ngày)
- `HapticService`, `SoundService`, `WakelockService`.
- **`permission_system_flow.md`** (cần stakeholder duyệt).
- Feedback Screen (dropdown, single-select issues, textarea, image, Submit → mailto).
- Offline submit → Snackbar (no queue).
- Metadata builder (`package_info_plus + device_info_plus`).
- Error UX (Snackbar helper, global handler).
- App Widget / Notification Shortcut / Launcher Shortcut (placeholder hoặc basic — pending OQ3/OQ4).

### Phase 8 — AI Tutor Placeholder + Chat (1 ngày)
- AI Tutor tab UI placeholder.
- Chat History screen (empty + danh sách).
- Clear Chat History (confirm + Hive clear).

### Phase 9 — QA & Polish (3–5 ngày)
- Unit tests targets đầy đủ (xem `architecture.md` §9).
- Widget tests cho key screens.
- Integration tests cho happy paths.
- Accessibility audit (content descriptions, contrast).
- Performance check (60fps, debounce, scroll).
- Edge cases (offline, OS TZ change, rapid toggle, large numbers).
- Localization review EN + VI.
- Build release APK + IPA.

**Tổng**: ~21–28 ngày dev cho team 1 mid-senior + 1 junior, song song hợp lý.

---

## 15. Dev Handoff Checklist

### Trước khi code 1 feature

- [ ] Đọc file `feature_*.md` tương ứng — source of truth chi tiết nhất.
- [ ] Đọc `ui_notes.md` cho design tokens.
- [ ] Đọc `technical_design.md` cho engine/data design.
- [ ] Đọc `solution_architecture_review.md` (file này) cho cross-cutting concerns.
- [ ] Kiểm tra Open Questions tại §17 — không tự assume thêm.
- [ ] Xác nhận data model trong `architecture.md` trước khi viết Hive model.
- [ ] Xác nhận route trong `navigation_flow.md` (tạo nếu chưa có).
- [ ] Xác nhận permission trong `permission_system_flow.md` nếu feature đụng tới quyền hệ thống.

### Conventions

- Tên biến/hàm: `camelCase`; class/widget: `PascalCase`; hằng số: `UPPER_SNAKE_CASE`.
- Không hardcode string hiển thị → `AppLocalizations`.
- Mọi số hiển thị phải qua `NumberFormatter.format()`.
- Mọi async I/O phải try-catch → map sang `Failure`.
- ViewModel KHÔNG import Flutter widgets (chỉ import `flutter_bloc` cho event/state base).

### Testing Targets

| Component | Min tests |
|---|---|
| `CalculatorEngine` | 30 (gồm chia 0, overflow, trig DEG/RAD/GRA) |
| `NumberFormatter` | 20 (gồm scientific notation 2 ngưỡng) |
| `PercentageFormulaEngine` | 15 (mode 1, mode 2, conflict resolution) |
| `CurrencyRepository` cache logic | 10 (TTL, offline, force refresh) |
| `WorldTimeCubit` DST + reference | 10 (DST switch, OS TZ change, day boundary) |

---

## 16. Recommended File Implementation Order

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
10. features/calculator/presentation/           ← integration với engine
11. features/converter/list/ + favorites
12. features/converter/currency/                ← Dio + cache
13. shared/widgets/calculator_overlay.dart      ← Currency cần overlay
14. features/converter/percentage/              ← dùng overlay
15. features/converter/world_time/              ← timezone package
16. shared/widgets/ (keyboard, dialogs, snackbar)
17. shared/services/ (haptic, sound, wakelock)
18. features/feedback/                          ← cần mailto + permission
19. features/ai_tutor/ + chat history          ← placeholder
20. Phase 7 cross-cutting (widget, notification, shortcut)
21. QA pass
```

---

## 17. Open Questions

### 17.1 Block Phase tương ứng

| # | Câu hỏi | Block Phase | Priority |
|---|---|---|---|
| OQ1 | **Email mailto đích** (vd `support@tohsoft.com`?) | Phase 7 (Feedback) | 🔴 High |
| OQ2 | **List preset Feedback issues** đầy đủ — nội dung từng item | Phase 7 | 🔴 High |
| ~~OQ3~~ | ~~`navigation_flow.md`~~ | — | ✅ Closed |
| ~~OQ4~~ | ~~`permission_system_flow.md`~~ | — | ✅ Closed |
| OQ5 | **Help link URL** — nội bộ hay ngoài? | Phase 1 (Settings) | 🟡 Medium |
| OQ6 | **Startup Calculator** option list đầy đủ | Phase 1 | 🟡 Medium |
| OQ7 | **App Widget** nội dung + kích thước | Phase 7 | 🟡 Medium |
| OQ8 | **Notification Shortcut** dẫn tới tính năng nào | Phase 7 | 🟡 Medium |
| OQ9 | **Launcher Shortcut** scope (icon đơn / widget tương tác) | Phase 7 | 🟡 Medium |
| OQ10 | **Currency API endpoint** + auth scheme cụ thể | Phase 4 | 🟡 Medium |
| OQ11 | **Percentage History commit timing** xác nhận (Share/toggle/back) | Phase 5 | 🟢 Low |
| OQ12 | **Chat History** xoá theo khoảng thời gian | Phase 8 | 🟢 Low |

### 17.2 Architectural decision còn open

| # | Decision | Recommendation |
|---|---|---|
| AD1 | MVVM ViewModel: `Cubit/Bloc` hay `ChangeNotifier`? | **Cubit/Bloc** — preserve technical_design hiện có, tooling tốt hơn |
| AD2 | Currency cache TTL = 1h cố định hay configurable? | **1h cố định** trong MVP (A1) |
| AD3 | Calculator History capacity 100 — hard cap hay configurable? | **100 hard cap** (đã chốt C20) |
| AD4 | Themes: chỉ Light/Dark hay có theme custom? | **Light/Dark only MVP** (A7) |

---

## 18. Tóm tắt deliverable

Bộ tài liệu hiện tại **đã sẵn sàng cho team start Phase 0**, với điều kiện:
1. Đóng OQ1, OQ2 (email đích + preset issues) trước Phase 7.
2. Tạo `navigation_flow.md` + `permission_system_flow.md` trước Phase 1.
3. Xác nhận OQ10 (Currency API) trước Phase 4.

Các Open Questions còn lại (🟡 / 🟢) có thể defer mà không block phase trước.

**Next concrete steps** đề xuất:
1. Session review với stakeholder để đóng OQ1, OQ2, OQ10 (🔴 còn lại) trong ≤ 1 buổi.
2. Stakeholder duyệt `navigation_flow.md` + `permission_system_flow.md` đã draft.
3. Khoá baseline → tag `spec-v1.0` → bắt đầu Phase 0.
