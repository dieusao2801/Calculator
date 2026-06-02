# Đặc tả Chi tiết: Tab Converter — List & Currency Converter & Feedback

Tài liệu đặc tả 3 màn hình thuộc Tab Converter:
1. **Converter List** — danh sách tool + Favorites.
2. **Currency Converter** — quy đổi tiền tệ (Simple/Advanced) + các dialog phụ.
3. **Feedback Screen** — gửi phản hồi tới developer qua email.

Bám tài liệu tổng: `feature_spec.md`, `architecture.md`, `ui_notes.md`.

---

# Phần 1. Converter List

## 1.1 Mô tả
Màn hình cổng vào của Tab Converter. Cho phép user search/duyệt nhanh các công cụ quy đổi, ghim công cụ thường dùng vào **Favorites**, và vào chế độ **Manage Favorites** để thêm/bỏ ghim.
Không có history cấp List — history thuộc từng tool con.

## 1.2 Thành phần UI

### A. Header
- **Search bar** (kính lúp + placeholder `Search`).
- **Icon Manage Favorites** (lưới-có-dấu-cộng, góc phải).

### B. Favorites Grid (chỉ render khi có ≥ 1 favorite)
- Tiêu đề section `Favorite`.
- Grid **4 cột × N hàng**. Hàng cuối có thể **chưa đủ 4 ô** (vẫn render đúng).
- Mỗi cell: icon vuông bo góc (nền gradient riêng) + nhãn tool 2 dòng.
- **Không giới hạn** số lượng Favorites trong MVP.

### C. Categorized List
Thứ tự hiển thị (theo screenshot, label dùng nhãn nội bộ thống nhất):
1. **Converter**
2. **Consume**
3. **Health**
4. **Money**

Mỗi tool 1 hàng: icon vuông + tên tool (đậm) + subtitle category (mờ).

### D. Bottom Navigation
4 tab cố định: **AI Tutor · Converter (active, cam) · Calculator · Settings**.

### E. Chế độ Manage Favorites
- Header: search bar được thay bằng `← Manager Favorites`.
- Mỗi item (cả Favorites grid lẫn list):
  - Đang Favorite → nút **`X` đỏ** (góc phải) → tap = bỏ.
  - Chưa Favorite → nút **`+` đen** (góc phải) → tap = thêm.
- Back ở header → thoát chế độ.

## 1.3 Hành động / Kết quả

| Hành động | Kết quả |
|---|---|
| Gõ vào Search bar | Filter theo tên tool ở **locale hiện tại**, case-insensitive, debounce ~200ms. Ẩn Favorites section khi đang search. |
| Search không có kết quả | Empty state (icon + thông báo thân thiện). |
| Tap 1 tool (List hoặc Favorites) | Mở màn tool tương ứng. |
| Tap icon Manage Favorites | Vào chế độ Manage. |
| Tap `+` (Manage mode) | Thêm vào Favorites; push xuống cuối grid theo `addedOrder`. |
| Tap `X` (Manage mode) | Bỏ khỏi Favorites; grid co lại; nếu rỗng → ẩn section. |
| Back từ Manage | Thoát chế độ, khôi phục search bar. |

## 1.4 Business Rules
1. Favorites lưu cục bộ; thứ tự = `addedOrder` (thời gian thêm). Không drag-drop.
2. Không giới hạn số Favorites trong MVP.
3. Favorites grid render kể cả khi hàng cuối chưa đủ 4 cell.
4. Search dùng tên tool theo locale hiện tại.
5. Trạng thái `Favorite` của tool **đồng nhất** với menu `Favorite/UnFavorite` bên trong tool — cùng 1 boolean.

## 1.5 Edge Cases
1. Đổi Language khi đang ở List → tên tool re-render theo locale mới; thứ tự Favorites giữ nguyên.
2. Favorites rỗng → ẩn toàn bộ section, search bar và List giữ nguyên.
3. Tap nhanh `+` rồi `X` trên cùng 1 item → trạng thái cuối thắng (debounce nhẹ).

---

# Phần 2. Currency Converter

## 2.1 Mô tả
Quy đổi giá trị giữa các đơn vị tiền tệ. Hỗ trợ 2 chế độ:
- **Simple**: 1 cặp From/To + dòng tham chiếu tỷ giá.
- **Advanced**: 4 dòng đơn vị song song; mọi dòng tự đồng bộ khi 1 dòng đổi.

Tỷ giá: load cache → fetch API khi cũ/rỗng; có nút Refresh thủ công; mất mạng + cache → vẫn dùng; mất mạng + không cache → lỗi.

## 2.2 Thành phần UI

### A. Display Panel
Nền xanh nhạt bo góc.

**Simple**:
- Nhãn `FROM CURRENCY` + hàng `[Dropdown currency] [Input value]`.
- Nhãn `TO CURRENCY` + hàng tương tự.
- **Footer rate** (phải dưới, chữ nhỏ): `Rate as of dd MMM yyyy, HH:mm:ss` + dòng `* 1 [FROM] = X [TO]`.

**Advanced**:
- 4 hàng `[Dropdown] [Input]` liên tiếp, không nhãn `FROM/TO`.
- **Không** hiển thị footer rate (ẩn hoàn toàn).

Ô input đang focus có viền sáng (Sapphire/Purple theo theme).

### B. Bàn phím (4 cột × 4 hàng)

| Hàng | Cột 1 | Cột 2 | Cột 3 | Cột 4 |
|---|---|---|---|---|
| 1 | `7` | `8` | `9` | **`⌫`** (xanh teal) |
| 2 | `4` | `5` | `6` | **`↓↑`** (Simple = swap) / **`↓`** (Advanced = next focus) |
| 3 | `1` | `2` | `3` | **icon `±=`** (mở Calculator Overlay) |
| 4 | `0` | `00` | **dấu thập phân** (`.` hoặc `,` theo `Number Format`) | **`C`** (đỏ pastel) |

### C. Bottom Bar (riêng cho tool, ẩn Bottom Nav app)
`← (back) | Currency Converter | [icon calculator nhanh] | ⋮ (menu)`

### D. Menu ⋮
Thứ tự: `Add Shortcut` · `Favorite` / `UnFavorite` · `Refresh` · `Advanced Mode` / `Simple Mode` · `History` · `Share` · `Help` · `Feedback` · `Caution` · `Settings`.
- `Add Shortcut`: **chỉ hiển thị trên Android**. iOS ẩn item này hoàn toàn.

### E. Currency Picker (bottom-sheet)
Mở khi tap dropdown currency.
- Header `From Currency` / `To Currency`.
- **Search bar** đầu sheet.
- **List**: RadioGroup, mỗi item = `flag | tên localized | (ISO code)`. Item đang chọn = radio filled.
- Sort A→Z theo **tên localized** (đổi theo Language).
- Search match cả **tên localized**, **tên English**, và **ISO code**.
- Nút `CANCEL` góc phải dưới.
- Tap 1 item → áp dụng + đóng sheet ngay.
- Flag icon lấy từ **asset bundle local**.

### F. Calculator Overlay (khi tap `±=` keypad)
- **Dialog overlay** che mờ màn dưới (semi-modal). Giữ context Currency Converter ở dưới.
- Bên trong là bàn phím Calculator (Basic) + display nhỏ.
- Khi đóng (tap `=` hoặc nút đóng) → **inject kết quả** vào input đang focus của Currency Converter.

## 2.3 Dialog phụ

### A. Add Shortcut Dialog
- Tiêu đề `Add Shortcut`.
- Nội dung: `Do you want to add this converter shortcut to home screen?`
- Action: `CANCEL` / `OK`. `OK` → gọi API Launcher Shortcut hệ thống (Android).

### B. Caution Dialog
- Tiêu đề `Caution`.
- Nội dung: cảnh báo tỷ giá tham khảo + chưa bao gồm phí.
- Action: `OK`.
- **Chỉ mở khi tap mục `Caution` trong menu** — không auto-show lần đầu.

### C. Share Dialog
Preview content + `CANCEL` / `SHARE`. Nội dung gồm:
```
Currency Converter

[Currency A]: [value A]
[Currency B]: [value B]
(... thêm dòng nếu Advanced)

Rate as of [dd MMM yyyy, HH:mm:ss]
* 1 [BASE] = [rate] [QUOTE]

via Calculator
[storeUrl từ AppConfig]
```
`SHARE` → System Share Sheet.

## 2.4 Hành động / Kết quả

| Hành động | Kết quả |
|---|---|
| Mở màn lần đầu | Load cache. Cache hợp lệ → dùng ngay. Cache cũ/rỗng → fetch API; loading spinner cho tới khi có data hoặc lỗi. |
| Tap dropdown currency | Mở Currency Picker. |
| Chọn currency mới | Cập nhật dropdown + tính lại mọi input liên quan. |
| Nhập số ở input focus | Cập nhật input; mọi input còn lại tính ngay theo tỷ giá. |
| Tap `↓↑` (Simple) | Swap from ↔ to (giá trị + currency). |
| Tap `↓` (Advanced) | Next focus xoay vòng. |
| Tap `⌫` | Xoá 1 ký tự cuối input focus. |
| Tap `C` | Xoá toàn bộ input focus về rỗng (các input khác cũng rỗng theo, footer rate vẫn giữ). |
| Tap icon `±=` | Mở Calculator Overlay. Đóng → inject kết quả. |
| Tap icon Calculator ở Bottom Bar | Mở Calculator overlay (dùng nhanh, không rời màn Currency). |
| Tap `Refresh` | Force fetch API (bypass TTL). Thành công → update cache + footer. Lỗi → Snackbar, giữ cache cũ. |
| Tap `Simple Mode` / `Advanced Mode` | Toggle layout. <br>• **Simple → Advanced**: hàng 1 = FROM, hàng 2 = TO, **hàng 3 = Euro (EUR)**, **hàng 4 = British Pound (GBP)** (default). <br>• **Advanced → Simple**: hàng 1 = FROM, hàng 2 = TO; hàng 3-4 bỏ. |
| Tap `Favorite` / `UnFavorite` | Toggle tool Currency Converter trong Favorites grid của List. **Cùng boolean** với Manage Favorites. |
| Tap `Add Shortcut` (Android) | Mở Add Shortcut Dialog → `OK` tạo Launcher Shortcut. |
| Tap `History` | Mở màn History của Currency Converter. |
| Tap 1 item History | Restore mode + currencies + values + rateTimestamp lên màn. |
| Tap `Share` | Mở Share Dialog với content như §2.3.C. |
| Tap `Caution` | Mở Caution Dialog. |
| Tap `Help` | Mở màn Help (TBD ở doc riêng). |
| Tap `Feedback` | Mở Feedback Screen (xem Phần 3); dropdown context = `Currency Converter`. |
| Tap `Settings` | Mở Tab Settings. |

## 2.5 Business Rules

1. **Tỷ giá & cache**
   - Cache TTL: dùng cached cho tới khi API trả về thành công lần kế.
   - Refresh thủ công bypass TTL.
   - Mất mạng + cache → vẫn quy đổi, footer ghi rõ thời điểm cache.
   - Mất mạng + cache rỗng → màn lỗi + nút Retry.
2. **Nhập liệu**: số không âm, 1 dấu thập phân. Bàn phím không có phím `-`.
3. **Định dạng số**:
   - Tuân theo `Number Format` + `Decimal Digits` từ Settings.
   - **Scientific notation** bắt buộc khi `|x| ≥ 1e15` hoặc `0 < |x| < 1e-6`.
   - Trong khoảng còn lại, nếu giá trị quy đổi `|x| < 10^(-decimalDigits)` (mất ý nghĩa) → **mở rộng `decimalDigits`** tự động để giữ ≥ **3 chữ số có nghĩa**.
4. **Caution Dialog**: chỉ mở khi tap thủ công. Không auto lần đầu.
5. **Toggle mode**:
   - Simple → Advanced fill default `Euro`, `British Pound`.
   - Advanced → Simple lấy hàng 1-2.
6. **Favorite trạng thái**: 1 boolean dùng cho cả menu tool + Favorites grid List.
7. **Add Shortcut**: Android only.
8. **History**:
   - Item lưu: `mode` (simple/advanced), `currencyList[]`, `inputValue`, `outputValues`, `rateTimestamp`, `timestamp`.
   - Capacity: **100 bản ghi**, vượt → **FIFO** (xoá bản ghi cũ nhất).
   - Tap = restore; long-press = menu (Share, Xoá).
   - Có "Xoá tất cả" với confirm dialog.
9. **Currency Picker**:
   - Sort theo tên localized; search match localized + English + ISO.
   - Flag asset bundle local.
10. **Bottom Bar tool** ẩn Bottom Nav app khi vào tool; Back từ Bottom Bar = thoát tool về List.

## 2.6 Edge Cases

1. **Mở Picker khi cache rỗng + offline**: list currencies vẫn hiển thị (asset local); nếu user chọn và nhập → báo "không có tỷ giá".
2. **Simple → Advanced khi `from == EUR` hoặc `to == GBP`**: nếu hàng 3 (default EUR) trùng FROM/TO → thay bằng **USD**; nếu USD cũng trùng → **JPY**. Tương tự hàng 4 (default GBP). Thứ tự fallback chuẩn: `USD → JPY → AUD → CAD`.
3. **Currency Picker offline**: load asset local OK, không cần mạng.
4. **iOS user** tap menu → không thấy `Add Shortcut` (đã ẩn).
5. **Rate timestamp qua nửa đêm**: format `dd MMM yyyy, HH:mm:ss` theo locale.
6. **Share dialog khi không có app share nào**: Snackbar lỗi.
7. **Tap `±=` overlay rồi back hệ thống**: đóng overlay, không inject kết quả.
8. **Cache stale (vd 7 ngày)**: vẫn dùng, nhưng footer cảnh báo "Cached" + đề xuất Refresh.
9. **Số quá lớn vượt range**: hiển thị scientific notation theo quy ước Calculator (`|x| ≥ 1e15`).
10. **Đổi `Number Format` / `Decimal Digits` khi đang ở Currency**: input + output re-format ngay.
11. **Đổi Language khi mở Currency Picker**: tên localized + sort A→Z cập nhật ngay.
12. **Refresh trong khi đang fetch**: hủy request cũ, bắt đầu request mới.

---

# Phần 3. Feedback Screen

## 3.1 Mô tả
Màn riêng (không phải dialog) cho user báo lỗi / góp ý. **Implement trong MVP**.
Backend: **mailto** — mở email client mặc định với nội dung soạn sẵn.

## 3.2 Thành phần UI
- Header: `← Feedback`.
- **Dropdown** `In which place you met issue?` — auto-fill theo nơi mở (vd `Currency Converter`); user đổi được. Options: `Calculator`, `Currency Converter`, `Percentage Calculator`, `World Time Converter`, `Settings`, `Other`.
- Tiêu đề `What problems did you encounter?`
- **List preset issues** (single-select, list cố định trong MVP — **chờ stakeholder chốt nội dung đầy đủ**; mẫu tham khảo từ screenshot):
  - `Too long time to open this feature.`
  - `Long time to open other calculator types.`
  - `Sometimes crashes.`
  - `Wrong calculation result.`
  - `Inaccurate exchange rate.`
  - `UI / Display issue.`
- Section `Other`:
  - Textarea: `Please leave more details so that we can solve your problem as soon as possible.`
  - Icon **camera** ở góc trên-trái textarea → đính kèm tối đa 1 ảnh (chụp mới hoặc chọn từ gallery).
- Nút `Submit` (xanh đậm, full-width).

## 3.3 Hành động / Kết quả

| Hành động | Kết quả |
|---|---|
| Mở từ menu tool | Dropdown context auto chọn tên tool đó. |
| Tap dropdown | Mở picker chọn vị trí lỗi (list tool app). |
| Tap 1 preset issue | Chọn single-select; bỏ chọn issue trước. |
| Tap icon camera | Yêu cầu permission (camera + gallery); chọn xong gắn vào textarea preview. |
| Tap `Submit` | • Online → mở mailto (email client mặc định) với subject + body soạn sẵn + attachment nếu có ảnh.<br>• Offline → Snackbar lỗi "không có kết nối", **không queue**. |

## 3.4 Business Rules

1. **Single-select** issue (không multi).
2. List issue **cố định trong code**.
3. **Submit yêu cầu**: phải có ≥ 1 issue được chọn **HOẶC** textarea Other không rỗng.
4. **Mailto** (deep-link `mailto:` mở email client). Email đích cấu hình trong code/`AppConfig`.
5. **Subject mailto**: `[Calculator AI] Feedback - <feature_name>`.
6. **Body mailto** gồm:
   - Issue được chọn (nếu có).
   - Other text (nếu có).
   - Metadata: `app_version` (qua `package_info_plus`), `os_version`, `device_model` (qua `device_info_plus`), `language`, `locale`.
   - Ảnh đính kèm: nếu có ảnh, đính kèm dưới dạng attachment (mailto chỉ hỗ trợ attachment ở một số platform — fallback: ghi chú user tự đính kèm).
7. **Offline** → báo lỗi, không queue, không retry tự động.
8. **Quyền camera/gallery bị từ chối** → Dialog giải thích + hướng dẫn mở Settings.

## 3.5 Edge Cases

1. **Không có email client**: Snackbar lỗi "không tìm thấy email client".
2. **User huỷ ngoài mailto**: không có hành động phụ.
3. **Ảnh đính kèm quá lớn**: cảnh báo, có thể bị email client từ chối — không xử lý đặc biệt ở app.
4. **Đổi tool ở dropdown sau khi đã chọn issue**: giữ issue đã chọn (issue không phụ thuộc tool).
5. **Submit khi chỉ có ảnh, không có issue + text**: chặn submit, Snackbar nhắc cần mô tả.

---

# Phần 4. Tham chiếu

- Model: `CurrencyUnit`, `CurrencyHistory`, `ConverterItem`, `Favorite` — xem `feature_spec.md` §7 + `architecture.md` §5.
- Settings liên quan: `Number Format`, `Decimal Digits`, `Language`, `storeUrl` — xem `feature_setting.md`.
- UI quy ước: keypad, picker, dialog, snackbar — xem `ui_notes.md`.

---

> **Out of scope MVP** đã loại khỏi tài liệu này: quảng cáo (banner/interstitial/IAP), `dec/hex/bin` chuyển hệ cơ số.
