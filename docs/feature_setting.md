# Đặc tả Chi tiết: Tab Settings (Màn hình Cài đặt)

Tài liệu này đặc tả chi tiết giao diện người dùng (UI), hành động/kết quả (UX), các quy tắc nghiệp vụ (Business Rules) và các trường hợp biên (Edge Cases) của Tab Settings trong ứng dụng Calculator AI.

---

## 1. Mô tả (Description)

Tab **Settings** là trung tâm cấu hình cá nhân hoá của ứng dụng, cho phép người dùng điều chỉnh hành vi, ngôn ngữ, định dạng hiển thị, phản hồi cảm giác và các liên kết phụ trợ. Mọi thay đổi có hiệu lực **ngay lập tức** mà không cần nhấn nút Lưu (Save) và không có tính năng Khôi phục mặc định (Restore default).

Settings được tổ chức thành 3 nhóm rõ ràng:
*   **System Settings**: Cấu hình hành vi cốt lõi của ứng dụng.
*   **Chat Settings** *(AI Tutor)*: Quản lý dữ liệu hội thoại với AI.
*   **Developer Settings** *(Other)*: Các liên kết ngoài và thông tin phụ trợ.

---

## 2. Thành phần UI (UI Components)

### 2.1 Khu vực hành động nhanh (Quick Action Buttons)
Nằm ở phía trên cùng của màn hình, trước danh sách cài đặt, bố cục 2 cột ngang:
*   **Nút Themes** (biểu tượng bảng màu): Truy cập nhanh vào màn hình cài đặt chủ đề / giao diện màu sắc của ứng dụng.
*   **Nút Help** (biểu tượng dấu hỏi): Mở trang trợ giúp / hướng dẫn sử dụng ứng dụng.

### 2.2 Nhóm SYSTEM SETTINGS
Tiêu đề phân nhóm in đậm, chữ hoa. Mỗi mục gồm: icon đại diện (bên trái) + nhãn tiêu đề (màu tối, đậm) + nhãn giá trị hiện tại bên dưới (màu xanh dương nhạt) + chevron `>` hoặc Toggle switch (bên phải).

| Mục | Nhãn giá trị mẫu | Loại UI | Mặc định |
| :--- | :--- | :--- | :--- |
| **Language** | `Auto` | Picker (`>`) | Theo hệ thống |
| **Startup Calculator** | `Last Used Calculator` | Picker (`>`) | Last Used |
| **Measurement unit** | `As system` | Picker (`>`) | System |
| **Number format** | `Auto` | Picker (`>`) | System |
| **Decimal Digits** | `1,000.2` *(preview định dạng)* | Picker (`>`) | 2 |
| **App Widget** *(MVP placeholder)* | *(không có giá trị phụ)* | Picker / Điều hướng (`>`) | — |
| **Notification Shortcut** *(MVP placeholder)* | *(không có giá trị phụ)* | Picker / Điều hướng (`>`) | — |
| **Launcher Shortcut** *(MVP placeholder)* | *(không có giá trị phụ)* | Picker / Điều hướng (`>`) | — |
| **Vibration** | `Button feedback` | Toggle | Off |
| **Sound** | `Sound when pressing key` | Toggle | Off |
| **Always on screen** | `Keep the screen on` | Toggle | Off |
| **Keep calculator record** | `Keep the last calculator record` | Toggle | Off |
| **Battery Optimization** *(Android only)* | *(hiển thị có điều kiện)* | Nút điều hướng | — |

> **Lưu ý UX**: Nhãn giá trị hiện tại của mục **Decimal Digits** hiển thị dưới dạng **preview số mẫu** (ví dụ: `1,000.2`) thay vì chỉ hiển thị số chữ số đơn thuần (`2`). Điều này giúp người dùng hình dung trực tiếp kết quả định dạng trước khi vào picker.

### 2.3 Nhóm CHAT SETTINGS (AI Tutor)
> **Vị trí xác nhận**: Nhóm này nằm trong Tab Settings (không tách sang màn hình riêng trong tab AI Tutor). Lý do: giữ thống nhất tất cả cấu hình tại một nơi.

Tiêu đề phân nhóm in đậm. Các mục là flat navigation rows, không có giá trị hiện tại và không có toggle:

*   **Chat History**: Mở danh sách các hội thoại đã thực hiện với AI Tutor.
*   **Clear Chat History**: Xóa toàn bộ lịch sử hội thoại.

### 2.4 Nhóm DEVELOPER SETTINGS (Other)
Tên hiển thị trên giao diện: **DEVELOPER SETTINGS**. Các mục là flat navigation rows:

| Mục | Nhãn chính thức trên UI | Hành vi |
| :--- | :--- | :--- |
| **Privacy Policy** | Privacy Policy | Mở liên kết ngoài trong trình duyệt hệ thống. |
| **Report Problem** | Report problem | Mở màn hình Feedback với trường vị trí lỗi được điền sẵn "Settings". |
| **Rating** | Rate us 5 stars | Mở trang đánh giá ứng dụng trên cửa hàng (App Store / Google Play). |
| **Share** | Share | Mở hộp chia sẻ hệ thống (System Share Sheet) kèm liên kết tải app. |
| **More Apps** | More apps | Mở trang danh sách ứng dụng khác của nhà phát triển. |
| **App Version** | *(phía cuối danh sách)* | Hiển thị số phiên bản hiện tại của app, không tương tác. |

---

## 3. Hành động / Kết quả (Actions / Results)

| Hành động của Người dùng | Kết quả hệ thống / Giao diện phản hồi |
| :--- | :--- |
| **Nhấn nút Themes** | Mở màn hình/dialog chọn chủ đề giao diện ứng dụng. |
| **Nhấn nút Help** | Mở trang trợ giúp (màn hình nội bộ hoặc liên kết web ngoài). |
| **Nhấn vào mục Picker** (Language, Number Format, v.v.) | Mở Bottom Sheet hoặc Dialog hiển thị danh sách tuỳ chọn dạng `RadioGroup`. Khi chọn một mục, dialog tự đóng và cấu hình mới được áp dụng ngay lập tức. |
| **Chuyển Toggle** (Vibration, Sound, v.v.) | Thay đổi trạng thái bật/tắt ngay lập tức. Giao diện toggle cập nhật màu sắc tương ứng (xanh = bật, xám = tắt). |
| **Nhấn mục Chat History** | Mở màn hình danh sách toàn bộ hội thoại AI Tutor đã lưu. |
| **Nhấn mục Clear Chat History** | Hiển thị Dialog xác nhận. Nếu người dùng đồng ý → xóa toàn bộ lịch sử hội thoại cục bộ. |
| **Nhấn mục Privacy Policy / Rate us / Share / More Apps** | Gọi Intent/URL tương ứng để mở trình duyệt hoặc cửa hàng ứng dụng. |
| **Nhấn mục Report Problem** | Mở màn hình Feedback với trường "In which place you met issue?" được điền sẵn giá trị `Settings`. |
| **Nhấn mục Battery Optimization** *(Android)* | Mở màn hình cài đặt hệ thống Android tại mục Battery Optimization của app. |

---

## 4. Quy tắc Nghiệp vụ (Business Rules)

1.  **Áp dụng tức thì (Instant Apply)**:
    *   Mọi thay đổi cấu hình (Picker hoặc Toggle) được áp dụng và phản ánh trên toàn bộ ứng dụng ngay khi người dùng xác nhận lựa chọn — không cần nút Save và không có cơ chế Restore Default.

2.  **Cơ chế Picker (Bottom Sheet / RadioGroup)**:
    *   Khi nhấn vào một mục Picker, hệ thống mở Bottom Sheet hoặc Dialog chứa danh sách tuỳ chọn với RadioGroup.
    *   Tùy chọn đang được chọn được đánh dấu radio bullet rõ ràng.
    *   Ngay khi người dùng chọn một mục mới, dialog tự đóng và nhãn giá trị hiện tại dưới tiêu đề mục cập nhật ngay.

3.  **Hiển thị có điều kiện — Battery Optimization (Android only)**:
    *   Mục này chỉ hiển thị trên nền tảng Android.
    *   Chỉ hiển thị khi ứng dụng **chưa** được miễn tối ưu hóa pin.
    *   Khi ứng dụng được miễn (người dùng đã cấp quyền), mục này **tự ẩn**.
    *   Hệ thống tự kiểm tra lại trạng thái mỗi khi ứng dụng chuyển từ background về foreground (App Resume).

4.  **Ẩn liên kết khi thiếu URL**:
    *   Các mục trong nhóm Developer Settings (Privacy Policy, Rating, Share, More Apps) **chỉ hiển thị** khi URL tương ứng đã được cấu hình trong mã nguồn.
    *   Nếu URL chưa được cấu hình → ẩn mục đó hoàn toàn khỏi danh sách.

5.  **Đồng bộ Number Format & Decimal Digits trên toàn app**:
    *   Ngay sau khi thay đổi Number Format hoặc Decimal Digits, toàn bộ kết quả số đang hiển thị trên các màn hình khác (Calculator, Currency Converter, Percentage Calculator) phải được re-render theo định dạng mới.
    *   Nhãn preview ở mục Decimal Digits cũng cập nhật tương ứng (ví dụ: khi chọn 0 chữ số thập phân → preview hiển thị `1,000`).

6.  **Keep Calculator Record**:
    *   Bật: Tự động lưu biểu thức đang nhập dở trên Calculator. Khi người dùng rời và quay lại tab Calculator, biểu thức nháp được khôi phục nguyên vẹn.
    *   Tắt: Xóa biểu thức nháp mỗi khi người dùng thoát ứng dụng hoặc chuyển sang tab khác.

7.  **Clear Chat History — Không thể hoàn tác**:
    *   Thao tác xóa toàn bộ lịch sử hội thoại AI Tutor là không thể hoàn tác (no undo).
    *   Bắt buộc phải có bước xác nhận bằng Dialog trước khi thực hiện xóa.

8.  **Startup Calculator**:
    *   Cho phép chọn màn hình máy tính mặc định khi mở ứng dụng. Các tuỳ chọn dự kiến: `Last Used Calculator` (mặc định), `Basic Calculator`, `Scientific Calculator`.

---

## 5. Trường hợp Ngoại lệ (Edge Cases)

1.  **Mở liên kết ngoài thất bại**:
    *   Nếu thiết bị không có trình duyệt web hoặc không tìm thấy ứng dụng cửa hàng phù hợp → hiển thị Snackbar thông báo lỗi *"Không thể mở liên kết"*.

2.  **Đổi Language khi màn hình khác đang mở**:
    *   Khi người dùng đổi ngôn ngữ, toàn bộ nhãn văn bản trên màn hình Settings cập nhật ngay lập tức.
    *   Cần xác nhận: Các tab khác (Calculator, Converter) có cần reload fragment/view để áp dụng ngôn ngữ mới hay chỉ áp dụng cho lần điều hướng tiếp theo?

3.  **Battery Optimization — Người dùng từ chối cấp quyền**:
    *   Sau khi người dùng mở màn hình cài đặt hệ thống nhưng không cấp quyền rồi quay lại app → mục Battery Optimization tiếp tục hiển thị (không ẩn).
    *   Không hiển thị thêm bất kỳ dialog nhắc nhở nào; người dùng tự quyết định.

4.  **Toggle nhanh liên tục (Rapid toggle)**:
    *   Nếu người dùng bật/tắt một Toggle nhiều lần liên tiếp trong thời gian ngắn (ví dụ: Vibration), hệ thống chỉ lưu trạng thái của thao tác cuối cùng và không phát sinh lỗi ghi đè.

5.  **Decimal Digits và biểu thức Calculator đang hiển thị**:
    *   Khi người dùng giảm số chữ số thập phân (ví dụ từ 6 xuống 2) trong khi Calculator đang hiển thị một kết quả có nhiều chữ số thập phân hơn → kết quả hiển thị được làm tròn về đúng số chữ số mới mà không thay đổi giá trị nội bộ lưu trữ.

6.  **App Widget / Notification Shortcut / Launcher Shortcut — Từ chối quyền hệ thống**:
    *   Nếu người dùng không cấp quyền cần thiết (ví dụ: quyền tạo Launcher Shortcut trên Android) → hiển thị Dialog giải thích lý do cần quyền và hướng dẫn cách cấp quyền trong Settings hệ thống.

---

## 6. Điểm mở cần Stakeholder xác nhận (Open Questions)

1.  ✅ **Themes**: Không IAP trong MVP. Chỉ implement **Light/Dark toggle** + placeholder cho theme tuỳ chỉnh tương lai. Nút Themes mở `ThemesScreen` riêng.
2.  **Help**: Dẫn tới màn hình trợ giúp nội bộ hay liên kết web ngoài? Nếu là liên kết ngoài, có áp dụng quy tắc ẩn khi thiếu URL không?
3.  **Startup Calculator**: Danh sách đầy đủ các tùy chọn trong Picker là gì? (ví dụ: `Last Used`, `Basic`, `Scientific`, hay còn thêm chế độ nào nữa không?)
4.  **App Widget** *(MVP placeholder)*: Widget hiển thị gì? Kích thước & loại widget?
5.  **Notification Shortcut** *(MVP placeholder)*: Shortcut dẫn tới tính năng cụ thể nào của app?
6.  **Launcher Shortcut** *(MVP placeholder)*: Khác gì với **App Widget**? Shortcut icon đơn giản hay widget tương tác?
7.  ✅ **Chat Settings**: Nhóm **CHAT SETTINGS nằm trong Tab Settings**.
8.  ✅ **Tên nhóm thứ 3**: Tên chính thức là **`DEVELOPER SETTINGS`**.
9.  ✅ **Nhãn mục Rating**: Nhãn chính thức là **`Rate us 5 stars`**.
10. ✅ **App Version**: Hiển thị ở **cuối danh sách DEVELOPER SETTINGS**. Định dạng: `v2.1.0 (build 412)`.
11. **Email đích mailto Feedback**: chưa chốt (vd `support@tohsoft.com`?).
12. **List preset Feedback issues** đầy đủ: chưa chốt — xem `feature_converter.md` §3.2 cho mẫu tham khảo.

> Feedback Screen dùng chung — đặc tả chi tiết tại `feature_converter.md` §3.
