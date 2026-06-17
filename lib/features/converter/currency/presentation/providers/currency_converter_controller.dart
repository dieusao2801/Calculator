import 'dart:async';

import 'package:calculator/core/prefs/app_prefs.dart';
import 'package:calculator/features/converter/currency/domain/currency_conversion.dart';
import 'package:calculator/features/converter/currency/domain/default_currency_for_locale.dart';
import 'package:calculator/features/converter/currency/domain/entities/currency_rate.dart';
import 'package:calculator/features/converter/currency/presentation/providers/currency_history_controller.dart';
import 'package:calculator/features/converter/currency/presentation/providers/currency_rates_controller.dart';
import 'package:calculator/features/history/domain/entities/currency_convert_history.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/currency_converter_mode.dart';
import '../../domain/usecases/get_currency_converter_mode.dart';
import '../../domain/usecases/save_currency_converter_mode.dart';
import 'currency_converter_state.dart';

part 'currency_converter_controller.g.dart';

@riverpod
class CurrencyConverterController extends _$CurrencyConverterController {
  static const int _maxDigits = 15;
  static const Duration _saveHistoryDelay = Duration(milliseconds: 500);

  Timer? _saveHistoryTimer;
  bool _skipNextSave = false;

  /// User đã action (gõ/click focus/load history/swap...) trước khi `_init`
  /// xong. Cờ này để _init KHÔNG ghi đè user input do race với await rates.
  bool _userInteracted = false;

  @override
  CurrencyConverterState build() {
    ref.onDispose(() => _saveHistoryTimer?.cancel());
    // Recompute sau khi rates thay đổi do caller (page) chủ động gọi
    // `recomputeAfterRatesChanged()`. Initial load đã await rates trong `_init`.
    Future.microtask(_init);
    return const CurrencyConverterState();
  }

  Future<void> _init() async {
    final mode = await ref.read(getCurrencyConverterModeUseCaseProvider).execute();
    final prefs = ref.read(appPrefsProvider);

    final knownCodes = await _knownCodes();
    final String fromCode;
    final String toCode;
    if (prefs.currencyFromCode == null) {
      fromCode = defaultCurrencyForDeviceLocale(knownCodes);
      toCode = fromCode == 'USD' ? 'EUR' : 'USD';
    } else {
      fromCode = prefs.currencyFromCode!;
      toCode = prefs.currencyToCode ?? 'EUR';
    }

    final advCodes = prefs.currencyAdvancedCodes;
    final restored = CurrencyConverterState(
      mode: mode,
      fromCode: fromCode,
      toCode: toCode,
      fromInput: (prefs.currencyFromInput == null || prefs.currencyFromInput == '0') ? '' : prefs.currencyFromInput!,
      toInput: (prefs.currencyToInput == null || prefs.currencyToInput == '0') ? '' : prefs.currencyToInput!,
      advancedCodes: (advCodes != null && advCodes.isNotEmpty) ? advCodes : const ['USD', 'EUR', 'VND', 'GBP'],
      advancedActiveInput: (prefs.currencyAdvancedActiveInput == null || prefs.currencyAdvancedActiveInput == '0')
          ? ''
          : prefs.currencyAdvancedActiveInput!,
      focusedSimple: _clampSimple(prefs.currencyFocusedSimple ?? 0),
      focusedAdvanced: _clampAdvanced(prefs.currencyFocusedAdvanced ?? 0, (advCodes?.length ?? 4)),
      historyRecordSimple: prefs.currencyConvertHistorySimple,
      historyRecordAdvanced: prefs.currencyConvertHistoryAdvance,
    );

    if (!ref.mounted) return;
    if (_userInteracted) {
      // Race: user đã gõ input → giữ input/focused user vừa thao tác (vì input
      // có thể chưa flush vào prefs xong). Còn lại (mode, codes, history record)
      // ĐỀU restore từ prefs vì các action đó persist real-time, không race.
      state = _recompute(
        state.copyWith(
          mode: mode,
          fromCode: fromCode,
          toCode: toCode,
          advancedCodes: restored.advancedCodes,
          historyRecordSimple: prefs.currencyConvertHistorySimple,
          historyRecordAdvanced: prefs.currencyConvertHistoryAdvance,
        ),
      );
    } else {
      // Cold start: source = focused (không persist activeInputIndex riêng).
      state = _recompute(restored.copyWith(activeInputIndex: restored.focusedAdvanced));
    }
  }

  Future<Set<String>> _knownCodes() async {
    final rates = await ref.read(currencyRatesControllerProvider.future);
    return rates.map((r) => r.code).toSet();
  }

  // -------- Mode --------

  void setMode(CurrencyConverterMode mode) {
    state = state.copyWith(mode: mode);
    ref.read(saveCurrencyConverterModeUseCaseProvider).execute(mode);
  }

  void toggleMode() {
    final next = state.mode == CurrencyConverterMode.simple ? CurrencyConverterMode.advanced : CurrencyConverterMode.simple;
    setMode(next);
  }

  // -------- Focus --------

  void focusField(int index) {
    _userInteracted = true;
    if (state.mode == CurrencyConverterMode.advanced) {
      final clamped = _clampAdvanced(index, state.advancedCodes.length);
      // Chỉ đổi highlight, KHÔNG đụng vào source. Source promote khi user gõ.
      state = state.copyWith(focusedAdvanced: clamped);
      ref.read(appPrefsProvider).setCurrencyFocusedAdvanced(clamped);
    } else {
      final clamped = _clampSimple(index);
      state = state.copyWith(focusedSimple: clamped);
      ref.read(appPrefsProvider).setCurrencyFocusedSimple(clamped);
    }
  }

  /// Promote ô đang focus thành source (gọi trước khi edit nếu focus != source).
  /// Lấy giá trị đã convert đang hiển thị ở focus làm input mới.
  void _promoteFocusToSource() {
    if (state.focusedAdvanced == state.activeInputIndex) return;
    final newInput = displayForAdvancedIndex(state.focusedAdvanced);
    state = state.copyWith(
      activeInputIndex: state.focusedAdvanced,
      advancedActiveInput: newInput,
    );
  }

  // -------- List Management --------

  void addCurrency(String code) {
    if (state.advancedCodes.contains(code)) return;
    final newCodes = [...state.advancedCodes, code];
    state = state.copyWith(advancedCodes: newCodes);
    _persistAdvanced();
  }

  void removeCurrency(int index) {
    if (state.advancedCodes.length <= 2) return; // Giữ tối thiểu 2 dòng
    final newCodes = List<String>.from(state.advancedCodes)..removeAt(index);

    // Nếu xóa ô đang focus, chuyển focus về ô đầu tiên.
    int newFocus = state.focusedAdvanced;
    if (index == state.focusedAdvanced) {
      newFocus = 0;
    } else if (index < state.focusedAdvanced) {
      newFocus--;
    }

    // Nếu xóa ô đang là source → clear input, source về 0. Nếu xóa ô khác,
    // shift activeInputIndex theo nếu cần.
    int newSourceIndex = state.activeInputIndex;
    String newActiveInput = state.advancedActiveInput;
    if (index == state.activeInputIndex) {
      newSourceIndex = 0;
      newActiveInput = '';
    } else if (index < state.activeInputIndex) {
      newSourceIndex--;
    }

    state = state.copyWith(
      advancedCodes: newCodes,
      focusedAdvanced: newFocus,
      activeInputIndex: newSourceIndex,
      advancedActiveInput: newActiveInput,
    );
    _persistAdvanced();
  }

  // -------- Input editing --------
  // (Giữ nguyên logic append/back/clear đã sửa ở bước trước)

  void appendDigit(String digit) {
    _userInteracted = true;
    if (state.mode == CurrencyConverterMode.simple) {
      _editSimple((cur) => _append(cur, digit));
    } else {
      _promoteFocusToSource();
      state = state.copyWith(advancedActiveInput: _append(state.advancedActiveInput, digit));
      _persistAdvanced();
    }
    _scheduleSaveHistory();
  }

  void backspace() {
    _userInteracted = true;
    if (state.mode == CurrencyConverterMode.simple) {
      _editSimple(_back);
    } else {
      _promoteFocusToSource();
      state = state.copyWith(advancedActiveInput: _back(state.advancedActiveInput));
      _persistAdvanced();
    }
    _scheduleSaveHistory();
  }

  void clearAll() {
    _userInteracted = true;
    if (state.mode == CurrencyConverterMode.simple) {
      state = state.copyWith(fromInput: '', toInput: '');
      _persistSimpleInputs();
    } else {
      // Giữ activeInputIndex, chỉ clear giá trị → mọi ô về empty.
      state = state.copyWith(advancedActiveInput: '');
      _persistAdvanced();
    }
  }

  void swap() {
    _userInteracted = true;
    state = _recompute(state.copyWith(fromCode: state.toCode, toCode: state.fromCode));
    _saveSimpleModeStateToPrefs();
    _scheduleSaveHistory();
  }

  void setFromCurrency(String code) {
    if (state.fromCode == code) return;
    // Nếu đang dùng history rate Simple + code mới không có trong record → stop
    // (P6 sẽ wrap confirm dialog quanh action này; hiện tại stop ngay).
    if (state.isConvertByHistoryRate &&
        state.mode == CurrencyConverterMode.simple &&
        !historyContainsCode(state.historyRecordSimple, code)) {
      stopConvertByHistoryRate(CurrencyConverterMode.simple);
    }
    state = _recompute(state.copyWith(fromCode: code));
    _saveSimpleModeStateToPrefs();
  }

  void setToCurrency(String code) {
    if (state.toCode == code) return;
    if (state.isConvertByHistoryRate &&
        state.mode == CurrencyConverterMode.simple &&
        !historyContainsCode(state.historyRecordSimple, code)) {
      stopConvertByHistoryRate(CurrencyConverterMode.simple);
    }
    state = _recompute(state.copyWith(toCode: code));
    _saveSimpleModeStateToPrefs();
  }

  void setAdvancedCurrency(int index, String code) {
    if (index < 0 || index >= state.advancedCodes.length) return;
    if (state.advancedCodes[index] == code) return;
    if (state.isConvertByHistoryRate &&
        state.mode == CurrencyConverterMode.advanced &&
        !historyContainsCode(state.historyRecordAdvanced, code)) {
      stopConvertByHistoryRate(CurrencyConverterMode.advanced);
    }
    final newCodes = List<String>.from(state.advancedCodes);
    newCodes[index] = code;
    state = _recompute(state.copyWith(advancedCodes: newCodes));
    _persistAdvanced();
  }

  /// Stop convert by history rate cho [mode]. `stopConvertByHistoryRate`.
  /// Gọi khi: rates refresh thành công, hoặc user đổi code mà code mới không nằm
  /// trong record (P6 sẽ wrap thêm confirm dialog).
  void stopConvertByHistoryRate(CurrencyConverterMode mode) {
    if (mode == CurrencyConverterMode.simple) {
      if (state.historyRecordSimple == null) return;
      state = state.copyWith(historyRecordSimple: null);
    } else {
      if (state.historyRecordAdvanced == null) return;
      state = state.copyWith(historyRecordAdvanced: null);
    }
    _persistHistoryRecord(mode);
  }

  /// Fill state từ 1 history record + auto switch mode nếu cần. Set flag để
  /// debounce save không trigger lại record vừa load.
  ///
  /// Mark `isConvertByHistoryRate` nếu `h.ratesLastUpdated < newestRateTime`
  void loadFromHistory(CurrencyConvertHistory h) {
    _userInteracted = true;
    _skipNextSave = true;
    _saveHistoryTimer?.cancel();

    final rates = ref.read(currencyRatesControllerProvider).value ?? const <CurrencyRate>[];
    final newest = newestRateTime(rates);
    final shouldUseHistoryRate = newest != null && h.ratesLastUpdated.isBefore(newest);

    final isAdvanced = h.currencyCode3 != null && h.currencyCode4 != null;
    if (isAdvanced) {
      final codes = [h.currencyCode1, h.currencyCode2, h.currencyCode3!, h.currencyCode4!];
      state = _recompute(
        state.copyWith(
          mode: CurrencyConverterMode.advanced,
          advancedCodes: codes,
          advancedActiveInput: h.amount1,
          activeInputIndex: 0,
          focusedAdvanced: 0,
          historyRecordAdvanced: shouldUseHistoryRate ? h : null,
        ),
      );
      ref.read(saveCurrencyConverterModeUseCaseProvider).execute(CurrencyConverterMode.advanced);
      _persistAdvanced();
      _persistHistoryRecord(CurrencyConverterMode.advanced);
      ref.read(appPrefsProvider).setCurrencyFocusedAdvanced(0);
    } else {
      state = _recompute(
        state.copyWith(
          mode: CurrencyConverterMode.simple,
          fromCode: h.currencyCode1,
          toCode: h.currencyCode2,
          fromInput: h.amount1,
          toInput: h.amount2,
          focusedSimple: 0,
          historyRecordSimple: shouldUseHistoryRate ? h : null,
        ),
      );
      ref.read(saveCurrencyConverterModeUseCaseProvider).execute(CurrencyConverterMode.simple);
      _saveSimpleModeStateToPrefs();
      _persistHistoryRecord(CurrencyConverterMode.simple);
      ref.read(appPrefsProvider).setCurrencyFocusedSimple(0);
    }
  }

  // -------- Display helpers --------

  String displayForAdvancedIndex(int i) {
    if (i == state.activeInputIndex) return state.advancedActiveInput;
    if (state.advancedActiveInput.isEmpty) return '';
    final rates = ref.read(currencyRatesControllerProvider).value ?? const <CurrencyRate>[];
    final fromCode = state.advancedCodes[state.activeInputIndex];
    final toCode = state.advancedCodes[i];
    return convertCurrency(rates, fromCode, toCode, state.advancedActiveInput, historyOverride: state.historyRecordAdvanced) ??
        '';
  }

  /// Wrapper cho [ref.listen] rates: refresh state hiện tại theo rates mới.
  void recomputeAfterRatesChanged() => state = _recompute(state);

  /// Tính state mới từ [s] dựa trên rates hiện tại, KHÔNG set state.
  /// Caller compose state mới rồi `state = _recompute(...)` để set 1 lần,
  /// tránh double-mutation khi đổi code + recompute input.
  CurrencyConverterState _recompute(CurrencyConverterState s) {
    final rates = ref.read(currencyRatesControllerProvider).value ?? const <CurrencyRate>[];
    if (rates.isEmpty) return s;

    if (s.mode == CurrencyConverterMode.simple) {
      final h = s.historyRecordSimple;
      if (s.focusedSimple == 0) {
        if (s.fromInput.isEmpty) return s.toInput.isEmpty ? s : s.copyWith(toInput: '');
        final converted = convertCurrency(rates, s.fromCode, s.toCode, s.fromInput, historyOverride: h) ?? '';
        return converted == s.toInput ? s : s.copyWith(toInput: converted);
      } else {
        if (s.toInput.isEmpty) return s.fromInput.isEmpty ? s : s.copyWith(fromInput: '');
        final converted = convertCurrency(rates, s.toCode, s.fromCode, s.toInput, historyOverride: h) ?? '';
        return converted == s.fromInput ? s : s.copyWith(fromInput: converted);
      }
    }
    // Advanced — `displayForAdvancedIndex` compute on-the-fly; chỉ cần state mới
    // để trigger rebuild widget khi rates đổi.
    return s.copyWith();
  }

  // -------- Internals --------

  int _clampSimple(int focus) => (focus < 0 || focus > 1) ? 0 : focus;

  int _clampAdvanced(int focus, int count) => (focus < 0 || focus >= count) ? 0 : focus;

  void _editSimple(String Function(String current) edit) {
    final rates = ref.read(currencyRatesControllerProvider).value ?? const <CurrencyRate>[];
    final h = state.historyRecordSimple;
    if (state.focusedSimple == 0) {
      final next = edit(state.fromInput);
      final converted = next.isEmpty
          ? ''
          : (convertCurrency(rates, state.fromCode, state.toCode, next, historyOverride: h) ?? '');
      state = state.copyWith(fromInput: next, toInput: converted);
    } else {
      final next = edit(state.toInput);
      final converted = next.isEmpty
          ? ''
          : (convertCurrency(rates, state.toCode, state.fromCode, next, historyOverride: h) ?? '');
      state = state.copyWith(toInput: next, fromInput: converted);
    }
    _persistSimpleInputs();
  }

  String _append(String current, String digit) {
    if (digit == '.') {
      if (current.contains('.')) return current;
      if (current.isEmpty) return '0.';
      return '$current.';
    }
    String next;
    if (current == '' || current == '0') {
      if (digit == '0' || digit == '00') return current == '0' ? '0' : '';
      next = digit;
    } else {
      next = current + digit;
    }
    if (next.replaceAll('.', '').length > _maxDigits) return current;
    return next;
  }

  String _back(String current) {
    if (current.length <= 1) return '';
    return current.substring(0, current.length - 1);
  }

  // -------- Persistence (fire-and-forget) --------

  void _persistSimpleInputs() {
    final prefs = ref.read(appPrefsProvider);
    prefs.setCurrencyFromInput(state.fromInput);
    prefs.setCurrencyToInput(state.toInput);
  }

  /// Lưu toàn bộ trạng thái hiện tại của chế độ Đơn giản (Simple Mode) vào SharedPreferences.
  /// Bao gồm: Cặp mã tiền tệ (From/To) và các giá trị số đang nhập dở ở cả 2 ô.
  /// Việc này giúp ứng dụng khôi phục chính xác trạng thái cuối cùng khi người dùng mở lại app.
  void _saveSimpleModeStateToPrefs() {
    final prefs = ref.read(appPrefsProvider);
    prefs.setCurrencyFromCode(state.fromCode);
    prefs.setCurrencyToCode(state.toCode);
    prefs.setCurrencyFromInput(state.fromInput);
    prefs.setCurrencyToInput(state.toInput);
  }

  void _persistAdvanced() {
    final prefs = ref.read(appPrefsProvider);
    prefs.setCurrencyAdvancedCodes(state.advancedCodes);
    prefs.setCurrencyAdvancedActiveInput(state.advancedActiveInput);
  }

  /// Persist history rate state cho [mode]. Lưu record full nếu non-null, hoặc
  /// clear pref nếu đã stop convert by history rate (state = null).
  void _persistHistoryRecord(CurrencyConverterMode mode) {
    final prefs = ref.read(appPrefsProvider);
    if (mode == CurrencyConverterMode.simple) {
      final h = state.historyRecordSimple;
      if (h != null) {
        prefs.setCurrencyConvertHistorySimple(h);
      } else {
        prefs.clearCurrencyConvertHistorySimple();
      }
    } else {
      final h = state.historyRecordAdvanced;
      if (h != null) {
        prefs.setLastCurrencyConvertHistoryAdvance(h);
      } else {
        prefs.clearCurrencyConvertHistoryAdvance();
      }
    }
  }

  // -------- History save (debounce) --------

  void _scheduleSaveHistory() {
    if (_skipNextSave) {
      _skipNextSave = false;
      return;
    }
    _saveHistoryTimer?.cancel();
    _saveHistoryTimer = Timer(_saveHistoryDelay, _saveCurrentToHistory);
  }

  Future<void> _saveCurrentToHistory() async {
    final rates = ref.read(currencyRatesControllerProvider).value ?? const <CurrencyRate>[];
    if (rates.isEmpty) return;

    final history = _buildHistorySnapshot(rates);
    if (history == null) return;

    await ref.read(currencyHistoryControllerProvider.notifier).saveIfNotDuplicate(history);
  }

  /// Build snapshot history từ state hiện tại. Trả null nếu không đủ điều kiện
  /// lưu (input chính = 0 hoặc rỗng, hoặc code thiếu rate trong DB).
  CurrencyConvertHistory? _buildHistorySnapshot(List<CurrencyRate> rates) {
    final now = DateTime.now();
    final h = state.currentHistoryRecord;
    final serverTime = DateTime.fromMillisecondsSinceEpoch(ref.read(appPrefsProvider).currencyTimeServer);

    if (state.mode == CurrencyConverterMode.simple) {
      final from = state.fromInput;
      if (from.isEmpty || _isZero(from)) return null;
      // Dùng effective rate (history nếu đang convert by history rate, else current).
      final rateFrom = effectiveRateOf(rates, state.fromCode, h);
      final rateTo = effectiveRateOf(rates, state.toCode, h);
      if (rateFrom == null || rateTo == null) return null;
      final updatedAt = h?.ratesLastUpdated ?? serverTime;
      return CurrencyConvertHistory(
        ratesLastUpdated: updatedAt,
        currencyCode1: state.fromCode,
        exchangeRate1: rateFrom.toString(),
        amount1: state.fromInput,
        currencyCode2: state.toCode,
        exchangeRate2: rateTo.toString(),
        amount2: state.toInput,
        createdTime: now,
      );
    }

    // Advanced — cần 4 ô non-empty và input chính != 0
    final active = state.advancedActiveInput;
    if (active.isEmpty || _isZero(active)) return null;
    final codes = state.advancedCodes;
    final rs = codes.map((c) => effectiveRateOf(rates, c, h)).toList();
    if (rs.any((r) => r == null)) return null;

    final amounts = List.generate(state.advancedCodes.length, (i) => displayForAdvancedIndex(i));
    if (amounts.any((a) => a.isEmpty)) return null;

    final updatedAt = h?.ratesLastUpdated ?? serverTime;
    return CurrencyConvertHistory(
      ratesLastUpdated: updatedAt,
      currencyCode1: codes[0],
      exchangeRate1: rs[0].toString(),
      amount1: amounts[0],
      currencyCode2: codes[1],
      exchangeRate2: rs[1].toString(),
      amount2: amounts[1],
      currencyCode3: codes.length > 2 ? codes[2] : null,
      exchangeRate3: rs.length > 2 ? rs[2].toString() : null,
      amount3: amounts.length > 2 ? amounts[2] : null,
      currencyCode4: codes.length > 3 ? codes[3] : null,
      exchangeRate4: rs.length > 3 ? rs[3].toString() : null,
      amount4: amounts.length > 3 ? amounts[3] : null,
      createdTime: now,
    );
  }

  bool _isZero(String s) {
    final d = double.tryParse(s.endsWith('.') ? '${s}0' : s);
    return d == null || d == 0.0;
  }
}
