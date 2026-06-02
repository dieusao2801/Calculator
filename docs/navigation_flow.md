# navigation_flow.md — Calculator AI

Tài liệu mô tả luồng điều hướng tổng quát của app: cấu trúc route, back stack, deep links, tab state preservation, modal/dialog navigation.

Bám: `feature_spec.md`, `technical_design.md`, `solution_architecture_review.md`.

---

## 1. Mô tả (Description)

Calculator AI dùng `go_router v14+` với **`StatefulShellRoute`** để giữ navigator stack độc lập cho mỗi tab. Mặc định mở tại tab **Calculator**. Back hệ thống có hành vi đặc biệt: từ tab khác về Calculator; tại Calculator hiện Exit Confirmation Dialog.

---

## 2. Cấu trúc Route

### 2.1 Route Map

| Path | Screen | Trong shell? | Notes |
|---|---|---|---|
| `/splash` | Splash | ❌ | Init AppConfig, kiểm tra Battery Opt, then navigate Home |
| `/home/ai-tutor` | AI Tutor (placeholder) | ✅ Branch 0 | — |
| `/home/converter` | Converter List | ✅ Branch 1 | — |
| `/home/converter/currency` | Currency Converter | ✅ Branch 1 | — |
| `/home/converter/currency/history` | Currency History | ✅ Branch 1 | — |
| `/home/converter/percentage` | Percentage Calculator | ✅ Branch 1 | — |
| `/home/converter/percentage/history` | Percentage History | ✅ Branch 1 | — |
| `/home/converter/world-time` | World Time Converter | ✅ Branch 1 | — |
| `/home/converter/world-time/add` | Add City | ✅ Branch 1 | — |
| `/home/calculator` | Calculator | ✅ Branch 2 (**default**) | — |
| `/home/calculator/history` | Calculator History | ✅ Branch 2 | — |
| `/home/settings` | Settings | ✅ Branch 3 | — |
| `/home/settings/themes` | Themes | ✅ Branch 3 | — |
| `/home/settings/chat-history` | Chat History | ✅ Branch 3 | AI Tutor logs |
| `/feedback?source=<toolId>` | Feedback | ❌ | Shared, push trên top shell |

### 2.2 Cây navigation

```
GoRouter
├── /splash                           (no shell)
├── /feedback?source=...              (no shell, modal-style)
└── StatefulShellRoute (HomeShell)
    ├── Branch 0: /home/ai-tutor
    ├── Branch 1: /home/converter
    │   ├── /home/converter/currency
    │   │   └── /home/converter/currency/history
    │   ├── /home/converter/percentage
    │   │   └── /home/converter/percentage/history
    │   └── /home/converter/world-time
    │       └── /home/converter/world-time/add
    ├── Branch 2: /home/calculator    ← initialLocation
    │   └── /home/calculator/history
    └── Branch 3: /home/settings
        ├── /home/settings/themes
        └── /home/settings/chat-history
```

---

## 3. Thành phần điều hướng (UI Components)

### 3.1 Bottom Navigation (HomeShell)
- 4 tab cố định: **AI Tutor · Converter · Calculator · Settings**.
- Tab active có màu primary (cam) cho icon + label.
- Tap tab → `shellNavigator.goBranch(index)` — giữ stack tab hiện tại.

### 3.2 Bottom Bar tool (sub-screen của Converter)
Ẩn Bottom Nav app, hiện Bottom Bar riêng:
- `← (back)` — pop về screen cha (Converter List).
- Tiêu đề tool.
- `[icon calculator overlay]` — mở Calculator Overlay (Currency, Percentage). **Ẩn ở World Time.**
- `⋮ (menu)` — menu tool.

### 3.3 Header sub-screen Settings
Sub-screen Settings (Themes, Chat History) dùng header chuẩn AppBar `← Title`.

### 3.4 Modal / Dialog
Không có route riêng — dùng `showDialog` / `showModalBottomSheet` trên màn hiện tại:
- Currency Picker (bottom sheet).
- Add City modal (full-screen modal).
- Set Reference Time Dialog.
- Date Picker / Time Picker.
- Add Shortcut Dialog.
- Caution Dialog.
- Share Dialog.
- Calculator Overlay (semi-modal).
- Exit Confirmation Dialog.
- Manage Favorites mode (in-place state change, không phải dialog).

---

## 4. Hành động / Kết quả (Actions / Results)

### 4.1 App Startup

| Hành động | Kết quả |
|---|---|
| Mở app lần đầu | Splash → load AppConfig → init Hive → push `/home/calculator` |
| Mở app từ Launcher Shortcut (Android) | Splash → push `/home/<target_route>` theo shortcut |
| Mở app từ deep link / notification | Splash → push deep link target (nếu hợp lệ) hoặc default `/home/calculator` |

### 4.2 Tab Switch

| Hành động | Kết quả |
|---|---|
| Tap tab khác | `goBranch(index)`. Giữ stack tab cũ + stack tab mới. Tự ẩn bàn phím qua `FocusScope.unfocus()`. |
| Tap lại tab đang active | Pop về root của tab đó (vd Currency Converter → Converter List). |

### 4.3 System Back

| Vị trí | System Back | Kết quả |
|---|---|---|
| `/home/calculator` (root, default) | — | Exit Confirmation Dialog |
| `/home/calculator/history` | pop | Về Calculator |
| `/home/converter` (root tab phụ) | switch | Về Calculator tab (giữ stack Converter) |
| `/home/converter/currency` | pop | Về Converter List |
| `/home/converter/currency/history` | pop | Về Currency Converter |
| `/home/converter/world-time/add` | pop | Về World Time (modal close) |
| `/home/settings` (root tab phụ) | switch | Về Calculator tab |
| `/home/settings/themes` | pop | Về Settings |
| `/home/ai-tutor` (root) | switch | Về Calculator tab |
| `/feedback?source=*` | pop | Về tool gọi Feedback |
| Dialog đang mở (bất kỳ) | đóng dialog | Giữ nguyên screen |

### 4.4 Cross-tab Navigation

| Hành động | Kết quả |
|---|---|
| Menu tool → `Settings` | Push `/home/settings` trên top shell **VÀ** switch branch sang Settings tab; back từ Settings về tool gọi (deep-link history). |
| Menu tool → `Feedback` | Push `/feedback?source=<toolId>` (ngoài shell); back về tool gọi. |
| Menu tool → `Calculator (Bottom Bar icon)` | Mở Calculator Overlay (KHÔNG switch tab). |
| Settings → `Report Problem` | Push `/feedback?source=settings`. |
| Settings → `Chat History` | Push `/home/settings/chat-history`. |
| Settings → `Themes` | Push `/home/settings/themes`. |

### 4.5 Exit App

| Hành động | Kết quả |
|---|---|
| Back tại Calculator | Exit Confirmation Dialog: `Cancel / Exit`. Tap `Exit` → `SystemNavigator.pop()`. |
| Swipe back gesture (iOS) | Tuân theo native pop behavior trừ Calculator root → confirm. |

---

## 5. Deep Links

### 5.1 Internal Deep Links (intra-app)

| Source | Target | Notes |
|---|---|---|
| Launcher Shortcut "Calculator" | `/home/calculator` | Android only |
| Launcher Shortcut "Currency" | `/home/converter/currency` | Android only |
| Launcher Shortcut "Percentage" | `/home/converter/percentage` | Android only |
| Launcher Shortcut "World Time" | `/home/converter/world-time` | Android only |
| Notification Shortcut tap | `/home/calculator` (default, MVP placeholder — chờ stakeholder chốt) | — |

### 5.2 External Deep Links (out-app)

| Trigger | Scheme | Notes |
|---|---|---|
| Settings → Privacy Policy | `https://...` (`AppConfig.privacyUrl`) | `url_launcher`; ẩn item nếu URL rỗng |
| Settings → Rate us 5 stars | `https://play.google.com/...` hoặc `https://apps.apple.com/...` (`storeUrl`) | Ẩn nếu URL rỗng |
| Settings → Share app | System Share Sheet với `storeUrl` payload | `share_plus` |
| Settings → More Apps | `https://...` (`moreAppsUrl`) | Ẩn nếu URL rỗng |
| Settings → Help | `https://...` (`helpUrl`) hoặc internal screen — **OQ5** | — |
| Feedback Submit | `mailto:<support_email>?subject=...&body=...&attachment=...` | OQ1 chốt email đích |
| Battery Optimization (Android) | `Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` intent | Native bridge |
| Add Shortcut (Android) | `ShortcutManager.requestPinShortcut()` | Native bridge |

### 5.3 Inbound Deep Link Handling (MVP)

MVP **không hỗ trợ inbound URL scheme** (vd `calculator://...`). Chỉ Launcher Shortcut + Notification Shortcut tự app tạo ra.

---

## 6. Tab State Preservation

### 6.1 Rule

`StatefulShellRoute.indexedStack` giữ Navigator + state mỗi branch độc lập:
- Switch tab không dispose Bloc/Cubit của branch.
- Switch tab không pop stack của branch.
- Vào lại tab → state cũ y nguyên (text field, expression, scroll position).

### 6.2 Exceptions (Reset state khi switch)

| Trường hợp | Reset |
|---|---|
| Calculator Draft khi `keepCalculatorRecord = false` | Reset expression về rỗng khi rời tab Calculator |
| Currency Converter focus | Bỏ focus + ẩn bàn phím khi rời tab |
| World Time Edit Mode | Thoát Edit Mode (bỏ chọn) khi rời tab |
| Percentage Calculator | KHÔNG reset (giữ state cho cả 2 mode) |

### 6.3 Lifecycle Cubit/Bloc theo tab

| ViewModel | Scope | Reset trigger |
|---|---|---|
| `AppConfigCubit`, `ThemesCubit`, `FavoritesCubit` | Global (provided ở root) | Chỉ khi app killed |
| `HomeShellCubit` | Shell | Khi shell dispose (rare) |
| `CalculatorBloc` | Calculator branch | Khi branch dispose |
| `ConverterListCubit`, `CurrencyConverterBloc`, `PercentageCubit`, `WorldTimeCubit` | Converter branch | Khi branch dispose |
| `SettingsCubit` | Settings branch | Khi branch dispose |
| `FeedbackCubit` | Route-scoped (Feedback screen) | Khi pop Feedback |
| History cubits (Calculator/Currency/Percentage) | Route-scoped (History screen) | Khi pop History |

---

## 7. Business Rules

1. **Default tab**: Calculator (index 2) khi mở app lần đầu hoặc không có deep link.
2. **Back behavior**: 1 quy tắc chung — pop trong tab; nếu đã ở root tab phụ → switch về Calculator; tại Calculator root → Exit Dialog.
3. **Cross-tab navigation từ menu tool**: `Settings` SWITCH BRANCH (về Settings tab); `Feedback` PUSH ngoài shell.
4. **Modal/Dialog không pollute back stack route**: dùng `showDialog` thay vì push route.
5. **Bottom Nav ẩn**: khi vào sub-screen tool (Currency/Percentage/World Time), ẩn Bottom Nav app, hiện Bottom Bar tool. Back về Converter List → hiện lại Bottom Nav app.
6. **Calculator Overlay**: KHÔNG push route — dùng `showDialog` semi-modal.
7. **Tab switch dismiss keyboard**: `FocusScope.of(context).unfocus()` mỗi lần `goBranch()`.
8. **Launcher Shortcut**: chỉ Android; iOS ẩn entry.
9. **Exit Confirmation**: dùng `PopScope(canPop: false, onPopInvoked: ...)` ở Calculator root.
10. **Deep link mailto / external URL**: Mở qua `url_launcher`; nếu không có app handler → Snackbar lỗi.

---

## 8. Edge Cases

1. **App killed trong sub-screen** (vd `/home/converter/currency`) → mở lại: navigate về default `/home/calculator` (KHÔNG restore deep route). MVP đơn giản.
2. **Tab Calculator có Calculator History đang mở** → tap tab Calculator → pop về Calculator (không stack 2 lần).
3. **Tap nhanh nhiều tab liên tiếp** → debounce nhẹ (~100ms) để tránh state corruption.
4. **System gesture back trên iOS từ giữa sub-screen** → giống System Back.
5. **Feedback từ Settings → tap back trong Feedback** → về Settings (đúng source).
6. **Switch tab khi đang trong Edit Mode World Time** → tự thoát Edit Mode (bỏ chọn).
7. **Mở app từ deep link Launcher Shortcut khi app đang chạy background** → bring to foreground + navigate target.
8. **Currency History đang mở + đổi tab → quay lại Converter tab** → vẫn ở Currency History (stack preserved).
9. **Exit Dialog mở → tap ngoài** → đóng dialog, không exit.
10. **Push `/feedback` khi đang trong `/feedback`** (edge case nếu trigger 2 lần) → replace, không stack.

---

## 9. Tham chiếu

- Route + Cubit mapping: `solution_architecture_review.md` §7 + `technical_design.md` §7.
- Back behavior code-level: `technical_design.md` §11.2.
- Tab branches code-level: `technical_design.md` §11.1.

---

## 10. Open Questions

| # | Câu hỏi | Block |
|---|---|---|
| NF-1 | Inbound URL scheme (vd `calculator://...`)? | Out of scope MVP |
| NF-2 | Restore deep route khi app killed | Out of scope MVP (mặc định về Calculator) |
| NF-3 | Notification Shortcut target cụ thể | Phase 7 — OQ8 |
| NF-4 | Launcher Shortcut list đầy đủ (chỉ Calculator hay tất cả tool?) | Phase 7 — OQ9 |
| NF-5 | Behavior khi tap tab đang active 2 lần liên tiếp: pop root vs scroll to top? | Phase 1 |
