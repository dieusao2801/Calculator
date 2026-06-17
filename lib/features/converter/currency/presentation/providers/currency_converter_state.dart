import 'package:calculator/features/history/domain/entities/currency_convert_history.dart';
import 'package:flutter/foundation.dart';

import '../../domain/entities/currency_converter_mode.dart';

/// Sentinel để phân biệt "không truyền" với "truyền null" cho nullable field
/// trong [CurrencyConverterState.copyWith].
const Object _unset = Object();

@immutable
class CurrencyConverterState {
  const CurrencyConverterState({
    this.mode = CurrencyConverterMode.simple,
    this.fromCode = 'USD',
    this.toCode = 'EUR',
    this.fromInput = '',
    this.toInput = '',
    this.advancedCodes = const ['USD', 'EUR', 'VND', 'GBP'],
    this.advancedActiveInput = '',
    this.activeInputIndex = 0,
    this.focusedSimple = 0,
    this.focusedAdvanced = 0,
    this.historyRecordSimple,
    this.historyRecordAdvanced,
  });

  final CurrencyConverterMode mode;

  /// Simple mode: 2 field từ/đến — chỉ lưu code, lookup name/rate qua `currencyRatesControllerProvider`.
  final String fromCode;
  final String toCode;
  final String fromInput;
  final String toInput;

  /// Advanced mode: danh sách field cùng lúc; chỉ 1 nguồn input ([advancedActiveInput])
  /// thuộc field [activeInputIndex], các field khác render bằng cách convert động.
  final List<String> advancedCodes;
  final String advancedActiveInput;

  /// Index của ô đang là **nguồn** input (data source) trong advanced mode.
  /// Tách khỏi [focusedAdvanced] (ô được highlight visual) để focus không tự
  /// trigger convert ngược — chỉ promote source khi user thực sự gõ.
  final int activeInputIndex;

  /// Index ô đang focus theo mode (lưu riêng để giữ vị trí khi switch mode).
  final int focusedSimple; // 0 = from, 1 = to
  final int focusedAdvanced; // 0..advancedCodes.length-1

  /// History record đang được dùng làm rate (mỗi mode lưu riêng)
  /// `mCurrencyHistorySimple` / `mCurrencyHistoryAdvance`). Non-null = đang
  /// convert by history rate cho mode tương ứng.
  final CurrencyConvertHistory? historyRecordSimple;
  final CurrencyConvertHistory? historyRecordAdvanced;

  /// Derive theo mode hiện tại — tiện cho widget render.
  int get focusedFieldIndex => mode == CurrencyConverterMode.simple ? focusedSimple : focusedAdvanced;

  CurrencyConvertHistory? get currentHistoryRecord =>
      mode == CurrencyConverterMode.simple ? historyRecordSimple : historyRecordAdvanced;

  bool get isConvertByHistoryRate => currentHistoryRecord != null;

  CurrencyConverterState copyWith({
    CurrencyConverterMode? mode,
    String? fromCode,
    String? toCode,
    String? fromInput,
    String? toInput,
    List<String>? advancedCodes,
    String? advancedActiveInput,
    int? activeInputIndex,
    int? focusedSimple,
    int? focusedAdvanced,
    Object? historyRecordSimple = _unset,
    Object? historyRecordAdvanced = _unset,
  }) {
    return CurrencyConverterState(
      mode: mode ?? this.mode,
      fromCode: fromCode ?? this.fromCode,
      toCode: toCode ?? this.toCode,
      fromInput: fromInput ?? this.fromInput,
      toInput: toInput ?? this.toInput,
      advancedCodes: advancedCodes ?? this.advancedCodes,
      advancedActiveInput: advancedActiveInput ?? this.advancedActiveInput,
      activeInputIndex: activeInputIndex ?? this.activeInputIndex,
      focusedSimple: focusedSimple ?? this.focusedSimple,
      focusedAdvanced: focusedAdvanced ?? this.focusedAdvanced,
      historyRecordSimple: identical(historyRecordSimple, _unset)
          ? this.historyRecordSimple
          : historyRecordSimple as CurrencyConvertHistory?,
      historyRecordAdvanced: identical(historyRecordAdvanced, _unset)
          ? this.historyRecordAdvanced
          : historyRecordAdvanced as CurrencyConvertHistory?,
    );
  }
}
