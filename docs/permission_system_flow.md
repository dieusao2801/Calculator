# permission_system_flow.md — Calculator AI

Tài liệu mô tả luồng xin/sử dụng/xử lý các quyền hệ thống của app trên Android & iOS.

Bám: `feature_spec.md`, `technical_design.md`, `solution_architecture_review.md`, `feature_converter.md` §3 (Feedback).

---

## 1. Mô tả (Description)

Calculator AI là app **offline-first, đơn người dùng, không tài khoản**. Quyền hệ thống yêu cầu **tối thiểu**:

| Permission | Trigger | Phase |
|---|---|---|
| Camera | Feedback → tap icon camera → chụp ảnh đính kèm | Phase 7 |
| Photo Library / Storage | Feedback → tap icon camera → chọn ảnh từ gallery | Phase 7 |
| Internet | Currency Converter (refresh tỷ giá) | Phase 4 |
| Battery Optimization (Android) | Settings → Battery Optimization → mở settings hệ thống | Phase 1 |
| Notification (Notification Shortcut placeholder) | Phase 7 — chờ stakeholder OQ8 | Phase 7 |
| Launcher Shortcut (Android) | Settings → Launcher Shortcut + menu tool → Add Shortcut | Phase 7 |

**Nguyên tắc chung**:
1. **Just-in-time request** — chỉ xin quyền khi tính năng được trigger, không xin lúc startup.
2. **Rationale dialog** trước system permission dialog nếu hệ thống không tự show.
3. **Graceful degradation** — từ chối quyền không crash app, có fallback rõ ràng.
4. **Re-request flow** — chỉ rationale + redirect Settings hệ thống nếu user đã chọn "Don't ask again".

---

## 2. Permission Inventory

### 2.1 Android — `AndroidManifest.xml`

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />

<!-- Camera (Feedback image capture) -->
<uses-permission android:name="android.permission.CAMERA" />
<uses-feature android:name="android.hardware.camera" android:required="false" />

<!-- Photo Library (Feedback image pick) -->
<!-- API 33+ (Android 13+) -->
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
<!-- API ≤ 32 -->
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"
    android:maxSdkVersion="32" />

<!-- Battery Optimization exemption -->
<uses-permission android:name="android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS" />

<!-- Notification (Android 13+) -->
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />

<!-- Launcher Shortcut (no permission needed; chỉ cần API call) -->
```

### 2.2 iOS — `Info.plist`

```xml
<key>NSCameraUsageDescription</key>
<string>Cho phép Calculator AI truy cập camera để chụp ảnh đính kèm khi gửi phản hồi.</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>Cho phép Calculator AI chọn ảnh từ thư viện để đính kèm khi gửi phản hồi.</string>

<!-- iOS không cần khai báo INTERNET; mặc định cho phép. -->
<!-- iOS không có Battery Optimization tương đương. -->
<!-- iOS không có Launcher Shortcut tương đương cho 3rd-party app. -->

<!-- Notification (nếu Notification Shortcut được implement trên iOS) -->
<!-- iOS dùng runtime API requestAuthorization() - không cần Info.plist key riêng -->
```

---

## 3. Permission Flows

### 3.1 Camera (Feedback)

**Trigger**: User mở Feedback → tap icon camera → chọn "Camera".

**Flow**:
```
User tap "Camera"
  → Check permission status
     ✓ Granted    → Mở camera → user chụp → trả ảnh path → preview trong Feedback
     ✗ Denied (chưa hỏi) → Show System Permission Dialog
        ✓ Allow   → Mở camera (như trên)
        ✗ Deny    → Snackbar `"Cần quyền Camera để chụp ảnh"` + đóng action
     ✗ Permanently denied → Rationale Dialog:
        Title: "Cần quyền truy cập camera"
        Body: "Vui lòng bật quyền Camera trong Cài đặt để chụp ảnh đính kèm."
        Buttons: [Cancel] [Open Settings]
        → Open Settings → mở `app_settings`
```

**Fallback**: User vẫn submit Feedback được mà không có ảnh.

### 3.2 Photo Library / Storage (Feedback)

**Trigger**: User mở Feedback → tap icon camera → chọn "Gallery".

**Flow** (Android 13+):
```
User tap "Gallery"
  → Check READ_MEDIA_IMAGES
     ✓ Granted    → Mở picker → chọn ảnh → trả path → preview
     ✗ Denied (chưa hỏi) → Show System Permission Dialog
        ✓ Allow / Limited → Mở picker
        ✗ Deny    → Snackbar `"Cần quyền truy cập ảnh để đính kèm"`
     ✗ Permanently denied → Rationale Dialog → Open Settings
```

**Flow** (Android ≤ 12 / iOS): tương tự nhưng dùng `READ_EXTERNAL_STORAGE` (Android) hoặc `NSPhotoLibraryUsageDescription` (iOS).

**Fallback**: User submit Feedback không kèm ảnh.

**Lưu ý iOS Limited Photo Access** (iOS 14+):
- User có thể chọn "Selected Photos" → app chỉ thấy ảnh được chọn.
- App vẫn hoạt động bình thường; user thấy giới hạn lựa chọn trong picker hệ thống.

### 3.3 Internet (Currency Converter)

**Trigger**: Mở Currency Converter / tap `Refresh` menu.

**Flow**:
```
Mở Currency Converter
  → Check cache TTL (1h)
     ✓ Còn hạn → Dùng cache, không cần network
     ✗ Hết hạn → Fetch API
        → Check connectivity (connectivity_plus)
           ✓ Có mạng → Dio fetch
              ✓ thành công → cập nhật cache + UI
              ✗ HTTP error / timeout → Snackbar + giữ cache cũ (nếu có)
           ✗ Không mạng → 
              • Có cache → emit Offline state, dùng cache, footer cảnh báo
              • Không cache → màn lỗi + nút Retry
```

**Không có dialog xin quyền Internet** — `INTERNET` là normal permission, granted khi cài đặt.

**Fallback offline**: cache + Snackbar.

### 3.4 Battery Optimization (Android only)

**Trigger**: Settings → tap `Battery Optimization` row.

**Flow**:
```
Check: PowerManager.isIgnoringBatteryOptimizations(packageName)
   ✓ Already exempted → Ẩn row hoàn toàn (không hiển thị)
   ✗ Chưa exempted → Show row
      → User tap row
         → Open intent: ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS
            (Mở Settings hệ thống đến trang Battery Optimization cho app)
         → User chọn:
            • "Allow" → Quay lại app (onResume) → recheck → ẩn row
            • "Deny"  → Quay lại app → row vẫn hiển thị, không nhắc lại
```

**Recheck timing**: Mỗi khi `WidgetsBindingObserver.didChangeAppLifecycleState(AppLifecycleState.resumed)`.

**Không có rationale dialog** — Settings system tự hiển thị chi tiết.

**Fallback**: App vẫn chạy bình thường; chỉ có thể bị OS kill khi background.

### 3.5 Notification (Notification Shortcut — MVP placeholder)

**Trigger**: User bật Notification Shortcut trong Settings (TBD — chờ OQ8).

**Flow** (Android 13+):
```
User toggle Notification Shortcut ON
  → Check POST_NOTIFICATIONS permission
     ✓ Granted    → Tạo persistent notification
     ✗ Denied (chưa hỏi) → System Permission Dialog
        ✓ Allow   → Tạo notification
        ✗ Deny    → Toggle về OFF + Snackbar `"Cần quyền Thông báo để hiển thị shortcut"`
     ✗ Permanently denied → Rationale Dialog → Open Settings
```

**Android ≤ 12**: Notification permission tự cấp; không cần xin runtime.
**iOS**: dùng `UNUserNotificationCenter.requestAuthorization` (alert + sound).

**Fallback**: User dùng app bình thường, chỉ thiếu shortcut trên thanh notification.

### 3.6 Launcher Shortcut (Android only)

**Trigger**:
- Settings → tap `Launcher Shortcut` → tạo shortcut chính.
- Menu tool → tap `Add Shortcut` → tạo shortcut cho tool đó.

**Flow**:
```
User tap Add Shortcut
  → Hiển thị Add Shortcut Dialog: "Do you want to add this converter shortcut to home screen?"
  → User tap OK
     → Check: ShortcutManager.isRequestPinShortcutSupported()
        ✓ Supported → ShortcutManager.requestPinShortcut(info)
           → OS hiển thị system prompt "Add to Home screen?"
              • User accept → shortcut xuất hiện trên Home screen
              • User decline → không có hành động phụ
        ✗ Not supported (vd MIUI cũ, launcher không hỗ trợ) → Snackbar lỗi `"Trình khởi chạy không hỗ trợ tính năng này"`
```

**iOS**: KHÔNG có Launcher Shortcut tương đương → menu item `Add Shortcut` **ẩn hoàn toàn** trên iOS.

**Fallback**: User dùng app qua icon chính bình thường.

---

## 4. Rationale Dialog Template

### 4.1 Layout chuẩn

```
Title: "Cần quyền truy cập <permission name>"
Body: <Mô tả ngắn lý do app cần quyền + chức năng sẽ bị giới hạn nếu từ chối>
Buttons:
  - [Cancel]        ← Đóng dialog, không có action
  - [Open Settings] ← Mở settings hệ thống của app (deep-link)
```

### 4.2 Rationale Texts (gợi ý — sẽ localize qua ARB)

| Permission | Title | Body |
|---|---|---|
| Camera | "Cần quyền truy cập camera" | "Vui lòng bật quyền Camera trong Cài đặt để chụp ảnh đính kèm khi gửi phản hồi." |
| Photos | "Cần quyền truy cập ảnh" | "Vui lòng bật quyền truy cập Ảnh trong Cài đặt để chọn ảnh đính kèm khi gửi phản hồi." |
| Notification | "Cần quyền Thông báo" | "Vui lòng bật quyền Thông báo trong Cài đặt để hiển thị shortcut nhanh trên thanh thông báo." |

---

## 5. Business Rules

1. **Just-in-time**: KHÔNG xin quyền tại Splash. Chỉ xin khi user trigger tính năng cần quyền.
2. **Rationale trước system dialog**: Nếu hệ thống đã hiển thị dialog 1 lần và user "Don't ask again" → app phải hiển thị Rationale Dialog với hướng dẫn mở Settings.
3. **Recheck on resume**:
   - Battery Optimization: recheck mỗi resume.
   - Camera / Photos / Notification: recheck khi user mở action liên quan, không cần background recheck.
4. **Permanently denied**: chỉ rationale + redirect Settings. KHÔNG show system dialog lần 2 (system block).
5. **Ẩn UI khi platform không hỗ trợ**:
   - `Add Shortcut`, `Battery Optimization`, `Launcher Shortcut` Settings → ẩn hoàn toàn trên iOS.
   - `Notification Shortcut` → behavior khác giữa Android/iOS nhưng UI giữ nguyên.
6. **Fallback luôn graceful**: từ chối quyền không crash, không block toàn app — chỉ disable tính năng cụ thể.
7. **Không xin Internet runtime** — `INTERNET` là normal permission Android, tự granted khi cài.
8. **Image picker iOS Limited Access**: chấp nhận; không yêu cầu Full Access.
9. **Permission state cache**: KHÔNG cache trạng thái permission trong app — luôn query OS API (rẻ, đảm bảo accuracy).

---

## 6. Edge Cases

1. **User accept Camera nhưng đóng camera giữa chừng (back hardware)** → trả về Feedback không có ảnh; KHÔNG báo lỗi.
2. **Camera permission granted, nhưng device không có camera** → `image_picker` throws → Snackbar `"Thiết bị không có camera"`.
3. **Photo picker iOS Limited Access user chỉ chọn 1 ảnh** → picker chỉ hiển thị ảnh đó → user chọn → trả về bình thường.
4. **Battery Optimization Settings system mở rồi user back chứ không thao tác** → recheck on resume → row vẫn hiển thị.
5. **App update gồm permission mới (vd thêm POST_NOTIFICATIONS Android 13)** → App build sẽ tự xử lý theo OS API level; với Android < 13 không cần runtime request.
6. **User xoá ảnh đã đính kèm trong gallery sau khi đã pick** → khi Submit mailto, attachment có thể fail → fallback ghi chú trong body.
7. **User từ chối POST_NOTIFICATIONS** → toggle Notification Shortcut tự revert OFF + lưu state user choice + không tự pop dialog lại.
8. **Launcher không hỗ trợ pinShortcut** (vd MIUI cũ, custom launcher) → Snackbar; không crash.
9. **Battery Opt exempt nhưng user revoke từ Settings hệ thống bên ngoài app** → recheck on resume → row hiển thị lại.
10. **iOS user trên menu tool xem `Add Shortcut`** → KHÔNG thấy item (đã ẩn theo Platform.isIOS).

---

## 7. Implementation Notes

### 7.1 Package suggestions

| Concern | Package |
|---|---|
| Permission generic | `permission_handler` v11+ |
| Camera + Gallery | `image_picker` (đã có trong technical_design) |
| Battery Optimization Android | `battery_optimization` hoặc native channel custom |
| Launcher Shortcut Android | `quick_actions` hoặc native channel custom |
| Open Settings | `app_settings` (cross-platform) |
| Connectivity check | `connectivity_plus` |

### 7.2 Mapping ViewModel

| Permission | ViewModel handle | Service helper |
|---|---|---|
| Camera | `FeedbackCubit.requestCamera()` | `PermissionService.camera()` |
| Photos | `FeedbackCubit.requestPhotos()` | `PermissionService.photos()` |
| Battery Opt | `SettingsCubit.checkBatteryOpt()` | `PermissionService.batteryOptimization()` |
| Notification | `SettingsCubit.toggleNotificationShortcut()` | `PermissionService.notification()` |
| Launcher Shortcut | `SettingsCubit.addLauncherShortcut()` | `LauncherShortcutService.create()` |

### 7.3 Lifecycle hooks

- `WidgetsBindingObserver.didChangeAppLifecycleState(AppLifecycleState.resumed)` → trigger recheck Battery Optimization.
- KHÔNG dùng để recheck Camera/Photos/Notification (chỉ check khi action trigger).

---

## 8. Acceptance Criteria

| AC | Covered by |
|---|---|
| User được hỏi quyền chỉ khi cần (just-in-time) | Each Cubit gọi `PermissionService` khi action |
| User từ chối quyền → app vẫn chạy bình thường | Fallback Snackbar + disable tính năng cụ thể |
| User "Don't ask again" → có hướng dẫn mở Settings | Rationale Dialog → `app_settings.openAppSettings()` |
| Battery Optimization row ẩn khi đã exempt | `PermissionService.isBatteryOptIgnored()` + UI conditional |
| Battery Opt recheck on resume | `WidgetsBindingObserver` |
| iOS không hiển thị Battery Opt / Add Shortcut | `Platform.isIOS` guard |
| iOS Limited Photo Access hoạt động bình thường | `image_picker` default behavior |
| Android 13+ POST_NOTIFICATIONS xử lý đúng | `permission_handler.notification` |
| Permission state luôn fresh (không cache) | Query OS API mỗi lần |

---

## 9. Open Questions

| # | Câu hỏi | Block |
|---|---|---|
| PSF-1 | **Email mailto cần permission email gì không?** | None — `url_launcher mailto:` không cần permission |
| PSF-2 | **Notification Shortcut MVP scope**: có gửi notification thực sự hay chỉ persistent icon? | Phase 7 — OQ8 |
| PSF-3 | **Privacy Policy required Internet?** Khi mở Privacy URL trên Settings — cần check connectivity? | Phase 1 — đề xuất: KHÔNG block, `url_launcher` tự handle |
| PSF-4 | **Camera audio permission**: nếu sau này thêm video attach Feedback → cần `RECORD_AUDIO` | Out of scope MVP |
| PSF-5 | **Foreground service permission** (nếu sau này có background task) | Out of scope MVP |

---

## 10. Tham chiếu

- Feedback flow: `feature_converter.md` §3.
- Battery Optimization Settings: `feature_setting.md` §2.2.
- Permission code-level: `technical_design.md` §12.3 (packages).
- Cross-cutting concerns roadmap: `solution_architecture_review.md` §14 (Phase 7).
