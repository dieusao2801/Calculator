# ui_notes.md — Calculator AI

Skeleton quy ước UI/UX chung. Chi tiết bố cục từng màn hình nằm trong file đặc tả tính năng.

---

## 1. Ngôn ngữ thiết kế
- Phong cách: hiện đại, premium, glassmorphism nhẹ; tránh màu mặc định thô.
- Hỗ trợ Light & Dark Mode; Dark là nền tối sâu (không đen thuần).
- Typography: font hiện đại (Inter / Roboto / Outfit). Cỡ chữ kết quả Calculator tự thu nhỏ khi tràn.
- Màu nhấn (primary) dùng cho tab active, nút chính, highlight timezone thiết bị.

---

## 2. Bố cục chung
- **Shell**: Bottom Nav 4 tab (AI Tutor, Converter, Calculator, Settings) cố định đáy màn hình.
- **Header màn con**: tiêu đề + nút Back + Menu `⋮` (nếu có).
- **Khu nội dung** + (nếu cần) **Bàn phím ảo** chiếm nửa dưới.

### 2.bis Bottom Bar tool (Currency / Percentage / World Time)
- Khi vào màn tool con: **ẩn Bottom Nav app**, hiện **Bottom Bar tool** cấu trúc: `← (back) | Title tool | [icon calculator overlay] | ⋮ (menu)`.
- Back từ Bottom Bar = thoát về Converter List.

### 2.ter Reference Mode Banner (World Time only)
- Khi ở Reference Mode: hiện **banner mỏng** dưới header với text `Reference: HH:mm — <CityName>` + nút `Now` cuối banner; màu khác Primary (vd Amber/Warning).

---

## 3. Bàn phím ảo
- **Calculator Basic** (7 hàng × 4 cột): nhóm số / toán tử / tiện ích có nền khác biệt.
- **Calculator Scientific** (7 hàng × 4 cột): mở rộng hằng số & hàm; sau khi chèn hàm → tự về Basic.
- **Long-press `( )`**: bao biểu thức hiện tại.
- **Currency keypad** (4 hàng × 4 cột): số, `.`/`,` theo locale, `⌫`, phím swap `↓↑` (Simple) / next focus `↓` (Advanced), `±=` Calculator Overlay, `C`.
- **Percentage keypad** (5 hàng × 4 cột): hàng 1 `C / ← / → / ⌫`, hàng 2-4 số, hàng 4 cột 4 = `−`, hàng 5 cột 4 = `+`, hàng 2 cột 4 = `↓↑` swap, hàng 3 cột 4 = `±=` Overlay.

### 3.bis Calculator Overlay (shared)
- Semi-modal dialog đè màn dưới (semi-transparent backdrop).
- **Title overlay = tên field đang focus** ở màn gọi (vd `Initial Value`, `Number`, `FROM CURRENCY`).
- Bên trong: Display nhỏ + bàn phím Calculator Basic.
- Đóng overlay (tap `=` hoặc nút `X` góc phải) → **inject kết quả** vào field focus.
- **Không** lưu vào Calculator History.
- Dùng chung giữa Currency Converter + Percentage Calculator. World Time **không** dùng overlay (đề xuất ẩn icon calc ở Bottom Bar).

---

## 4. Điều hướng
- Tab mặc định: Calculator.
- Back tab phụ → Calculator; Back ở Calculator → confirm thoát.
- Chuyển tab giữ input state; tự dismiss bàn phím.

---

## 5. Tương tác & phản hồi
- Micro-animation: scale-down khi nhấn phím; slide bottom-sheet.
- Haptic: rung nhẹ khi `Vibration` bật.
- Sound: tiếng phím khi `Sound` bật.
- Snackbar/Toast cho lỗi (không chặn luồng): cú pháp sai, vượt phạm vi, refresh tỷ giá lỗi, "already selected", mở link lỗi.
- Dialog xác nhận: thoát app, clear history, xoá nhiều (Edit mode).

---

## 6. Trạng thái rỗng (Empty State)
- Search Converter rỗng → icon + thông báo thân thiện.
- World Time chưa thêm thành phố → icon + nút thêm.
- History rỗng → icon + thông báo.

---

## 7. Định dạng hiển thị
- Số: theo `Number Format` + `Decimal Digits` (Settings).
- **Scientific notation** kích hoạt khi `|x| ≥ 1e15` hoặc `0 < |x| < 1e-6`. Số rất nhỏ gần biên → mở rộng `decimalDigits` để giữ ≥ 3 chữ số có nghĩa.
- Ngày/giờ: theo locale; World Time mặc định 24h.
- Tiền tệ: hiển thị mã ISO; thời điểm tỷ giá ở footer Currency (Simple Mode); Advanced Mode **ẩn** footer rate hoàn toàn.
- DST suffix `(DST)` cố định, **không** localize.

---

## 8. Picker & Toggle (Settings)
- Picker = bottom-sheet/dialog RadioGroup; chọn xong áp dụng tức thì và đóng.
- Toggle: switch chuẩn; áp dụng tức thì.
- Mục liên kết ngoài: ẩn khi thiếu URL.

---

## 9. Accessibility
- Vùng chạm tối thiểu đạt chuẩn (≥ 44×44 dp).
- Content description cho mọi nút icon-only.
- Tương phản chữ/nền đạt WCAG AA.
- Hỗ trợ font scaling hệ thống ở các vùng văn bản (không phải vùng kết quả Calculator).

---

## 10. Quy ước icon & nhãn
- Icon: outline cho trạng thái mặc định, filled cho trạng thái active (tab, favorite).
- Nhãn ngắn, theo I18n; không hardcode.
- Menu `⋮` đặt ở góc phải header màn con.
- **Toggle Basic ⇄ Scientific** dùng 1 icon thống nhất (đề xuất `fx`); KHÔNG dùng icon `X` đỏ (tránh nhầm Close/Clear).
- Mục `Add Shortcut` trong menu tool: chỉ render trên **Android**; iOS ẩn hoàn toàn.

## 11. Quy ước Share content (theo tool)
Mỗi tool có template Share riêng, dạng **multi-line text**:
- **Calculator**: expression + `=` + result + (angle mode nếu có lượng giác) + timestamp.
- **Currency**: tool name + danh sách currency:value + rate timestamp + dòng tỷ giá cơ sở + "via Calculator" + storeUrl (nếu có cấu hình).
- **Percentage**: tool name + mode + tất cả field values + công thức tương ứng. **Không** kèm storeUrl trong MVP.
- **World Time**: tool name + Mode (Now / Reference @ city) + list city với day + time + GMT. **Không** kèm storeUrl trong MVP.

## 12. Font auto-shrink (Calculator)
- Expression: mặc định `32sp`, tối thiểu `16sp`.
- Result: mặc định `48sp`, tối thiểu `20sp`.
- Đạt min → cho phép scroll ngang, không thu nhỏ tiếp.
