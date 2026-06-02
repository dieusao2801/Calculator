# Đặc tả Chi tiết: World Time Converter

Tài liệu đặc tả màn hình **World Time Converter** trong Tab Converter.
Bám tài liệu tổng: `feature_spec.md`, `architecture.md`, `ui_notes.md`, `feature_converter.md`.

---

## 1. Mô tả (Description)

Công cụ theo dõi giờ nhiều thành phố trên thế giới và quy đổi múi giờ thông qua **mốc tham chiếu** (Reference Mode).

- 2 chế độ hoạt động:
  - **Now Mode** (mặc định): tự động cập nhật theo giờ thực thiết bị.
  - **Reference Mode**: tap 1 city → mở dialog đặt thời điểm cụ thể; city đó trở thành **anchor**, mọi card khác tính lại theo công thức `T_target = T_ref + (offset_target − offset_ref)` (đã tính DST).
- Múi giờ thiết bị **luôn ghim đầu**, highlight, không xoá được, không bị di chuyển bởi Sort.
- Có nút **`Now`** ở header để thoát Reference Mode.
- **Không có History** trong MVP.

> Out of scope MVP: ads banner.

---

## 2. Thành phần UI (UI Components)

### 2.1 Header
- Tiêu đề (ẩn — tiêu đề ở Bottom Bar).
- **Nút `Now`** (chỉ hiển thị khi đang ở Reference Mode) — tap để thoát Reference Mode, quay về Now.
- **Reference Mode Indicator** (badge/banner mỏng): hiển thị `Reference: HH:mm — <CityName>` khi đang ở Reference Mode.

### 2.2 Danh sách City Cards
Card bo góc, chia 2 cột:

| Vị trí | Nội dung | Ghi chú |
|---|---|---|
| Trái-trên | Tên thành phố (đậm) | Suffix `(DST)` cố định (không localize) nếu đang DST |
| Trái-dưới | Tên quốc gia | font nhẹ hơn |
| Phải-trên | `Day, dd MMM` | vd `Monday, 01 Jun`; theo locale; không có year |
| Phải-dưới | `HH:mm (GMT±HH:MM)` | 24h cố định; offset phản ánh DST |

**Card device timezone**: nền **xanh đậm primary**, chữ trắng, **ghim đầu** danh sách; không xoá; không di chuyển bởi Sort.

### 2.3 FAB
- Nút tròn `+` xanh, đặt **giữa-dưới** display area, lơ lửng trên Bottom Bar.
- Tap → mở **Add City Screen**.

### 2.4 Bottom Bar tool
`← (back) | World Time Converter | [icon calculator] | ⋮ (menu)`

### 2.5 Menu `⋮`
Thứ tự: **Add Shortcut · Favorite/UnFavorite · Sort · Edit · Share · Help · Feedback · Settings**.
- `Add Shortcut`: **Android only** (iOS ẩn).
- `Favorite/UnFavorite`: cùng boolean với Favorites grid (Converter List).
- **Không có** History (bỏ trong MVP), Refresh, Caution, Calculation Formula.

### 2.6 Add City Screen (full-screen modal)
- Header: `Add`.
- **Search bar** (kính lúp + placeholder `Search`).
- **List card** (cùng layout với card chính), mỗi card live update giờ.
- Sort A→Z theo **tên localized**.
- Nút `CANCEL` góc phải dưới đóng modal.

### 2.7 Set Reference Time Dialog
Tap 1 card chính (gồm cả device card) → dialog:
- Tiêu đề = tên thành phố tap.
- Badge `GMT±HH:MM` — **read-only**.
- Label `Set time`.
- Field **Date** `Day, MMM dd, yyyy` → tap mở Date Picker.
- Field **Time** `HH:mm` → tap mở Time Picker.
- `CANCEL` / `OK`.

### 2.8 Date Picker
- Tiêu đề `Date Picker`.
- 3 wheel: `Month / Day / Year`.
- Year range: **current year ± 100**.
- Day chỉ hiện ngày hợp lệ theo month/year.
- `CANCEL` / `OK`.

### 2.9 Time Picker
- Tiêu đề `Time Picker`.
- 2 wheel: `Hour / Minute` (24h).
- `CANCEL` / `OK`.

### 2.10 Sort Bottom Sheet
Hiện 4 option (single-select):
- `Name A→Z`
- `Name Z→A`
- `Time ↑` (GMT tăng)
- `Time ↓` (GMT giảm)

Áp dụng tức thì khi chọn; đóng sheet. Device card luôn ghim đầu bất chấp sort.

### 2.11 Edit Mode
- Vào Edit qua: menu `Edit` **hoặc** long-press 1 card.
- Mỗi card (trừ device) hiện **checkbox** bên trái.
- Tap card khi đang Edit → toggle checkbox.
- Header / action bar: `Selected: X | Cancel | Delete`.
- `Delete` → confirm dialog `Xoá X thành phố?` → OK = xoá.
- Card device timezone **không có checkbox**, không xoá được.
- Thoát Edit: tap `Cancel` ở action bar hoặc back hệ thống.

### 2.12 Share Dialog
Preview text + `CANCEL` / `SHARE`. Nội dung **multi-line text**:
```
World Time Converter
Mode: Now            (hoặc: Reference — <CityName> @ <HH:mm>)

Ho Chi Minh, Vietnam — Monday, 01 Jun, 10:36 (GMT+07:00)
London (DST), United Kingdom — Monday, 01 Jun, 04:36 (GMT+01:00)
New York City (DST), United States — Sunday, 31 May, 23:36 (GMT-04:00)
...
```
`SHARE` → System Share Sheet.

### 2.13 Bottom Bar — icon Calculator
**Ẩn icon calculator** ở Bottom Bar của World Time. Lý do: World Time không có input số → overlay không có field để inject; giữ icon gây UX không nhất quán.

Bottom Bar World Time rút gọn: `← (back) | World Time Converter | ⋮ (menu)`.

---

## 3. Hành động / Kết quả (Actions / Results)

| Hành động | Kết quả |
|---|---|
| Mở màn lần đầu | Now Mode; device card ghim đầu; cities đã thêm theo `addedOrder`; nút `Now` ẩn. |
| Tap 1 city card | Mở Set Reference Time Dialog với city đó là anchor. |
| OK trong Set Time | Chuyển sang **Reference Mode**: dừng auto-update; tính lại toàn bộ card theo anchor; header hiện **nút `Now`** + indicator Reference. |
| Tap nút `Now` (header) | Thoát Reference Mode → Now Mode; ẩn nút Now + indicator; resume auto-update. |
| Tap field Date trong Set Time | Mở Date Picker; OK ghi giá trị vào field Date. |
| Tap field Time trong Set Time | Mở Time Picker; OK ghi giá trị vào field Time. |
| Tap FAB `+` | Mở Add City Screen. |
| Gõ Search ở Add | Filter case-insensitive, debounce; match **tên localized + tên English**. |
| Tap 1 city ở Add (chưa có) | Thêm vào cuối list, đóng modal. |
| Tap 1 city đã có | Snackbar `"already selected"`; không thêm; không đóng. |
| Tap `CANCEL` ở Add | Đóng modal. |
| Menu `Sort` → chọn 1 option | Re-sort list; device card vẫn ghim đầu; áp tức thì + đóng sheet. |
| Menu `Edit` hoặc long-press card | Vào Edit Mode. |
| Tap card khi Edit | Toggle checkbox. |
| Tap `Delete` action bar | Confirm dialog → OK = xoá những card đã tick. |
| Tap `Cancel` action bar / back | Thoát Edit Mode. |
| Menu `Share` | Mở Share Dialog với content §2.12. |
| Menu `Favorite/UnFavorite` | Toggle Favorite boolean (đồng nhất Favorites grid Converter List). |
| Menu `Add Shortcut` (Android) | Mở dialog → OK tạo Launcher Shortcut. |
| Menu `Feedback` | Mở Feedback Screen, context = `World Time Converter`. |
| Menu `Help` / `Settings` | Mở Help / Tab Settings. |
| (Bottom Bar không có icon calculator — đã ẩn) | — |

---

## 4. Business Rules

1. **Device timezone**
   - Luôn ghim đầu list, highlight primary.
   - Không xoá, không di chuyển bởi Sort/Edit.
   - Khi user đổi timezone hệ thống → device card cập nhật `timezoneId` mới ngay khi app resume.
2. **Không trùng**: định danh theo **`timezoneId` (IANA)**. Trùng → snackbar `"already selected"`.
3. **DST**
   - Suffix **`(DST)`** **không localize** (cố định).
   - GMT offset đã tính DST.
   - Cập nhật khi: **app launch/resume** và khi **tính toán lại thời gian** (vd OK Set Time, đổi mode).
4. **Now Mode**: tự update mỗi 1 giây (cho minute change). Hiển thị giờ theo `HH:mm` 24h.
5. **Reference Mode**
   - Dừng auto-update.
   - Anchor = city được tap mở Set Time Dialog.
   - Quy đổi card khác: `T_target = T_ref + (offset_target − offset_ref)` với cả 2 offset đã tính DST.
   - **Giữ Reference Mode** kể cả khi app close + mở lại sau nhiều ngày (không auto reset về Now).
   - Hiện nút `Now` ở header + indicator `Reference: HH:mm — <CityName>`.
6. **Add City**: sort A→Z theo tên localized; search match localized + English.
7. **Sort list chính**: 4 option (Name A↑/↓, Time ↑/↓). Device card luôn đầu.
8. **Edit Mode**: chỉ multi-select để xoá; không drag-drop sắp xếp.
9. **Add Shortcut**: Android only.
10. **History**: **không lưu** trong MVP.
11. **Favorite trạng thái**: 1 boolean đồng nhất với Favorites grid.
12. **Date Picker year range**: `currentYear − 100` đến `currentYear + 100`.
13. **Định dạng**:
    - Card chính: `Day, dd MMM` + `HH:mm (GMT±HH:MM)`.
    - Set Time dialog: `Day, MMM dd, yyyy` + `HH:mm`.
    - Locale-aware cho `Day` và `MMM` (vd `Monday` → `Thứ Hai`, `Jun` → `Th6`).
14. **Share**:
    - Multi-line text.
    - Gồm `Mode` + danh sách city + thời gian từng city tại thời điểm share.
    - Không kèm storeUrl trong MVP.
15. **Calculator Overlay**: dùng chung; ở World Time không inject về đâu — đóng overlay = đóng.

---

## 5. Edge Cases

1. **Đổi timezone hệ thống thiết bị**: device card cập nhật khi app resume; nếu user đã thêm city trùng `timezoneId` cũ → city đó giữ nguyên trong list.
2. **Reference time vượt ranh giới ngày**: card khác đổi ngày (vd `Sunday, 31 May` → `Monday, 01 Jun`).
3. **DST chuyển đổi xảy ra trong Reference Mode**: GMT offset & DST tính theo thời điểm reference (không nhảy theo giờ thực).
4. **Add city khi offline**: vẫn hoạt động (tzdata local trong app).
5. **Date Picker chọn ngày không hợp lệ** (vd 31/Feb): wheel chỉ render day hợp lệ theo `month + year` đang chọn.
6. **Year ngoài range ± 100**: wheel chỉ render trong range (không cuộn được ngoài range, không có item disabled).
7. **Tap `Now` khi đang Now Mode**: no-op (nút chỉ hiện khi Reference).
8. **Long-press device card**: **no-op** (không vào Edit Mode). Lý do: device card không có checkbox vì không xoá được, vào Edit từ device card sẽ confuse user.
9. **Xoá toàn bộ user-city ở Edit**: list chỉ còn device card; FAB hoạt động; KHÔNG hiển thị empty illustration.
10. **Reference Mode + mở lại app sau X ngày**: giữ nguyên Reference (anchor cụ thể tại thời điểm set), không auto reset.
11. **Sort theo Time với 2 city cùng GMT**: tie-break theo tên A→Z.
12. **Đổi Language khi đang ở World Time**: tên city + Day + MMM cập nhật locale ngay; `(DST)` giữ nguyên.
13. **iOS user** mở menu → không thấy `Add Shortcut`.
14. **Share khi không có ứng dụng share nào**: Snackbar lỗi "không tìm thấy ứng dụng share".
15. **Bottom Bar World Time**: không có icon Calculator → user vào Calculator chính qua Bottom Nav app nếu cần.
16. **Edit Mode đang dở + back hệ thống**: thoát Edit; bỏ chọn tất cả.
17. **App killed trong Reference Mode** rồi mở lại: khôi phục Reference + tính lại offset DST hiện tại theo `referenceTime` đã lưu.

---

## 6. Tham chiếu
- Model: `WorldTime`, `WorldTimeHistory` (chỉ giữ `selectedCityIds[]`, `referenceTime?`, `sortCriteria`, `sortOrderAscending` — bỏ phần history quy đổi) — xem `feature_spec.md` §7.6 + `architecture.md` §5.
- Calculator Overlay: `feature_converter.md` §2.2.F.
- Quy ước UI/dialog/empty state: `ui_notes.md`.
- Settings liên quan: `Language` — xem `feature_setting.md`.

---

> **Out of scope MVP**: Ads banner; History của World Time; drag-drop sắp xếp; localize `(DST)` suffix; auto reset Reference Mode theo thời gian.
