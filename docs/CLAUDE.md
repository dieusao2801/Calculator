# CLAUDE.md — Calculator AI

Tài liệu chỉ dẫn ngắn gọn cho Claude khi làm việc trên dự án **Calculator AI**.
Khi cần chi tiết hơn, đọc thêm: `feature_spec.md`, `architecture.md`, `ui_notes.md`,
và các file đặc tả riêng theo từng tính năng/màn hình (sẽ được thêm sau).

---

## 1. Tóm tắt sản phẩm
App di động đa tiện ích gồm 4 tab: **AI Tutor**, **Converter**, **Calculator** (mặc định), **Settings**.
- Đơn người dùng, không đăng nhập, dữ liệu lưu **cục bộ**.
- Offline 100% trừ **Currency Converter** (cần mạng để cập nhật tỷ giá).
- Đa ngôn ngữ; mọi định dạng số/ngày/giờ theo locale + cấu hình app.

Phạm vi đặc tả chi tiết: **Converter (Currency, Percentage, World Time), Calculator, Settings**.
AI Tutor chỉ ghi nhận sự tồn tại.

---

## 2. Nền tảng & công nghệ
- **Nền tảng**: Android & iOS (Mobile-first).
- **Framework**: **Flutter** (chốt). Không dùng React Native.
- **Kiến trúc**: Clean Architecture 3 tầng (Presentation → Domain → Data).
- **State**: `flutter_bloc` (Cubit cho case đơn giản, Bloc cho Calculator/Currency).
- **Navigation**: `go_router` (StatefulShellRoute giữ state per tab).
- **DI**: `get_it` + `injectable`.
- **Lưu trữ cục bộ**: `SharedPreferences` cho AppConfig key-value; **Hive** cho History/Favorites/Cache.
- **Mạng**: `dio`; chỉ dùng cho Currency rate API.
- **I18n**: `intl` + `flutter_localizations` (hot-reload locale qua `MaterialApp.locale`).

---

## 3. Lệnh phát triển (tham chiếu — thay bằng lệnh nền tảng thực tế)
- Dev: `flutter run` / `npm run dev`
- Build: `flutter build apk` (hoặc `ios`) / `npm run build`
- Lint: `flutter analyze` / `npm run lint`
- Test: `flutter test` / `npm run test`
- E2E: `flutter test integration_test` / `npm run test:e2e`

---

## 4. Quy chuẩn code
- **Ngôn ngữ**: Dart (Flutter). Kiểu dữ liệu tường minh.
- **State**: Lưu cục bộ, đồng bộ tức thì khi đổi Settings; không có nút Save / Restore default.
- **Lỗi**: try-catch cho async (tỷ giá, I/O local); thông báo qua **Snackbar/Toast** thân thiện.
- **Đặt tên**:
  - Biến/hàm: `camelCase`
  - Class/Component: `PascalCase`
  - Hằng số: `UPPER_SNAKE_CASE`
- **Định dạng số**: theo `Number Format` + `Decimal Digits` ở Settings.
- **I18n**: không hardcode chuỗi UI; dùng file tài nguyên ngôn ngữ.
- **Accessibility**: nhãn rõ cho screen reader; tương phản đạt chuẩn.

---

## 5. Nguyên tắc làm việc của Claude
- Bám theo `feature_spec.md` cho phạm vi tính năng; bám `architecture.md` cho phân lớp/luồng dữ liệu; bám `ui_notes.md` cho quy ước UI.
- Khi tạo file mới cho 1 tính năng cụ thể, đặt cạnh feature spec gốc và cập nhật mục lục ở `feature_spec.md`.
- Không phát sinh tính năng ngoài phạm vi tài liệu; nếu cần, ghi vào mục "Câu hỏi mở" của `feature_spec.md`.
- Mọi văn bản hiển thị cho người dùng phải đi qua I18n; mọi giá trị số phải đi qua formatter.

---

## 6. Tham chiếu tài liệu
- `feature_spec.md` — đặc tả tính năng (tổng quát + danh mục file chi tiết).
- `architecture.md` — kiến trúc tổng quan, phân lớp, luồng dữ liệu.
- `ui_notes.md` — quy ước UI/UX, điều hướng, lỗi, accessibility.
- `navigation_flow.md` — route map, back stack, deep links, tab preservation.
- `permission_system_flow.md` — permission Android/iOS, rationale dialog, fallback.
- `technical_design.md` — thiết kế kỹ thuật chi tiết, Clean Architecture, roadmap.
- `solution_architecture_review.md` — review tổng hợp + acceptance criteria + roadmap.
- `feature_calculator.md` — Calculator (Basic + Scientific + History).
- `feature_converter.md` — Converter List + Currency Converter + Feedback.
- `feature_percentage_calculator_screen.md` — Percentage Calculator.
- `feature_world_time.md` — World Time Converter.
- `feature_setting.md` — Settings (System + Chat + Developer).
