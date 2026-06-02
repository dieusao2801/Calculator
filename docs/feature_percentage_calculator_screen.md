# Đặc tả Chi tiết: Percentage Calculator

Tài liệu đặc tả màn hình **Percentage Calculator** trong Tab Converter.
Bám tài liệu tổng: `feature_spec.md`, `architecture.md`, `ui_notes.md`, `feature_converter.md`.

---

## 1. Mô tả (Description)

Bộ tính phần trăm hỗ trợ **2 chế độ** với **tính toán 2 chiều** (bidirectional): user nhập đủ điều kiện thì các trường còn lại tự suy ra.

| Chế độ | Trường | Công thức cơ bản |
|---|---|---|
| **`%` — % of Number** | `Number`, `Percentage`, `Result` | `Result = Number × Percentage / 100` |
| **`±%` — Percent Change** | `Initial Value`, `Percentage`, `Change`, `Final Value` | `Change = Initial × Percentage / 100`; `Final = Initial ± Change` |

Đổi chế độ giữ riêng state mỗi chế độ. History riêng cho tool, capacity **100, FIFO**.

> Không hỗ trợ Refresh / Simple-Advanced / Caution như Currency. Thay vào đó có **Calculation Formula** (info-only).

---

## 2. Thành phần UI (UI Components)

### 2.1 Display Panel
Nền xanh nhạt bo góc.

**Đầu màn**: **Toggle 2-segment**: `%` | `±%`. Segment active **xanh dương**, inactive trắng.

#### A. Form ở chế độ `%`
3 hàng stack dọc:
1. **`Number`** — input số, full-width.
2. **`Percentage`** — input số, suffix `%` cố định, full-width.
3. **`Result`** — input/derived, full-width, text **xanh đậm** khi là giá trị suy ra.

#### B. Form ở chế độ `±%`
3 hàng (hàng giữa **chia 2 cột**):
1. **`Initial Value`** — input, full-width.
2. Hàng 2 chia đôi:
   - **`Percentage`** (trái) — input số, prefix dấu `+`/`−` **luôn hiển thị explicit**, suffix `%`.
   - **`Change`** (phải) — input/derived, prefix dấu khớp Percentage, text xanh đậm khi derived.
3. **`Final Value`** — input/derived, full-width, text xanh đậm khi derived.

#### Quy ước chung
- **Mọi field đều editable** (kể cả các field "derived" hiển thị xanh).
- Field đang focus: viền **xanh dương** + underline ký tự đang nhập.
- Field rỗng: trống hoàn toàn (không hiện `0`).
- Số áp `Number Format` + `Decimal Digits` Settings.
- Dấu `+` ở chế độ `±%`: **luôn hiển thị** cho cả Percentage và Change khi giá trị dương.

### 2.2 Bàn phím (5 hàng × 4 cột)

| Hàng | Cột 1 | Cột 2 | Cột 3 | Cột 4 |
|---|---|---|---|---|
| 1 | **`C`** (đỏ) | `←` (focus prev) | `→` (focus next) | **`⌫`** |
| 2 | `7` | `8` | `9` | **`↓↑`** (swap fields) |
| 3 | `4` | `5` | `6` | **`±=`** (mở Calculator Overlay) |
| 4 | `1` | `2` | `3` | **`−`** (sign minus, chỉ `±%`) |
| 5 | `0` | `00` | **dấu thập phân** (theo Number Format) | **`+`** (sign plus, chỉ `±%`) |

- **`↓↑`** — swap cặp giá trị:
  - Chế độ `%`: swap `Number` ⇄ `Result`.
  - Chế độ `±%`: swap `Initial Value` ⇄ `Final Value`.
- **`±=`** — mở **Calculator Overlay dùng chung** (cùng overlay với Currency Converter); đóng → inject kết quả vào field đang focus.
- **`+` / `−`**:
  - Chế độ `±%`: đặt **dấu của Percentage** (tăng `+` / giảm `−`); Change & Final tính lại.
  - Chế độ `%`: **render nhưng disable** (mờ, không phản hồi).

### 2.3 Bottom Bar tool
`← (back) | Percentage Calculator | [icon calculator] | ⋮ (menu)`

### 2.4 Menu `⋮`
Thứ tự: **Add Shortcut · Favorite/UnFavorite · Calculation Formula · History · Share · Help · Feedback · Settings**.
- `Add Shortcut`: **Android only**; iOS ẩn item.
- `Favorite/UnFavorite`: cùng boolean với Favorites grid (Converter List).

### 2.5 Calculation Formula Dialog
- Tiêu đề `Calculation Formula`.
- Nội dung **info-only** (read-only, scroll dọc):
  ```
  - Percent:
    Initial Value = Final Value × 100 / Percent
    Final Value   = Initial Value × (Percent / 100)
    Percent       = Final Value × 100 / Initial Value

  - Percent Change:
    Initial Value = Final Value − Change
    Percent       = Change × 100 / Initial Value
    Change        = Final Value − Initial Value
    Final Value   = Initial Value + Change
  ```
- Action: chỉ nút `CANCEL` / `Close` đóng dialog. Không có OK.

### 2.6 Calculator Overlay
Dùng **chung** overlay với Currency Converter — không có calculator mini riêng cho Percentage. Chi tiết xem `feature_converter.md` §2.2.F.

**Title overlay** = tên field đang focus khi gọi overlay (vd `Number`, `Percentage`, `Initial Value`, `Change`, `Final Value`). Đóng overlay → inject kết quả vào field đó.

### 2.7 Share Dialog
Preview content (read-only) + `CANCEL` / `SHARE`. Mẫu nội dung:
```
Percentage Calculator
Mode: % of Number   (hoặc: ± % Change)

Number: 96
Percentage: 96%
Result: 92.16

Formula:
Result = Number × Percentage / 100
```
hoặc ở `±%`:
```
Percentage Calculator
Mode: ± % Change

Initial Value: 616,161
Percentage: +66%
Change: +406,666.26
Final Value: 1,022,827.26

Formula:
Change = Initial × Percentage / 100
Final  = Initial + Change
```
**Không** đính kèm storeUrl trong MVP.

---

## 3. Hành động / Kết quả (Actions / Results)

| Hành động | Kết quả |
|---|---|
| Tap toggle `%` / `±%` | Đổi chế độ; **giữ riêng state** mỗi chế độ. |
| Tap 1 field | Focus field, hiện caret + underline. |
| Nhập số ở field focus | Cập nhật; nếu đủ điều kiện (xem §4) → auto-derive các field còn lại. |
| Tap `+` / `−` (chế độ `±%`) | Đặt dấu Percentage (tăng/giảm); Change & Final tính lại. |
| Tap `+` / `−` (chế độ `%`) | No-op (disable). |
| Tap `←` / `→` | Chuyển focus tuần tự giữa các field hiện hữu. |
| Tap `↓↑` | Swap cặp giá trị: `Number ⇄ Result` (`%`) hoặc `Initial ⇄ Final` (`±%`); các field còn lại tính lại. |
| Tap `±=` | Mở Calculator Overlay; tap `=` hoặc đóng overlay → inject kết quả vào field focus. |
| Tap `⌫` | Xoá 1 ký tự cuối field focus; trigger tính lại. |
| Tap `C` | Xoá sạch **toàn bộ** field của chế độ đang dùng (state chế độ kia giữ nguyên). |
| Tap Bottom Bar icon calc | Mở Calculator Overlay (dùng nhanh). |
| Menu `Add Shortcut` (Android) | Mở Add Shortcut Dialog → OK = tạo Launcher Shortcut. |
| Menu `Calculation Formula` | Mở Dialog info-only. |
| Menu `History` | Mở màn History riêng của Percentage; tap item = restore mode + tất cả values + sign. |
| Menu `Share` | Mở Share Dialog với content theo §2.7. |
| Menu `Favorite/UnFavorite` | Toggle Favorite boolean (đồng nhất Favorites grid). |
| Menu `Feedback` | Mở Feedback Screen, context dropdown = `Percentage Calculator`. |
| Menu `Help` | Mở màn Help (TBD). |
| Menu `Settings` | Mở Tab Settings. |

---

## 4. Business Rules

1. **Bidirectional calculation**
   - Chế độ `%`: cần ≥ 2/3 field hợp lệ → derive field còn lại.
   - Chế độ `±%`: cần **`Initial Value` + ít nhất 1 field khác** → derive các field còn lại.
   - Đầu vào không đủ → các field derived rỗng, không báo lỗi.
2. **Mâu thuẫn dữ liệu**: Khi đủ điều kiện và user **chỉnh sửa 1 field** đã có giá trị → field vừa chỉnh sửa **ưu tiên** giữ nguyên; các field còn lại tự **tính lại** dựa trên field vừa edit + field được edit gần nhất trước đó.
3. **Nhập liệu**
   - Số nhập **không âm** (dùng phím `+`/`−` để biểu diễn chiều tăng/giảm ở `±%`).
   - `Percentage`: tối đa **3 chữ số thập phân**.
   - Các field khác: tối đa **6 chữ số thập phân**.
   - Vượt giới hạn → chặn nhập tiếp.
   - **Cho phép `Percentage > 100%` hoặc `< −100%`** (vd `+500%`, `−250%`).
4. **Dấu `+/−`**
   - Chỉ áp dụng cho chế độ `±%`.
   - Dấu hiển thị **explicit** ở Percentage và Change (cả khi dương: `+66%`, `+406,666.26`).
   - Chế độ `%`: phím `+`/`−` disable.
5. **Định dạng số**: theo `Number Format` + `Decimal Digits` Settings. **Override khi số rất nhỏ / rất lớn** theo cùng quy ước Calculator/Currency:
   - `|x| ≥ 1e15` hoặc `0 < |x| < 1e-6` → scientific notation.
6. **Đổi chế độ giữ riêng state** — không reset, không ghi đè khi toggle qua lại.
7. **Tất cả field đều editable**, kể cả khi đang ở trạng thái "derived" hiển thị xanh.
8. **Swap (`↓↑`)**: chỉ swap giá trị 2 field cặp đôi; các field còn lại tính lại theo công thức.
9. **Add Shortcut**: Android only.
10. **History**
    - Item lưu schema rõ: `{mode, numberVal?, percentageVal, signIsPositive, changeVal?, resultVal?, initialVal?, finalVal?, timestamp}`. Field nào không thuộc mode đang dùng = `null`.
    - Capacity: **100 bản ghi**, vượt → **FIFO** (xoá cũ nhất).
    - Tap item = restore đầy đủ mode + values + sign.
    - Hỗ trợ Share, Xoá từng item, Xoá tất cả (confirm dialog).
    - **Commit timing**: ghi History khi user (a) tap `Share` (commit snapshot), (b) tap toggle chế độ với form hợp lệ, (c) rời màn (back hoặc chuyển tab). KHÔNG ghi khi user flip `+/−` liên tiếp hoặc đang nhập dở.
11. **Calculation Formula Dialog**: info-only, đóng bằng `CANCEL` / `Close`. Không thay đổi state.
12. **Share content**: gồm `mode` + tất cả field values + công thức tương ứng. **Không** kèm storeUrl trong MVP.
13. **Calculator Overlay**: dùng **chung** với Currency Converter (xem `feature_converter.md` §2.2.F).

---

## 5. Edge Cases

1. **Chỉ fill 1 field** → tất cả field còn lại rỗng (không lỗi).
2. **Chế độ `±%` thiếu Initial Value** → không tính được dù 2 field khác đầy → giữ rỗng, không lỗi.
3. **`Initial Value = 0`** + tính ngược `Percentage` → chia 0 → field Percentage để rỗng + (tùy chọn) Snackbar `"không thể tính khi Initial = 0"`. Đề xuất: giữ rỗng im lặng để đồng nhất rule "trường thiếu → kết quả rỗng".
4. **Percentage = 0** ở `±%` → Change = 0, Final = Initial.
5. **Toggle `+` ⇄ `−` liên tiếp** → flip sign nhanh; **không sinh history mỗi lần** (history chỉ ghi khi user commit qua Share / lưu chủ động hoặc khi rời màn).
6. **Đổi `Number Format` / `Decimal Digits` Settings khi đang ở Percentage** → re-format ngay tất cả field.
7. **Đổi Language khi đang ở Percentage** → nhãn UI, formula dialog, share content cập nhật ngay; giá trị giữ nguyên.
8. **Nhập đủ 3/4 field rồi xoá 1 field** → field derived tương ứng trống lại; các field còn lại giữ giá trị.
9. **Swap (`↓↑`) khi 2 field đang trống** → no-op.
10. **Calculator Overlay huỷ bằng back hệ thống** → không inject kết quả.
11. **Số kết quả vô cực / NaN** (do chia 0 trong tính ngược) → field tương ứng trống, các field khác không đổi.
12. **`Percentage` lớn dẫn đến `Change` / `Final` vượt range** → áp scientific notation theo §4.5.
13. **Tap field derived rồi gõ số mới** → field đó trở thành input chính, các field khác (gồm field đã edit trước đó) tự cân bằng theo rule §4.2.
14. **iOS user** mở menu → không thấy `Add Shortcut` (đã ẩn).

---

## 6. Tham chiếu
- Model: `PercentageHistory` — xem `feature_spec.md` §7.5 + `architecture.md` §5.
- Calculator Overlay: `feature_converter.md` §2.2.F.
- Quy ước UI/keypad/dialog: `ui_notes.md`.
- Settings liên quan: `Number Format`, `Decimal Digits`, `Language` — xem `feature_setting.md`.

---

> **Out of scope MVP** (loại khỏi tài liệu): Ads banner, calculator mini riêng cho Percentage.
