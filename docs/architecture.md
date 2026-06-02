# architecture.md — Calculator AI

Skeleton kiến trúc tổng quan. Chi tiết kỹ thuật theo từng module nằm trong file đặc tả tính năng tương ứng.

---

## 1. Nền tảng
- Mobile (Android + iOS); Flutter (mặc định) hoặc React Native.
- Offline-first; không backend; dữ liệu lưu cục bộ key-value (`SharedPreferences` / `AsyncStorage`).
- Chỉ Currency cần mạng; còn lại offline 100%.

---

## 2. Phân lớp
- **UI / Presentation**: Widgets/Components theo tab; bàn phím tuỳ biến; bottom nav shell.
- **State**: Provider/Bloc/Riverpod (Flutter) hoặc Redux/Zustand (RN). Unidirectional Data Flow; UI quan sát State, gửi Action.
- **Domain / Logic**: tính toán biểu thức, quy đổi tỷ giá, % và múi giờ; format số/ngày/giờ.
- **Data / Services**: Local Storage; HTTP client (tỷ giá); Native bridge (battery optimization, share, browser).
- **Utils**: I18n, NumberFormatter, DateTimeFormatter, Validation.

---

## 3. Cấu trúc thư mục (dự kiến)
```
/lib (Flutter) hoặc /src (RN)
  ├── app/           # entry, routing, theme
  ├── assets/        # icons, fonts, locale json
  ├── components/    # widget/component dùng chung
  ├── modules/
  │     ├── aitutor/
  │     ├── converter/      # list, currency, percentage, world_time
  │     ├── calculator/     # basic, scientific, history
  │     └── settings/
  ├── services/       # api_rates, storage, native_bridge
  ├── state/          # app_config, favorites, histories
  └── utils/          # formatters, validators, i18n
```

---

## 4. Luồng dữ liệu chính
- **Settings**: thay đổi → ghi local → emit → mọi màn hình re-render.
- **Currency**: load cache → nếu cũ/rỗng → fetch API → cache + emit; refresh thủ công bypass cache TTL.
- **Calculator**: input → Tokenizer → Validator → Shunting-Yard (infix → RPN) → Evaluator (theo AngleMode) → NumberFormatter → display; `=` thành công → lưu history; draft theo Setting.
- **Percentage**: tính bidirectional thuần local; ghi history khi commit.
- **World Time**: live timer / reference mode; offset/DST tính từ tzdata IANA local. **Không lưu history trong MVP.**

---

## 5. Mô hình dữ liệu (mức code, rút gọn)
- `AppConfig` — language, measurementUnit, numberFormat, decimalDigits, vibrationEnabled, soundEnabled, alwaysOnScreen, keepCalculatorRecord, startupCalculator, favoriteCurrency, favoriteTools[], privacyUrl, storeUrl, moreAppsUrl.
- `ConverterItem` — toolId, category, displayNameKey, iconName.
- `Favorite` — toolId, addedOrder.
- `CurrencyRate` — base, rates, timestamp.
- `CurrencyHistory` — isAdvancedMode, currencyList[], inputValue, outputValues, rateTimestamp, timestamp. **Capacity 100 FIFO.**
- `PercentageHistory` — mode, numberVal, percentageVal, changeVal, resultVal, isAddition, timestamp. **Capacity 100 FIFO.**
- `WorldTimeState` — selectedCityIds[], referenceCity? (IANA ID anchor), referenceTime?, sortCriteria, sortAscending. **Không lưu history.**
- `CityTimeEntry` (runtime, không persist) — timezoneId, cityNameKey, countryNameKey, displayTime, gmtOffset, isDST, isDeviceTimezone.
- `CalculatorHistory` — expression, resultRaw (double), resultDisplay (string format thời điểm tính), angleMode, timestamp. **Capacity 100 FIFO.**

Enum `NumberFormat`: `system | grouped_comma_dot (1,234.56) | grouped_dot_comma (1.234,56) | grouped_apostrophe_dot (1'234.56) | grouped_apostrophe_comma (1'234,56)`.

Chi tiết trường xem `feature_spec.md` §7.

---

## 6. Tích hợp ngoài
- **Currency Rate API**: HTTP, có timeout & retry; lỗi → fallback cache.
- **System Browser**: mở URL ngoài (Privacy, Rating, More Apps).
- **System Share**: chia sẻ kết quả / link app.
- **OS Settings (Android)**: deep-link tới Battery Optimization.

---

## 7. Xử lý lỗi
- try-catch mọi async (network, I/O).
- UI feedback: Snackbar/Toast ngắn; không chặn luồng.
- Currency offline + cache trống → màn hình lỗi + retry.

---

## 8. I18n & Formatting
- Mọi chuỗi UI lấy từ resource bundle theo `language`.
- Mọi số đi qua `NumberFormatter(numberFormat, decimalDigits)`.
- **Scientific notation** kích hoạt khi `|x| ≥ 1e15` hoặc `0 < |x| < 1e-6`. Trong khoảng còn lại, nếu số rất nhỏ gần biên dưới → mở rộng `decimalDigits` để giữ ≥ 3 chữ số có nghĩa.
- Mọi ngày/giờ đi qua `DateTimeFormatter(locale, timezone)`; World Time mặc định 24h.

---

## 9. Test
- Unit: logic tính toán, formatter, parser.
- Widget/Component: bàn phím, danh sách Favorites, picker Settings.
- Integration/E2E: luồng quy đổi, lưu/restore history, thay đổi Settings áp dụng tức thì.

**Target tối thiểu**: `CalculatorEngine ≥ 30 cases`, `NumberFormatter ≥ 20 cases`, `PercentageCubit formula ≥ 15 cases`, `CurrencyRepository cache ≥ 10 cases`, `WorldTimeCubit DST + reference ≥ 10 cases`.
