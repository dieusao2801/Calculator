# feature_spec.md — Calculator AI

Skeleton tổng quát các tính năng. Chi tiết từng tính năng/màn hình sẽ được viết trong các file riêng và liên kết ở mục "Danh mục đặc tả chi tiết".

---

## 1. Phạm vi
App có 4 tab: **AI Tutor**, **Converter**, **Calculator**, **Settings**.
Đặc tả chi tiết: **Converter (Currency, Percentage, World Time)**, **Calculator**, **Settings**.
**AI Tutor**: chỉ ghi nhận tồn tại.

---

## 2. Điều hướng
- Tab mặc định: **Calculator**.
- Back ở tab khác → quay về Calculator.
- Back tại Calculator → hộp xác nhận thoát app.
- Chuyển tab giữ trạng thái nhập của tab khác; tự đóng bàn phím.

---

## 3. Tab Converter
- **Danh sách tool**: search + Favorites (lưới 4 cột, lưu cục bộ, không kéo-thả), nhóm Converter/Consume/Money/Health.
- **Currency Converter**: Simple/Advanced; cập nhật tỷ giá qua mạng, fallback cache; lịch sử riêng.
- **Percentage Calculator**: 2 chế độ `% of Number`, `± % Change`; đổi chế độ giữ riêng dữ liệu; lịch sử riêng.
- **World Time Converter**: ghim timezone thiết bị đầu danh sách; "Now" / thời điểm tuỳ chỉnh; sort & edit-mode; không trùng.

---

## 4. Tab Calculator
- 2 chế độ: **Basic** và **Scientific** (toggle).
- Angle mode DEG/RAD/GRA (hiện khi có lượng giác).
- History (xem, restore, share, xoá) + Draft (theo Setting `Keep Calculator Record`).
- Biểu thức sai / vượt phạm vi → Snackbar; vượt độ dài tối đa → chặn nhập.

---

## 5. Tab Settings
Áp dụng tức thì, không có Save / Restore default.
- **Header quick action**: 2 nút — **Themes** (placeholder, mở `ThemesScreen` Light/Dark) và **Help** (mở Help screen / link ngoài).
- **System**: Language, **Startup Calculator**, Measurement Unit, Number Format, Decimal Digits (0–10, mặc định 2), Vibration, Sound, Always On Screen, Keep Calculator Record, Battery Optimization (Android, ẩn nếu đã miễn), App Widget / Notification Shortcut / Launcher Shortcut (**MVP placeholder** — chờ stakeholder chốt scope).
- **Chat**: Chat History, Clear Chat History (confirm, không undo).
- **Developer**: Privacy, Report Problem, Rating, Share, More Apps, App Version (ẩn item nếu thiếu URL tương ứng).

---

## 6. Quy tắc nghiệp vụ chung
- Currency & Percentage: số nhập không âm, 1 dấu thập phân.
- Định dạng số: theo Number Format + Decimal Digits. **Scientific notation** khi `|x| ≥ 1e15` hoặc `0 < |x| < 1e-6`.
- Favorites: lưu cục bộ; thứ tự = thứ tự thêm; **không giới hạn số lượng**.
- Tỷ giá: có thời điểm hiệu lực; mất mạng → cache; cảnh báo "tham khảo" (chỉ mở khi tap menu, không auto lần đầu).
- World Time: timezone thiết bị ghim đầu; chặn trùng; DST phản ánh ở GMT; **không có history**.
- Calculator: biểu thức không hợp lệ / vượt phạm vi → thông báo, không tính.
- History capacity các tool: **100 FIFO** (Calculator / Currency / Percentage).
- `Add Shortcut`: **Android only**; iOS ẩn item.

---

## 7. Mô hình dữ liệu (mức nghiệp vụ)
- `AppConfig` — Settings + URL ngoài + favorite currency/tools.
- `ConverterItem`, `Favorite` — tool & yêu thích.
- `CurrencyUnit`, `CurrencyHistory` — tỷ giá + lịch sử.
- `PercentageHistory` — lịch sử % theo mode.
- `WorldTimeState` — danh sách city + reference mode (không có history quy đổi).
- `CalculatorHistory` — biểu thức + kết quả (raw + display) + angle mode + thời điểm.

Chi tiết kiểu dữ liệu xem `architecture.md`.

---

## 8. Tích hợp ngoài
- Nguồn tỷ giá (mạng) → fallback cache.
- Trình duyệt thiết bị → Privacy / Rating / More Apps / Help.
- Hộp chia sẻ hệ thống → share kết quả/link app.
- Email client (mailto) → submit Feedback (offline → báo lỗi, không queue).
- Settings hệ thống (Android) → miễn tối ưu pin + Launcher Shortcut.
Không có server, không sync, không đăng nhập.

---

## 9. Yêu cầu phi chức năng
- Offline 100% trừ Currency refresh.
- I18n: locale-aware mọi định dạng & nhãn.
- Hiệu năng: thao tác cục bộ < 50ms; tỷ giá lần đầu ≤ 3s.
- Quyền riêng tư: không thu thập PII; dữ liệu local.
- Accessibility: screen reader, tương phản, font kết quả đủ lớn.

---

## 10. Danh mục đặc tả chi tiết
- `feature_calculator.md` — Calculator (Basic + Scientific + History)
- `feature_converter.md` — Converter List + Currency Converter + Feedback Screen
- `feature_percentage_calculator_screen.md` — Percentage Calculator
- `feature_world_time.md` — World Time Converter
- `feature_setting.md` — Settings (System + Chat + Developer)
- `navigation_flow.md` — route map, back stack, deep links, tab preservation
- `permission_system_flow.md` — permission Android/iOS, rationale, fallback
- `technical_design.md` — thiết kế kỹ thuật chi tiết, Clean Architecture, roadmap
- `solution_architecture_review.md` — review tổng + acceptance criteria + roadmap
- (bổ sung khi có file mới)

---

## 11. Câu hỏi mở (chưa chốt)
- **Themes**: số lượng theme, có IAP? (hiện placeholder Light/Dark.)
- **Help link URL**: nội bộ hay ngoài?
- **Startup Calculator** options đầy đủ: `Last Used / Basic / Scientific / khác`?
- **App Widget** nội dung + kích thước?
- **Notification Shortcut** dẫn tới tính năng nào?
- **Currency API endpoint** cụ thể.
- **Email đích** của mailto Feedback.
- **List preset Feedback issues** đầy đủ.
- **Percentage History** commit timing (khi rời màn / Share / nhấn lưu)?
- **World Time Bottom Bar**: giữ icon Calculator overlay hay ẩn?
- **Chat History** xoá theo khoảng thời gian?
- **Lộ trình đồng bộ đa thiết bị**: out of scope MVP, có roadmap?

> Câu đã chốt (✅): Bottom Nav 4 tab (AI Tutor/Converter/Calculator/Settings); Calculator default; Flutter only; Hot-reload language qua `intl + flutter_localizations`; Ngưỡng 50 ký tự = quy ước UI; Favorites không kéo-thả; Ads out of scope MVP; dec/hex/bin out of scope MVP.
