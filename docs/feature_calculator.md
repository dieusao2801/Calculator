# Đặc tả Chi tiết: Calculator (Màn hình Máy tính chính)

Tài liệu đặc tả chi tiết màn hình **Calculator** trong app Calculator AI.
Bám tài liệu tổng: `feature_spec.md`, `architecture.md`, `ui_notes.md`.

---

## 1. Mô tả (Description)

Tab **Calculator** là tab mặc định khi mở app, cung cấp máy tính 2 chế độ bàn phím:
- **Basic**: số học cơ bản + tiện ích (`±`, `%`, `1/x`, `x²`, `^`, `()`, rollback…).
- **Scientific**: hằng số (`π`, `e`, `φ`), `rand`, mũ/căn (`eˣ`, `10ˣ`, `√`, `∛`), logarit (`log`, `ln`), `|x|`, `!`, lượng giác `sin/cos/tan` + nghịch + hyperbolic + nghịch hyperbolic.

Tính nhẩm kết quả thời gian thực, lưu **History**, đổi **angle mode** ở header, tự lưu/khôi phục **biểu thức nháp (Draft)**.

> **Out of scope MVP**: chuyển hệ cơ số `dec/hex/bin`, quảng cáo, ad-free IAP.

---

## 2. Thành phần UI (UI Components)

### 2.1 Display Panel (vùng hiển thị)
Khối bo góc, nền sáng dịu. Thứ tự nội dung từ trên xuống:

1. **Header row** (chữ nhỏ, góc trên):
   - **Angle Mode Indicator** (`DEG` / `RAD` / `GRA`): chỉ hiển thị khi biểu thức **có** ít nhất 1 hàm lượng giác. Bấm vào nhãn để cycle `DEG → RAD → GRA → DEG`.
   - **History Preview**: hiển thị biểu thức gần nhất + icon đồng hồ (vd `1900×34*28/2 ⟳`); tap → mở màn History.
2. **Expression Line** (chữ lớn, đậm): biểu thức đang nhập (vd `12+3×4^2`).
3. **Result Line** (góc phải dưới, nhỏ hơn): kết quả nháp tức thời (vd `60`).

**Font auto-shrink**:
- Expression: mặc định `32sp`, tối thiểu `16sp`.
- Result: mặc định `48sp`, tối thiểu `20sp`.
- Khi chạm min → cho phép **scroll ngang**, không thu nhỏ tiếp.

### 2.2 Basic Keyboard
Lưới **7 hàng × 4 cột**:

| Hàng | Cột 1 | Cột 2 | Cột 3 | Cột 4 |
|---|---|---|---|---|
| 1 | **Toggle Scientific** (icon `fx`) | `^` (luỹ thừa) | `x²` | `↺` (rollback) |
| 2 | `±` | `%` | `1/x` | `⌫` |
| 3 | `C` (accent đỏ pastel) | `( )` | `000` | `÷` |
| 4 | `7` | `8` | `9` | `×` |
| 5 | `4` | `5` | `6` | `−` |
| 6 | `1` | `2` | `3` | `+` |
| 7 | `0` | `00` | **Dấu thập phân** (`.` hoặc `,` theo Settings) | `=` (accent cam) |

Quy ước màu: nút primary `=` cam; nút huỷ `C` đỏ pastel; số nền sáng; toán tử/tiện ích nền đậm hơn.

### 2.3 Scientific Keyboard
Lưới **7 hàng × 4 cột**, **thay thế** Basic khi toggle (Display + Bottom Nav giữ nguyên):

| Hàng | Cột 1 | Cột 2 | Cột 3 | Cột 4 |
|---|---|---|---|---|
| 1 | **Toggle Basic** (cùng icon `fx` ở vị trí cùng tọa độ) | `π` | `e` | `φ` |
| 2 | `rand` | `eˣ` | `10ˣ` | `√` |
| 3 | `∛` | `log` | `ln` | `|x|` |
| 4 | `!` | `sin` | `asin` | `sinh` |
| 5 | `asinh` | `cos` | `acos` | `cosh` |
| 6 | `acosh` | `tan` | `atan` | `tanh` |
| 7 | `atanh` | — | — | — |

> Không có hàng `dec/hex/bin`, không có phím `DEG/RAD/GRA` riêng (cycle qua tap nhãn header).
> Hàng 7 còn 3 ô trống — UI fill bằng `—` placeholder (disabled) để giữ grid đều.

### 2.4 Bottom Navigation
4 tab cố định: **AI Tutor · Converter · Calculator (active) · Settings**.
Tab active có màu nhấn (cam) cho cả icon và nhãn.

---

## 3. Hành động / Kết quả (Actions / Results)

| Hành động | Kết quả |
|---|---|
| Nhấn phím số / toán tử cơ bản | Chèn ký tự vào Expression Line; cập nhật Result Line tức thời nếu biểu thức hợp lệ. |
| Nhấn **Toggle `fx`** | Chuyển giữa Basic ⇄ Scientific. Display + biểu thức giữ nguyên. |
| Nhấn 1 phím **hàm** ở Scientific (vd `sin`, `log`, `√`) | Chèn cụm hàm + ngoặc mở (`sin(`) vào biểu thức → **tự động chuyển về Basic** để nhập tiếp số. |
| Nhấn hằng số (`π`, `e`, `φ`) hoặc `rand` ở Scientific | Chèn giá trị vào biểu thức. **Không** tự chuyển về Basic (cho phép chèn liên tục). |
| Nhấn nhãn **angle mode** ở header | Cycle `DEG → RAD → GRA → DEG`; nếu biểu thức có lượng giác, Result Line tính lại ngay. |
| **Nhấn giữ `( )`** | Bao toàn bộ biểu thức hiện tại trong ngoặc (`12+3×4` → `(12+3×4)`). |
| Nhấn `±` | Đổi dấu **operand hiện tại** (vd `5+12` → `5+(-12)`). Nếu biểu thức trống → `-0` và chờ nhập. |
| Nhấn `%` (theo kiểu calculator cầm tay) | `200+10%`=`220`, `200−10%`=`180`, `200×10%`=`20`, `200÷10%`=`2000`. |
| Nhấn `↺` (rollback) | Hoàn tác **1 action** gần nhất (vd huỷ cả cụm `sin(`), không xoá từng ký tự. |
| Nhấn `⌫` | Xoá 1 ký tự cuối Expression Line. |
| Nhấn `C` | Xoá sạch Expression + Result; reset rollback stack. |
| Nhấn `=` | • Biểu thức **hợp lệ** → lưu History (biểu thức + kết quả + angle mode + thời điểm); chuyển kết quả lên Expression Line dạng số khởi đầu cho phép mới.<br>• **Không hợp lệ** → Snackbar `"biểu thức không đúng định dạng"`, không lưu, không xoá. |
| Tap **History Preview** ở header | Mở màn History (danh sách + share + xoá từng/xoá tất cả). |
| Tap 1 item trong History | Khôi phục biểu thức + angle mode lên Display; đóng History. |
| Đổi tab → quay lại Calculator | Nếu `Keep Calculator Record` **bật**: khôi phục Draft. **Tắt**: hiển thị rỗng. |

---

## 4. Quy tắc nghiệp vụ (Business Rules)

1. **Angle Mode**
   - Lưu cùng `CalculatorHistory` để restore chính xác trạng thái.
   - Nhãn ở header **chỉ hiển thị** khi biểu thức chứa hàm lượng giác (sin/cos/tan + biến thể).
   - Cycle qua tap nhãn: `DEG → RAD → GRA → DEG`.
2. **Định dạng số**
   - Result Line + History đều đi qua `NumberFormatter(numberFormat, decimalDigits)` từ Settings.
   - Phím dấu thập phân trên keypad **đồng bộ** với Number Format (`.` hoặc `,`).
3. **Toán tử & cú pháp**
   - Nhập liên tiếp 2 toán tử nhị phân → toán tử mới **thay thế** toán tử cũ.
   - Nhấn `=` mà thiếu `)` → tự đóng đủ ngoặc trước khi tính.
   - `%` theo ngữ cảnh toán tử trước nó (cầm tay), không phải chia 100 thuần.
3. **Luỹ thừa**: dùng duy nhất toán tử `^`. Không có phím `xʸ` riêng.
4. **`rand`**: sinh số ngẫu nhiên trong `[0, 1)` theo chuẩn, hiển thị **15 chữ số có nghĩa** (significant digits) khi chèn vào biểu thức. Không scale — user tự nhân nếu cần khoảng khác.
5. **Giới hạn nhập (quy ước UI)**
   - Độ dài biểu thức tối đa: **50 ký tự**. Đây là quy ước UI (không phải giới hạn của parser/evaluator); đạt 50 → chặn nhập tiếp.
   - Phần thập phân của 1 số trong biểu thức: tối đa **10 chữ số**.
   - Vượt giới hạn → chặn nhập, không hộp thoại.
6. **Draft Persistence**
   - `Keep Calculator Record` **bật**: lưu Expression + angle mode hiện tại cục bộ; khôi phục khi quay lại tab hoặc mở lại app.
   - **Tắt**: xoá Draft khi rời tab Calculator hoặc đóng app.
7. **Toggle Basic ⇄ Scientific**: dùng **1 icon thống nhất** (đề xuất `fx`), đặt cùng tọa độ ở cả 2 keypad. Không dùng icon `X` đỏ (tránh nhầm với Close/Clear).
8. **Rollback**: action-based — mỗi lần chèn (số/toán tử/hàm/hằng số) là 1 action; `↺` undo 1 action gần nhất. Stack reset khi nhấn `C` hoặc `=`.
9. **History**
   - Lưu mỗi phép tính khi `=` hợp lệ.
   - Item gồm: `expression`, `resultRaw` (double), `resultDisplay` (string format thời điểm tính), `angleMode`, `timestamp`.
   - Tap = restore; long-press = menu (Share, Xoá).
   - Có nút "Xoá tất cả" với confirm dialog.
   - **Capacity**: tối đa **100 bản ghi**, vượt ngưỡng → xoá bản ghi cũ nhất (**FIFO**). MVP không cleanup theo thời gian.
   - **Re-format khi đổi Settings**: dùng `resultRaw` → `NumberFormatter.format(raw, currentConfig)` để render. `resultDisplay` chỉ dùng cho Share/Copy ở thời điểm xảy ra.

---

## 5. Trường hợp ngoại lệ (Edge Cases)

1. **Chia cho 0 / căn âm / log số ≤ 0 / kết quả `Infinity` / `NaN`** → Snackbar `"giá trị tính vượt phạm vi"`. Không lưu History.
2. **Result quá lớn / quá nhỏ** → hiển thị dạng khoa học (vd `1.23e+15`) khi `|x| ≥ 1e15` hoặc `0 < |x| < 1e-6`; vẫn áp Decimal Digits cho phần định trị.
3. **Đổi Settings (Number Format / Decimal Digits) khi đang hiển thị kết quả** → Display tự re-format ngay, không cần nhập lại.
4. **Đổi Language khi đang ở Calculator** → nhãn Bottom Nav + Snackbar i18n update; biểu thức/kết quả giữ nguyên.
5. **Nhấn `⌫` hoặc `↺` khi biểu thức rỗng** → no-op, không crash, không phản hồi rung/âm thanh.
6. **Rollback khi vừa mở app / vừa nhấn `C` / `=`** → phím `↺` vô hiệu hoá (mờ).
7. **Nhập liên tiếp 2 toán hạng không có toán tử** → chèn ngầm `×` (vd `2π` hiểu là `2×π`); nếu không hợp lệ → coi là cú pháp sai khi `=`.
8. **Toggle Basic ⇄ Scientific giữa lúc đang nhập** → giữ nguyên Expression + Result + caret position.
9. **Nhấn hàm lượng giác xong rồi xoá hết** → angle mode indicator ẩn lại; angle mode giá trị vẫn được giữ trong state để dùng cho lượng giác tiếp theo.
10. **Mất focus / app vào background**:
    - `Keep Calculator Record` bật → ghi Draft, quay lại restore đúng trạng thái.
    - Tắt → khi resume, Display rỗng.
11. **App version cũ có Draft với angle mode không hợp lệ** → fallback `DEG`.
12. **Long-press `( )` khi biểu thức trống** → no-op.
13. **Nhấn `=` khi biểu thức thiếu `)` đóng** → tự đóng đủ ngoặc trước khi evaluate; nếu sau khi đóng vẫn invalid → Snackbar lỗi cú pháp.
14. **Calculator Overlay (từ Currency/Percentage)** ≠ Calculator chính: overlay không lưu vào Calculator History; overlay = subset Basic + chấp nhận chuỗi raw để inject về field focus.

---

## 6. Tham chiếu

- Model: `CalculatorHistory` — xem `feature_spec.md` §7.7 và `architecture.md` §5.
- Quy ước UI/keypad/animation: `ui_notes.md` §3, §5.
- Settings liên quan: `Number Format`, `Decimal Digits`, `Keep Calculator Record`, `Vibration`, `Sound` — xem `feature_setting.md`.

---

> Tất cả câu hỏi mở của màn hình Calculator đã được chốt. Sửa đổi tiếp theo bám tài liệu này.
