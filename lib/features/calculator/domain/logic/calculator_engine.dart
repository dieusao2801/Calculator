import 'dart:math' as math;
import 'package:intl/intl.dart';

import '../../../../core/constants/calc_symbols.dart';

/// Engine xử lý logic biểu thức cho calculator.
class CalculatorEngine {
  CalculatorEngine();

  static const String displayMinus = CalcSymbols.minus;
  static const String displayTimes = CalcSymbols.times;
  static const String displayDivide = CalcSymbols.divide;
  static const String displayPlus = CalcSymbols.plus;
  static const String displayDecimal = CalcSymbols.decimal;
  static const String displayGroupSeparator = CalcSymbols.groupSeparator;
  static const String displayPower = CalcSymbols.power;
  static const String displayPercent = CalcSymbols.percent;
  static const String displaySquare = CalcSymbols.squarePower;
  static const String displayBrackets = CalcSymbols.brackets;

  static const Set<String> _operators = {
    CalcSymbols.plus,
    CalcSymbols.minus,
    CalcSymbols.times,
    CalcSymbols.divide,
    CalcSymbols.power,
    CalcSymbols.percent,
    CalcSymbols.squarePower,
    CalcSymbols.brackets,
    CalcSymbols.openBracket,
    CalcSymbols.closeBracket,
    CalcSymbols.plusMinus,
  };

  static const Set<String> _infixOperators = {
    CalcSymbols.plus,
    CalcSymbols.minus,
    CalcSymbols.times,
    CalcSymbols.divide,
    CalcSymbols.power,
  };

  bool isOperator(String s) => _operators.contains(s);

  bool isInfixOperator(String s) => _infixOperators.contains(s);

  String formatNumberForDisplay(String raw) {
    if (raw.isEmpty) return '0';
    // Đảm bảo không format nhầm các ký hiệu toán học
    if (raw == displayPercent || raw == displaySquare) return raw;

    final negative = raw.startsWith('-');
    final unsigned = negative ? raw.substring(1) : raw;
    final dotIndex = unsigned.indexOf('.');
    final intPart = dotIndex == -1 ? unsigned : unsigned.substring(0, dotIndex);
    final decPart = dotIndex == -1 ? '' : unsigned.substring(dotIndex + 1);

    final intParsed = int.tryParse(intPart);
    final formattedInt = intParsed != null ? NumberFormat.decimalPattern('en_US').format(intParsed) : intPart;

    final body = decPart.isEmpty ? formattedInt : '$formattedInt$displayDecimal$decPart';
    return negative ? '-$body' : body;
  }

  /// Chuyển đổi biểu thức từ định dạng hiển thị (UI) sang định dạng máy tính (Toán học).
  /// - Loại bỏ dấu phân cách hàng nghìn (,).
  /// - Thay thế các ký hiệu Unicode (×, ÷, −) thành toán tử lập trình (*, /, -).
  String toMathExpression(String uiExpr) {
    var internal = uiExpr
        .replaceAll(displayTimes, '*')
        .replaceAll(displayDivide, '/')
        .replaceAll(displayMinus, '-')
        .replaceAll(displayPercent, '%')
        .replaceAll(displaySquare, '^2')
        .replaceAll(displayGroupSeparator, '')
        .replaceAll(displayDecimal, '.');

    return internal;
  }

  /// Kiểm tra biểu thức có đang kết thúc bằng một "term" đã hoàn chỉnh hay không
  /// — tức là `)`, `%`, hoặc `²`. Khi đó nhập số/dấu chấm/00/000 tiếp theo cần
  /// tự chèn dấu × ngầm để biểu thức hợp lệ về mặt toán học.
  bool _endsWithCompletedTerm(String expression) {
    if (expression.isEmpty) return false;
    final lastChar = expression[expression.length - 1];
    return lastChar == CalcSymbols.closeBracket || lastChar == displayPercent || lastChar == displaySquare;
  }

  String appendDigit(String expression, String digit, {bool justEvaluated = false}) {
    if (justEvaluated) return digit == '0' ? '' : digit;
    if (expression.isEmpty) return digit == '0' ? '0' : digit;

    // Sau term đã hoàn chỉnh ( ")", "%", "²" ) → tự thêm × ngầm trước digit
    if (_endsWithCompletedTerm(expression)) {
      return '$expression$displayTimes$digit';
    }

    final lastNumber = _getLastNumber(expression);
    if (lastNumber == '0') {
      return expression.substring(0, expression.length - 1) + digit;
    }
    return expression + digit;
  }

  String appendDoubleZero(String expression, {bool justEvaluated = false}) {
    if (justEvaluated) return '';
    if (expression.isEmpty) return '0';
    if (_endsWithCompletedTerm(expression)) {
      return '$expression${displayTimes}00';
    }
    final lastNumber = _getLastNumber(expression);
    if (lastNumber == '0') return expression;
    return '${expression}00';
  }

  String appendTripleZero(String expression, {bool justEvaluated = false}) {
    if (justEvaluated) return '';
    if (expression.isEmpty) return '0';
    if (_endsWithCompletedTerm(expression)) {
      return '$expression${displayTimes}000';
    }
    final lastNumber = _getLastNumber(expression);
    if (lastNumber == '0') return expression;
    return '${expression}000';
  }

  String appendDecimal(String expression, {bool justEvaluated = false}) {
    if (justEvaluated) return '0$displayDecimal';
    if (expression.isEmpty) return '0$displayDecimal';
    // Phải check completed term trước isOperator vì ")", "%", "²" đều là operator
    if (_endsWithCompletedTerm(expression)) {
      return '$expression${displayTimes}0$displayDecimal';
    }
    final lastChar = expression[expression.length - 1];
    if (isOperator(lastChar)) return '${expression}0$displayDecimal';
    final lastNumber = _getLastNumber(expression);
    if (lastNumber.contains(displayDecimal)) return expression;
    return expression + displayDecimal;
  }

  /// Xử lý logic khi người dùng nhấn thêm một toán tử vào biểu thức hiện tại.
  /// - Nếu biểu thức trống: Chỉ cho phép dấu trừ (−) hoặc dấu ngoặc đơn.
  /// - Nếu nhấn ngoặc đơn: Tự động thêm dấu nhân (×) trước ngoặc mở nếu sau một con số;
  ///   hoặc tự động thêm dấu đóng ngoặc nếu có ngoặc chưa đóng.
  /// - Nếu nhấn toán tử khác (+, ×, ÷): Thay thế toán tử cũ nếu người dùng nhấn thay đổi toán tử liên tiếp.
  String appendOperator(String expression, String op) {
    if (expression.isEmpty) {
      if (op == displayBrackets) return CalcSymbols.openBracket;
      return op == displayMinus ? op : '';
    }

    final lastChar = expression[expression.length - 1];

    int countChar(String text, String char) => text.split(char).length - 1;

    if (op == displayBrackets) {
      final hasUnclosedBracket =
          countChar(expression, CalcSymbols.openBracket) > countChar(expression, CalcSymbols.closeBracket);
      if (hasUnclosedBracket && !isInfixOperator(lastChar) && lastChar != CalcSymbols.openBracket) {
        return '$expression${CalcSymbols.closeBracket}';
      }
      return RegExp(r'[0-9%²]$').hasMatch(lastChar)
          ? '$expression$displayTimes${CalcSymbols.openBracket}'
          : '$expression${CalcSymbols.openBracket}';
    }

    if (isOperator(lastChar)) {
      // Nếu nhấn toán tử khác khi đang có toán tử cũ (trừ ngoặc), thì ghi đè
      if (lastChar != displayBrackets) {
        return expression.substring(0, expression.length - 1) + op;
      }
    }
    return expression + op;
  }

  String backspace(String expression) {
    if (expression.isEmpty) return '';
    return expression.substring(0, expression.length - 1);
  }

  String plusMinus(String expression) {
    if (expression.isEmpty) return '${CalcSymbols.openBracket}${CalcSymbols.minus}';

    final lastNumber = _getLastNumber(expression);

    // Trường hợp kết thúc không phải là số (có thể là toán tử hoặc ngoặc)
    if (lastNumber.isEmpty) {
      final lastChar = expression[expression.length - 1];
      if (lastChar == CalcSymbols.plus) {
        return expression.substring(0, expression.length - 1) + CalcSymbols.minus;
      } else if (lastChar == CalcSymbols.minus) {
        return expression.substring(0, expression.length - 1) + CalcSymbols.plus;
      }
      return expression + CalcSymbols.openBracket + CalcSymbols.minus;
    }

    final startIdx = expression.length - lastNumber.length;

    // Quy tắc 2: Đảo ngược mẫu (-x thành (+x và ngược lại
    if (startIdx >= 2) {
      final signPart = expression.substring(startIdx - 2, startIdx);
      if (signPart == '${CalcSymbols.openBracket}${CalcSymbols.minus}') {
        return expression.substring(0, startIdx - 2) + CalcSymbols.openBracket + CalcSymbols.plus + lastNumber;
      } else if (signPart == '${CalcSymbols.openBracket}${CalcSymbols.plus}') {
        return expression.substring(0, startIdx - 2) + CalcSymbols.openBracket + CalcSymbols.minus + lastNumber;
      }
    }

    // Quy tắc 3: Đảo ngược toán tử đứng trước số (x + y -> x - y)
    if (startIdx >= 1) {
      final op = expression[startIdx - 1];
      if (op == CalcSymbols.plus) {
        return expression.substring(0, startIdx - 1) + CalcSymbols.minus + lastNumber;
      } else if (op == CalcSymbols.minus) {
        return expression.substring(0, startIdx - 1) + CalcSymbols.plus + lastNumber;
      }
    }

    // Mặc định: Thêm dấu âm vào trước số
    return expression.substring(0, startIdx) + CalcSymbols.openBracket + CalcSymbols.minus + lastNumber;
  }

  String percent(String expression) {
    return appendOperator(expression, displayPercent);
  }

  String inverse(String expression) {
    if (expression.isEmpty) return '';
    // Hiển thị dạng: biểu thức cũ × ( 1 ÷ )
    return '$expression${CalcSymbols.times}(1${CalcSymbols.divide}';
  }

  String square(String expression) {
    if (expression.isEmpty) return '';
    final lastChar = expression[expression.length - 1];
    // Nếu kết thúc là toán tử, không cho phép bình phương (trừ % hoặc ² có sẵn)
    if (isOperator(lastChar) && lastChar != displayPercent && lastChar != displaySquare) {
      return expression;
    }
    return '$expression^2';
  }

  /// Tính toán giá trị của biểu thức hiển thị trên UI.
  /// - [expression]: Chuỗi biểu thức UI (ví dụ: "9×(2+3)").
  /// - [isStrict]: Nếu true, sẽ không tự động cắt bỏ toán tử dư thừa ở cuối.
  ///   Thường dùng cho phím "=" để báo lỗi biểu thức chưa hoàn thiện.
  /// - Quy trình:
  ///   1. Cắt tỉa các toán tử dư thừa ở cuối chuỗi (nếu không ở chế độ strict).
  ///   2. Chuyển đổi sang định dạng nội bộ qua [toMathExpression].
  ///   3. Thực hiện tính toán qua [_evalInternal].
  ///   4. Định dạng kết quả trả về hoặc trả về mã lỗi nếu có (chia cho 0, lỗi cú pháp).
  EvalResult evaluate(String expression, {bool isStrict = false}) {
    if (expression.isEmpty) return const EvalResult(result: '0');
    var trimmed = expression;

    if (!isStrict) {
      // Cắt tỉa các toán tử infix dở dang ở cuối (ví dụ: 9 + 5 + -> 9 + 5)
      while (trimmed.isNotEmpty &&
          isOperator(trimmed[trimmed.length - 1]) &&
          trimmed[trimmed.length - 1] != displayPercent &&
          trimmed[trimmed.length - 1] != displaySquare &&
          trimmed[trimmed.length - 1] != CalcSymbols.closeBracket) {
        trimmed = trimmed.substring(0, trimmed.length - 1);
      }
    }

    if (trimmed.isEmpty) return const EvalResult(result: '0');

    // Tự động đóng các ngoặc còn thiếu trước khi tính toán (Kể cả trong strict mode)
    int openCount = 0;
    int closeCount = 0;
    for (int i = 0; i < trimmed.length; i++) {
      if (trimmed[i] == CalcSymbols.openBracket) openCount++;
      if (trimmed[i] == CalcSymbols.closeBracket) closeCount++;
    }
    while (openCount > closeCount) {
      trimmed += CalcSymbols.closeBracket;
      closeCount++;
    }

    final internal = toMathExpression(trimmed);
    try {
      final value = _evalInternal(internal);
      if (value.isNaN || value.isInfinite) {
        return const EvalResult(errorKey: 'generic');
      }
      return EvalResult(result: _formatResult(value));
    } on _DivByZeroException {
      return const EvalResult(errorKey: 'divide_by_zero');
    } catch (_) {
      return const EvalResult(errorKey: 'generic');
    }
  }

  /// Chuyển đổi vị trí index từ chuỗi thô sang chuỗi đã định dạng.
  int rawToFormattedIndex(String rawExpr, int rawIndex) {
    if (rawIndex <= 0) return 0;
    final formatted = formatFullExpression(rawExpr);
    if (rawIndex >= rawExpr.length) return formatted.length;

    // Quy tắc: Duyệt qua chuỗi thô, đếm xem đến vị trí rawIndex đã có bao nhiêu
    // ký tự đặc biệt được thêm vào trong chuỗi formatted.
    int currentRaw = 0;
    int currentFormatted = 0;

    while (currentRaw < rawIndex && currentFormatted < formatted.length) {
      if (rawExpr[currentRaw] == formatted[currentFormatted]) {
        currentRaw++;
        currentFormatted++;
      } else {
        // Ký tự tại formatted không có trong raw (thường là dấu ,) -> nhảy qua
        currentFormatted++;
      }
    }
    return currentFormatted;
  }

  /// Chuyển đổi vị trí index từ chuỗi đã định dạng về chuỗi thô.
  int formattedToRawIndex(String rawExpr, int formattedIndex) {
    if (formattedIndex <= 0) return 0;
    final formatted = formatFullExpression(rawExpr);
    if (formattedIndex >= formatted.length) return rawExpr.length;

    int currentRaw = 0;
    int currentFormatted = 0;

    while (currentFormatted < formattedIndex && currentRaw < rawExpr.length) {
      if (rawExpr[currentRaw] == formatted[currentFormatted]) {
        currentRaw++;
        currentFormatted++;
      } else {
        currentFormatted++;
      }
    }
    return currentRaw;
  }

  String _getLastNumber(String expr) {
    var i = expr.length - 1;
    while (i >= 0 && !isOperator(expr[i])) {
      i--;
    }
    return expr.substring(i + 1);
  }

  String _formatResult(double value) {
    String raw;
    if (value == value.truncateToDouble() && value.abs() < 1e15) {
      raw = value.toInt().toString();
    } else {
      raw = value.toStringAsFixed(10);
      raw = raw.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
    }
    return formatNumberForDisplay(raw);
  }

  /// Định dạng toàn bộ chuỗi biểu thức để hiển thị lên UI.
  /// Duyệt qua chuỗi biểu thức, tách các phần số và toán tử riêng biệt.
  /// Mỗi phần số sẽ được chạy qua hàm [formatNumberForDisplay] để thêm dấu phân cách hàng nghìn.
  String formatFullExpression(String expr) {
    if (expr.isEmpty) return '';

    final List<String> parts = [];
    String currentNumber = '';

    for (int i = 0; i < expr.length; i++) {
      final char = expr[i];
      if (isOperator(char)) {
        if (currentNumber.isNotEmpty) {
          parts.add(formatNumberForDisplay(currentNumber));
          currentNumber = '';
        }
        parts.add(char);
      } else {
        currentNumber += char;
      }
    }

    if (currentNumber.isNotEmpty) {
      parts.add(formatNumberForDisplay(currentNumber));
    }

    return parts.join('');
  }

  /// Đếm số lượng chữ số trong phần số chứa vị trí hiện tại của con trỏ.
  int getLastNumberDigitCount(String expr) {
    // Tìm ranh giới của số hạng cuối cùng
    final lastNumber = _getLastNumber(expr);
    // Chỉ đếm các ký tự là số
    return lastNumber.replaceAll(RegExp(r'\D'), '').length;
  }

  /// Khởi chạy trình phân tích toán học (Parser) cho một biểu thức nội bộ.
  /// - Đầu vào: Chuỗi biểu thức đã được "Internalize" (ví dụ: "5*2+3").
  /// - Đầu ra: Giá trị số double sau khi tính toán.
  /// Ném ra lỗi [FormatException] nếu phát hiện ký tự không hợp lệ hoặc cú pháp sai.
  double _evalInternal(String input) {
    final parser = _Parser(input);
    final value = parser.parseExpr();
    if (!parser.isEnd) throw FormatException('Unexpected char at ${parser.pos}');
    return value;
  }
}

class EvalResult {
  const EvalResult({this.result, this.errorKey});

  final String? result;
  final String? errorKey;
}

class _Parser {
  _Parser(this.input);

  final String input;
  int pos = 0;

  bool get isEnd => pos >= input.length;

  String get _ch => input[pos];

  double parseExpr() {
    var left = _parseTerm();
    while (!isEnd && (_ch == '+' || _ch == '-')) {
      final op = _ch;
      pos++;
      final right = _parseTerm();
      left = op == '+' ? left + right : left - right;
    }
    return left;
  }

  double _parseTerm() {
    var left = _parsePower();
    while (!isEnd && (_ch == '*' || _ch == '/')) {
      final op = _ch;
      pos++;
      final right = _parsePower();
      if (op == '*') {
        left *= right;
      } else {
        // Throw để evaluate() phân biệt chia-cho-0 (cả qua biểu thức, ví dụ 5/(2-2))
        // với lỗi cú pháp khác — không thể dựa vào substring '/0' nữa.
        if (right == 0) throw const _DivByZeroException();
        left /= right;
      }
    }
    return left;
  }

  double _parsePower() {
    var left = _parseFactor();
    while (!isEnd) {
      if (_ch == '^') {
        pos++;
        final right = _parseFactor();
        left = math.pow(left, right).toDouble();
      } else if (_ch == '%') {
        pos++;
        left = left * 0.01;
      } else if (_ch == ' ') {
        pos++;
      } else {
        break;
      }
    }
    return left;
  }

  /// Cấp độ thấp nhất của Parser: Phân tích số hạng đơn lẻ hoặc biểu thức trong ngoặc.
  /// - Xử lý dấu âm đơn nguyên (-x).
  /// - Xử lý biểu thức nằm trong ngoặc đơn (...).
  /// - Xử lý các con số (bao gồm cả dấu chấm thập phân).
  /// - Đọc toàn bộ chuỗi chữ số liên tiếp và chuyển đổi thành kiểu [double].
  double _parseFactor() {
    // Ăn chuỗi unary +/- liên tiếp (xử lý cả `(+9...)`, `9*-5`, `--9`, `-(+5)`, v.v.)
    var sign = 1;
    while (!isEnd && (_ch == '-' || _ch == '+')) {
      if (_ch == '-') sign = -sign;
      pos++;
    }

    if (!isEnd && _ch == CalcSymbols.openBracket) {
      pos++; // Bỏ qua '('
      // Paren rỗng `()` (thường do evaluate auto-close khi user gõ dở '(') → coi như 0
      if (!isEnd && _ch == CalcSymbols.closeBracket) {
        pos++;
        return 0;
      }
      final value = parseExpr();
      if (!isEnd && _ch == CalcSymbols.closeBracket) {
        pos++; // Bỏ qua ')'
      }
      return sign * value;
    }

    if (isEnd) throw const FormatException('Unexpected end');
    final start = pos;
    while (!isEnd && (_isDigit(_ch) || _ch == '.')) {
      pos++;
    }
    if (start == pos) throw FormatException('Expected number at $pos');
    final num = double.parse(input.substring(start, pos));
    return sign * num;
  }

  bool _isDigit(String c) => c.codeUnitAt(0) >= 48 && c.codeUnitAt(0) <= 57;
}

/// Ngoại lệ private dùng để báo về `evaluate()` rằng có chia-cho-0
/// (kể cả khi mẫu số là biểu thức như `5/(2-2)`).
class _DivByZeroException implements Exception {
  const _DivByZeroException();
}
