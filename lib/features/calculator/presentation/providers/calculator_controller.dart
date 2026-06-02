import 'package:calculator/core/constants/calc_symbols.dart';
import 'package:calculator/features/calculator/domain/logic/calculator_engine.dart';
import 'package:calculator/features/calculator/presentation/providers/calculator_state.dart';
import 'package:calculator/features/history/data/providers/history_repository_providers.dart';
import 'package:calculator/features/history/domain/entities/calculation_history.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'calculator_controller.g.dart';

@riverpod
class CalculatorController extends _$CalculatorController {
  final CalculatorEngine _engine = CalculatorEngine();

  @override
  CalculatorState build() => const CalculatorState();

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
      display: _displayFromExpression(newExpr),
      justEvaluated: false,
      clearError: true,
      cursorIndex: newCursor,
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
      display: _displayFromExpression(newExpr),
      justEvaluated: false,
      clearError: true,
      cursorIndex: tempExpr.length,
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
      display: _displayFromExpression(newExpr),
      justEvaluated: false,
      clearError: true,
      cursorIndex: tempExpr.length,
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
      display: _displayFromExpression(newExpr),
      justEvaluated: false,
      clearError: true,
      cursorIndex: tempExpr.length,
    );
  }

  void appendOperator(String op) {
    final s = state;
    String basePrefix;
    String suffix = "";

    if (s.justEvaluated && !s.hasError) {
      basePrefix = _engine.toMathExpression(s.display).replaceAll('.', CalculatorEngine.displayDecimal);
    } else {
      basePrefix = s.expression.substring(0, s.cursorIndex);
      suffix = s.expression.substring(s.cursorIndex);
    }

    final tempExpr = _engine.appendOperator(basePrefix, op);
    final newExpr = tempExpr + suffix;
    state = s.copyWith(
      expression: newExpr,
      display: _displayFromExpression(newExpr),
      justEvaluated: false,
      clearError: true,
      cursorIndex: tempExpr.length,
    );
  }

  void backspace() {
    final s = state;
    if (s.justEvaluated) {
      state = const CalculatorState();
      return;
    }

    if (s.cursorIndex == 0) return; // Không có gì đằng trước để xóa

    final prefix = s.expression.substring(0, s.cursorIndex);
    final suffix = s.expression.substring(s.cursorIndex);

    final newPrefix = prefix.substring(0, prefix.length - 1);
    final newExpr = newPrefix + suffix;

    state = s.copyWith(
      expression: newExpr,
      display: _displayFromExpression(newExpr),
      clearError: true,
      cursorIndex: newPrefix.length,
    );
  }

  void moveCursor(int index) {
    state = state.copyWith(cursorIndex: index.clamp(0, state.expression.length));
  }

  void clear() {
    state = const CalculatorState();
  }

  void clearErrorMessage() {
    state = state.copyWith(clearError: true);
  }

  void undo() {
    backspace();
  }

  void plusMinus() {
    final s = state;
    final prefix = s.expression.substring(0, s.cursorIndex);
    final suffix = s.expression.substring(s.cursorIndex);

    final tempExpr = _engine.plusMinus(prefix);
    final newExpr = tempExpr + suffix;

    state = s.copyWith(
      expression: newExpr,
      display: _displayFromExpression(newExpr),
      justEvaluated: false,
      clearError: true,
      cursorIndex: tempExpr.length,
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
      display: _displayFromExpression(newExpr),
      justEvaluated: false,
      clearError: true,
      cursorIndex: tempExpr.length,
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
      display: _displayFromExpression(newExpr),
      justEvaluated: false,
      clearError: true,
      cursorIndex: tempExpr.length,
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
      display: _displayFromExpression(newExpr),
      justEvaluated: false,
      clearError: true,
      cursorIndex: tempExpr.length,
    );
  }

  void sqrtPi() {
    state = state.copyWith(errorMessage: 'coming_soon');
  }

  void equals() async {
    final s = state;
    if (s.justEvaluated || s.expression.isEmpty) return;

    // Sử dụng chế độ strict: true để không bỏ qua các toán tử dở dang ở cuối
    final result = _engine.evaluate(s.expression, isStrict: true);
    if (result.errorKey != null) {
      state = s.copyWith(errorMessage: result.errorKey); // Chỉ set lỗi để hiện Toast
      return;
    }

    final finalResult = result.result ?? '0';

    final historyEntry = CalculationHistory(
      expression: s.expression,
      result: finalResult,
      isLock: false,
      note: '',
      createdTime: DateTime.now(),
    );

    await ref.read(historyRepositoryProvider).saveHistory(historyEntry);

    state = s.copyWith(
      history: '${s.expression} = $finalResult',
      // Lưu đầy đủ "Biểu thức = Kết quả"
      display: '',
      expression: finalResult,
      justEvaluated: true,
      clearError: true,
      cursorIndex: finalResult.length,
    );
  }

  /// Chuyển đổi chuỗi biểu thức hiện tại thành kết quả hiển thị xem trước (Preview).
  /// - Trả về chuỗi rỗng nếu biểu thức chưa có toán tử hoặc đang kết thúc bằng toán tử chờ số (Infix).
  /// - Gọi Engine.evaluate để tính toán giá trị thực tế của biểu thức dở dang.
  String _displayFromExpression(String expr) {
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
    // Chúng ta dùng endsWith thay vì contains để tránh bỏ sót các toán tử dở dang phía sau
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
    if (eval.result != null) {
      return eval.result!;
    }

    return '';
  }
}
