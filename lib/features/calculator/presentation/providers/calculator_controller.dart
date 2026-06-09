import 'dart:async';

import 'package:calculator/core/constants/calc_symbols.dart';
import 'package:calculator/features/calculator/domain/logic/calculator_engine.dart';
import 'package:calculator/features/calculator/domain/usecases/get_last_calculation_history.dart';
import 'package:calculator/features/calculator/domain/usecases/get_last_formula.dart';
import 'package:calculator/features/calculator/domain/usecases/save_last_formula.dart';
import 'package:calculator/features/calculator/presentation/providers/calculator_history_controller.dart';
import 'package:calculator/features/calculator/presentation/providers/calculator_state.dart';
import 'package:calculator/features/history/domain/entities/calculation_history.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'calculator_controller.g.dart';

@riverpod
class CalculatorController extends _$CalculatorController {
  final CalculatorEngine _engine = CalculatorEngine();
  Future<void>? _initFuture;

  @override
  CalculatorState build() {
    // Kích hoạt init lần đầu; splash có thể await qua init() để pre-warm.
    init();
    return const CalculatorState();
  }

  /// Pre-warm state từ DB (last record + last formula). Idempotent.
  Future<void> init() => _initFuture ??= _doInit();

  Future<void> _doInit() async {
    final results = await Future.wait<dynamic>([
      ref.read(getLastCalculationHistoryUseCaseProvider).execute(),
      ref.read(getLastFormulaUseCaseProvider).execute(),
    ]);

    final lastRecord = results[0] as CalculationHistory?;
    final expr = results[1] as String;

    state = state.copyWith(
      history: lastRecord != null ? "${lastRecord.expression} = ${lastRecord.result}" : state.history,
      expression: (expr.isNotEmpty && state.expression.isEmpty) ? expr : state.expression,
      cursorIndex: (expr.isNotEmpty && state.expression.isEmpty) ? expr.length : state.cursorIndex,
      previewResult: (expr.isNotEmpty && state.expression.isEmpty) ? _previewResultFromExpression(expr) : state.previewResult,
    );
  }

  /*
    Chức năng: Persist expression hiện tại xuống prefs.
    Gọi từ MyApp.onPause (fire-and-forget), từ equals() (fire-and-forget),
    hoặc từ chỗ cần await xong rồi mới tiếp tục (vd: clear history).
  */
  Future<void> persistExpression() async {
    await ref.read(saveLastFormulaUseCaseProvider).execute(state.expression);
  }

  void appendDigit(String digit) {
    final s = state;
    // Giới hạn 15 chữ số cho mỗi số hạng
    if (!s.justEvaluated && _engine.getLastNumberDigitCount(s.expression) >= 15) {
      state = s.copyWith(errorMessage: 'max_digits_exceeded');
      return;
    }

    String newExpr;
    int newCursor;

    if (s.justEvaluated) {
      newExpr = digit == '0' ? '' : digit;
      newCursor = newExpr.length;
    } else {
      // Chèn số vào vị trí con trỏ
      final prefix = s.expression.substring(0, s.cursorIndex);
      final suffix = s.expression.substring(s.cursorIndex);

      // Sử dụng logic appendDigit hiện tại nhưng áp dụng cho phần prefix
      final tempExpr = _engine.appendDigit(prefix, digit);
      newExpr = tempExpr + suffix;
      newCursor = tempExpr.length;
    }

    state = s.copyWith(
      expression: newExpr,
      previewResult: _previewResultFromExpression(newExpr),
      justEvaluated: false,
      clearError: true,
      cursorIndex: newCursor,
      canUndo: false,
    );
  }

  void appendDoubleZero() {
    final s = state;
    if (!s.justEvaluated && _engine.getLastNumberDigitCount(s.expression) >= 14) {
      state = s.copyWith(errorMessage: 'max_digits_exceeded');
      return;
    }

    final prefix = s.expression.substring(0, s.cursorIndex);
    final suffix = s.expression.substring(s.cursorIndex);
    final tempExpr = _engine.appendDoubleZero(prefix, justEvaluated: s.justEvaluated);
    final newExpr = tempExpr + suffix;

    state = s.copyWith(
      expression: newExpr,
      previewResult: _previewResultFromExpression(newExpr),
      justEvaluated: false,
      clearError: true,
      cursorIndex: tempExpr.length,
      canUndo: false,
    );
  }

  void appendTripleZero() {
    final s = state;
    if (!s.justEvaluated && _engine.getLastNumberDigitCount(s.expression) >= 13) {
      state = s.copyWith(errorMessage: 'max_digits_exceeded');
      return;
    }

    final prefix = s.expression.substring(0, s.cursorIndex);
    final suffix = s.expression.substring(s.cursorIndex);
    final tempExpr = _engine.appendTripleZero(prefix, justEvaluated: s.justEvaluated);
    final newExpr = tempExpr + suffix;

    state = s.copyWith(
      expression: newExpr,
      previewResult: _previewResultFromExpression(newExpr),
      justEvaluated: false,
      clearError: true,
      cursorIndex: tempExpr.length,
      canUndo: false,
    );
  }

  void appendDecimal() {
    final s = state;
    final prefix = s.expression.substring(0, s.cursorIndex);
    final suffix = s.expression.substring(s.cursorIndex);
    final tempExpr = _engine.appendDecimal(prefix, justEvaluated: s.justEvaluated);
    final newExpr = tempExpr + suffix;

    state = s.copyWith(
      expression: newExpr,
      previewResult: _previewResultFromExpression(newExpr),
      justEvaluated: false,
      clearError: true,
      cursorIndex: tempExpr.length,
      canUndo: false,
    );
  }

  void appendOperator(String op) {
    final s = state;
    String basePrefix;
    String suffix = "";

    if (s.justEvaluated && !s.hasError) {
      // Khi vừa có kết quả, lấy chính kết quả đó làm gốc để tính tiếp
      basePrefix = s.expression;
    } else {
      basePrefix = s.expression.substring(0, s.cursorIndex);
      suffix = s.expression.substring(s.cursorIndex);
    }

    final tempExpr = _engine.appendOperator(basePrefix, op);
    final newExpr = tempExpr + suffix;
    state = s.copyWith(
      expression: newExpr,
      previewResult: _previewResultFromExpression(newExpr),
      justEvaluated: false,
      clearError: true,
      cursorIndex: tempExpr.length,
      canUndo: false,
    );
  }

  void backspace() {
    final s = state;
    if (s.justEvaluated) {
      // Khi vừa có kết quả, nhấn Backspace sẽ chuyển sang chế độ sửa tiếp kết quả
      // mà không làm biến mất dòng history nhỏ ở trên
      state = s.copyWith(justEvaluated: false, canUndo: false);
      return;
    }

    if (s.cursorIndex == 0) return; // Không có gì đằng trước để xóa

    final prefix = s.expression.substring(0, s.cursorIndex);
    final suffix = s.expression.substring(s.cursorIndex);

    final newPrefix = prefix.substring(0, prefix.length - 1);
    final newExpr = newPrefix + suffix;

    state = s.copyWith(
      expression: newExpr,
      previewResult: _previewResultFromExpression(newExpr),
      clearError: true,
      cursorIndex: newPrefix.length,
      canUndo: false,
    );
  }

  void moveCursor(int index) {
    state = state.copyWith(cursorIndex: index.clamp(0, state.expression.length));
  }

  void clear() {
    // Chỉ xóa biểu thức nhập liệu, giữ lại history cuối cùng để người dùng quan sát
    state = state.copyWith(
      expression: '',
      previewResult: '',
      justEvaluated: false,
      cursorIndex: 0,
      clearError: true,
      canUndo: false,
    );
  }

  void clearErrorMessage() {
    state = state.copyWith(clearError: true);
  }

  void undo() {
    final s = state;
    if (!s.canUndo || s.previousExpression == null) return;

    // Khôi phục lại biểu thức và kết quả preview của phiên trước khi nhấn "="
    state = s.copyWith(
      expression: s.previousExpression,
      previewResult: s.previousPreviewResult,
      justEvaluated: false,
      canUndo: false,
      // Dùng xong thì disable
      cursorIndex: s.previousExpression!.length,
    );
  }

  void plusMinus() {
    final s = state;
    final prefix = s.expression.substring(0, s.cursorIndex);
    final suffix = s.expression.substring(s.cursorIndex);

    final tempExpr = _engine.plusMinus(prefix);
    final newExpr = tempExpr + suffix;
    state = s.copyWith(
      expression: newExpr,
      previewResult: _previewResultFromExpression(newExpr),
      justEvaluated: false,
      clearError: true,
      cursorIndex: tempExpr.length,
      canUndo: false,
    );
  }

  void percent() {
    final s = state;
    final prefix = s.expression.substring(0, s.cursorIndex);
    final suffix = s.expression.substring(s.cursorIndex);

    final tempExpr = _engine.percent(prefix);
    final newExpr = tempExpr + suffix;

    state = s.copyWith(
      expression: newExpr,
      previewResult: _previewResultFromExpression(newExpr),
      justEvaluated: false,
      clearError: true,
      cursorIndex: tempExpr.length,
      canUndo: false,
    );
  }

  void inverse() {
    final s = state;
    final prefix = s.expression.substring(0, s.cursorIndex);
    final suffix = s.expression.substring(s.cursorIndex);

    final tempExpr = _engine.inverse(prefix);
    final newExpr = tempExpr + suffix;

    state = s.copyWith(
      expression: newExpr,
      previewResult: _previewResultFromExpression(newExpr),
      justEvaluated: false,
      clearError: true,
      cursorIndex: tempExpr.length,
      canUndo: false,
    );
  }

  void square() {
    final s = state;
    final prefix = s.expression.substring(0, s.cursorIndex);
    final suffix = s.expression.substring(s.cursorIndex);

    final tempExpr = _engine.square(prefix);
    final newExpr = tempExpr + suffix;

    state = s.copyWith(
      expression: newExpr,
      previewResult: _previewResultFromExpression(newExpr),
      justEvaluated: false,
      clearError: true,
      cursorIndex: tempExpr.length,
      canUndo: false,
    );
  }

  void sqrtPi() {
    state = state.copyWith(errorMessage: 'coming_soon');
  }

  /// Cập nhật biểu thức và kết quả từ lịch sử
  void updateFromHistory(String expression, String result) {
    state = state.copyWith(
      expression: expression,
      previewResult: result,
      justEvaluated: false,
      cursorIndex: expression.length,
      clearError: true,
    );
  }

  void equals() async {
    final s = state;
    if (s.justEvaluated || s.expression.isEmpty) return;

    // Sử dụng chế độ strict: true để không bỏ qua các toán tử dở dang ở cuối
    final result = _engine.evaluate(s.expression, isStrict: true);
    if (result.errorKey != null) {
      state = s.copyWith(errorMessage: result.errorKey, canUndo: false); // Chắc chắn canUndo là false
      return;
    }

    final finalResult = result.result ?? '0';
    // Dùng expression đã chuẩn hóa (auto-close ngoặc) để history khớp với cái thực sự được eval.
    final normalizedExpression = _engine.normalize(s.expression, isStrict: true);

    state = s.copyWith(
      // Lưu trạng thái hiện tại vào bộ nhớ tạm để phục vụ Undo
      previousExpression: s.expression,
      previousPreviewResult: _previewResultFromExpression(s.expression),
      canUndo: true,
      // Kích hoạt nút Undo
      previewResult: '',
      expression: finalResult,
      justEvaluated: true,
      clearError: true,
      cursorIndex: finalResult.length,
    );

    // Thêm record vào history controller (optimistic update + save DB ngầm).
    unawaited(
      ref.read(calculatorHistoryControllerProvider.notifier).addRecord(expression: normalizedExpression, result: finalResult),
    );

    //Save last formula
    unawaited(persistExpression());
  }

  /// Chuyển đổi chuỗi biểu thức hiện tại thành kết quả hiển thị xem trước (Preview).
  /// - Trả về chuỗi rỗng nếu biểu thức chưa có toán tử hoặc đang kết thúc bằng toán tử chờ số (Infix).
  /// - Gọi Engine.evaluate để tính toán giá trị thực tế của biểu thức dở dang.
  String _previewResultFromExpression(String expr) {
    if (expr.isEmpty) return '';
    // Kiểm tra xem biểu thức có chứa ít nhất một toán tử hoặc ký hiệu đặc biệt hay không
    bool hasOperator = false;
    for (int i = 0; i < expr.length; i++) {
      if (_engine.isOperator(expr[i])) {
        hasOperator = true;
        break;
      }
    }

    final lastChar = expr[expr.length - 1];

    // Kiểm tra xem có phải đang nhập dở mẫu Inverse (vd: 9 × ( 1 ÷ ) không
    // Dùng endsWith thay vì contains để tránh bỏ sót các toán tử dở dang phía sau
    final isInverseEnding = expr.endsWith('1${CalculatorEngine.displayDivide}');

    // Gom nhóm các điều kiện KHÔNG hiện Preview:
    // 1. Chỉ là số thuần túy (không có phép tính) hoặc chỉ có 1 dấu mở ngoặc
    final isPureNumber = !hasOperator || (expr.length == 1 && lastChar == CalcSymbols.openBracket);

    // 2. Kết thúc bằng toán tử "đợi số" (Infix) nhưng không phải mẫu Inverse đặc biệt
    final isWaitingForOperand = _engine.isInfixOperator(lastChar) && !isInverseEnding;

    if (isPureNumber || isWaitingForOperand) {
      return '';
    }

    // Nếu có phép tính hoàn chỉnh (ví dụ: 98÷2 hoặc 9%), thực hiện tính toán preview
    final eval = _engine.evaluate(expr);
    if (eval.result == null) return '';

    // Cap 6 chữ số thập phân cho preview (final result sau '=' vẫn full precision).
    // Chỉ bỏ thousand separator; decimal '.' đã đúng format math.
    final mathRaw = eval.result!.replaceAll(CalcSymbols.groupSeparator, '');
    final value = double.tryParse(mathRaw);
    if (value == null) return eval.result!;
    return _engine.formatPreviewNumber(value);
  }

  /// Chèn biểu thức gốc (`item.expression`) vào vị trí hiện tại — smart insert
  /// có `×` ngầm và bọc `(...)` để giữ precedence.
  void restoreCalculation(CalculationHistory item) {
    _smartInsertToken(item.expression, wrapInBrackets: true);
  }

  /// Chèn kết quả (`item.result`) — token là số đơn nên không cần wrap.
  void restoreResult(CalculationHistory item) {
    _smartInsertToken(item.result, wrapInBrackets: false);
  }

  void _smartInsertToken(String token, {required bool wrapInBrackets}) {
    final s = state;
    final newExpr = _engine.smartInsert(
      s.expression,
      token,
      justEvaluated: s.justEvaluated,
      wrapInBrackets: wrapInBrackets,
    );
    state = s.copyWith(
      expression: newExpr,
      previewResult: _previewResultFromExpression(newExpr),
      justEvaluated: false,
      clearError: true,
      cursorIndex: newExpr.length,
      canUndo: false,
    );
  }
}
