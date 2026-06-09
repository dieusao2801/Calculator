import 'dart:math' as math;
import 'package:calculator/core/log/app_log.dart';

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

  static const Set<String> _infixOperators = {CalcSymbols.power};

  bool isOperator(String s) => _operators.contains(s);

  bool isInfixOperator(String s) => _infixOperators.contains(s);

  String formatNumberForDisplay(String raw) {
    if (raw.isEmpty) return '0';
    // Đảm bảo không format nhầm các ký hiệu toán học
    if (raw == displayPercent || raw == displaySquare) return raw;

    final negative = raw.startsWith('-');
    final unsigned = negative ? raw.substring(1) : raw;

    // Luôn split theo '.' vì raw input từ double.toStringAsFixed dùng '.'
    final parts = unsigned.split('.');
    final intPart = parts[0];
    final decPart = parts.length > 1 ? parts[1] : '';

    // Để đảm bảo ý muốn của bạn là dùng dấu '.' cho thập phân và bỏ các dấu khác gây nhầm lẫn:
    // Tạm thời bỏ grouping separator (,) ở phần nguyên.
    final body = decPart.isEmpty ? intPart : '$intPart.$decPart';
    return negative ? '-$body' : body;
  }

  /// Chuyển đổi biểu thức từ định dạng hiển thị (UI) sang định dạng máy tính (Toán học).
  /// - Loại bỏ dấu phân cách hàng nghìn (,).
  /// - Thay thế các ký hiệu Unicode (×, ÷, −) thành toán tử lập trình (*, /, -).
  String toMathExpression(String displayExpression) {
    return displayExpression
        .replaceAll(displayTimes, '*')
        .replaceAll(displayDivide, '/')
        .replaceAll(displayMinus, '-')
        .replaceAll(displayPercent, '%')
        .replaceAll(displaySquare, '^2')
        .replaceAll(displayGroupSeparator, '')
        .replaceAll(displayDecimal, '.');
  }

  /// Kiểm tra biểu thức có đang kết thúc bằng một "term" đã hoàn chỉnh hay không
  /// — tức là `)`, `%`, hoặc `²`. Khi đó nhập số/dấu chấm/00/000 tiếp theo cần
  /// tự chèn dấu × ngầm để biểu thức hợp lệ về mặt toán học.
  bool _endsWithCompletedTerm(String expression) {
    if (expression.isEmpty) return false;
    final lastChar = expression[expression.length - 1];
    return lastChar == CalcSymbols.closeBracket || lastChar == displayPercent || lastChar == displaySquare;
  }

  /// Chèn [token] (số hoặc biểu thức) vào cuối [expression] theo ngữ cảnh, giống
  /// như user nhập tay liên tục: tự thêm `×` ngầm hoặc append thẳng tùy lastChar.
  ///
  /// - [justEvaluated]=true → replace toàn bộ (kết quả `=` được coi như slot trống mới).
  /// - Expression rỗng → token đứng đầu.
  /// - Sau operator chờ số (`+ − × ÷ ^ (`) → append thẳng.
  /// - Sau term hoàn chỉnh (`) % ²`) hoặc sau số → thêm `×` ngầm.
  /// - [wrapInBrackets]=true VÀ token chứa operator VÀ phải thêm `×` ngầm → bọc
  ///   `(...)` quanh token để giữ precedence (vd restore `2+3` vào `5×` thành `5×(2+3)`).
  String smartInsert(String expression, String token, {bool justEvaluated = false, bool wrapInBrackets = false}) {
    if (token.isEmpty) return expression;
    if (justEvaluated) return token;
    if (expression.isEmpty) return token;

    final lastChar = expression[expression.length - 1];

    // Sau operator chờ số → append thẳng (operand mới, không cần wrap).
    if (isOperator(lastChar) && !_endsWithCompletedTerm(expression)) {
      return '$expression$token';
    }

    // Sau term hoàn chỉnh hoặc sau số → `×` ngầm; wrap token nếu cần giữ precedence.
    final tokenContainsOperator = token.split('').any(isOperator);
    final wrapped = (wrapInBrackets && tokenContainsOperator)
        ? '${CalcSymbols.openBracket}$token${CalcSymbols.closeBracket}'
        : token;
    return '$expression$displayTimes$wrapped';
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
      // Chỉ ghi đè nếu là toán tử infix (+, -, ×, ÷)
      // Không ghi đè nếu là ), %, ²
      if (lastChar != CalcSymbols.closeBracket && lastChar != displayPercent && lastChar != displaySquare) {
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
  /// Chuẩn hóa biểu thức UI: cắt operator dở dang (non-strict) + auto-close ngoặc.
  /// Trả về chuỗi đã chuẩn hóa ở dạng UI (×÷²,…); rỗng nếu sau trim không còn gì.
  String normalize(String expression, {bool isStrict = false}) {
    if (expression.isEmpty) return '';
    var normalized = expression;

    // Non-strict: cắt operator dư ở đuôi ("9+5+" → "9+5"). Strict (phím "="): giữ để báo lỗi.
    if (!isStrict) {
      while (normalized.isNotEmpty &&
          isOperator(normalized[normalized.length - 1]) &&
          // Trừ '%', '²', ')' — hậu tố hợp lệ, không phải toán tử dở dang.
          normalized[normalized.length - 1] != displayPercent &&
          normalized[normalized.length - 1] != displaySquare &&
          normalized[normalized.length - 1] != CalcSymbols.closeBracket) {
        normalized = normalized.substring(0, normalized.length - 1);
      }
    }

    if (normalized.isEmpty) return '';

    // Auto-close '(' còn thiếu — áp dụng cả strict mode vì là convention UX, không phải dọn rác.
    int openBracketCount = 0;
    int closeBracketCount = 0;
    for (int i = 0; i < normalized.length; i++) {
      if (normalized[i] == CalcSymbols.openBracket) openBracketCount++;
      if (normalized[i] == CalcSymbols.closeBracket) closeBracketCount++;
    }
    while (openBracketCount > closeBracketCount) {
      normalized += CalcSymbols.closeBracket;
      closeBracketCount++;
    }

    return normalized;
  }

  /// - [expression]: Chuỗi biểu thức UI (ví dụ: "9(2+3)").
  /// - [isStrict]: Nếu true, sẽ không tự động cắt bỏ toán tử dư thừa ở cuối.
  ///   Thường dùng cho phím "=" để báo lỗi biểu thức chưa hoàn thiện.
  /// - Quy trình:
  ///   1. Chuẩn hóa qua [normalize] (trim + auto-close ngoặc).
  ///   2. Chuyển đổi sang định dạng nội bộ qua [toMathExpression].
  ///   3. Thực hiện tính toán qua [_evalInternal].
  ///   4. Định dạng kết quả trả về hoặc trả về mã lỗi nếu có (chia cho 0, lỗi cú pháp).
  EvalResult evaluate(String expression, {bool isStrict = false}) {
    if (expression.isEmpty) return const EvalResult(result: '0');

    final normalized = normalize(expression, isStrict: isStrict);
    if (normalized.isEmpty) return const EvalResult(result: '0');

    // UI → math: ×÷ → */, dấu phẩy → dấu chấm.
    final mathExpression = toMathExpression(normalized);
    try {
      final value = _evalInternal(mathExpression);
      AppLog.d('evaluate: expression=$expression | math=$mathExpression | value=$value');
      // NaN/Infinity (0/0, overflow) → không hiển thị được, báo generic.
      if (value.isNaN || value.isInfinite) {
        return const EvalResult(errorKey: 'generic');
      }
      return EvalResult(result: _formatResult(value));
    } on _DivByZeroException {
      // Bắt riêng để UI map sang i18n 'error_divide_by_zero'.
      return const EvalResult(errorKey: 'divide_by_zero');
    } catch (_) {
      return const EvalResult(errorKey: 'generic');
    }
  }

  /// Map index từ chuỗi thô → chuỗi đã format (để đặt cursor đúng chỗ trên UI).
  int rawToFormattedIndex(String rawExpr, int rawIndex) {
    if (rawIndex <= 0) return 0;
    final formatted = formatFullExpression(rawExpr);
    if (rawIndex >= rawExpr.length) return formatted.length;

    // 2-pointer: ký tự khớp → tiến cả 2; lệch → chỉ tiến formatted (bỏ qua dấu phân cách).
    int rawPos = 0;
    int formattedPos = 0;

    while (rawPos < rawIndex && formattedPos < formatted.length) {
      if (rawExpr[rawPos] == formatted[formattedPos]) {
        rawPos++;
        formattedPos++;
      } else {
        formattedPos++;
      }
    }
    return formattedPos;
  }

  /// Map index từ chuỗi đã format → chuỗi thô (ngược của [rawToFormattedIndex]).
  int formattedToRawIndex(String rawExpr, int formattedIndex) {
    if (formattedIndex <= 0) return 0;
    final formatted = formatFullExpression(rawExpr);
    if (formattedIndex >= formatted.length) return rawExpr.length;

    // Cùng 2-pointer như rawToFormattedIndex, đảo điều kiện dừng.
    int rawPos = 0;
    int formattedPos = 0;

    while (formattedPos < formattedIndex && rawPos < rawExpr.length) {
      if (rawExpr[rawPos] == formatted[formattedPos]) {
        rawPos++;
        formattedPos++;
      } else {
        formattedPos++;
      }
    }
    return rawPos;
  }

  /// Lấy số hạng cuối (đoạn chữ số sau operator gần nhất).
  String _getLastNumber(String expr) {
    var i = expr.length - 1;
    while (i >= 0 && !isOperator(expr[i])) {
      i--;
    }
    return expr.substring(i + 1);
  }

  /// Format kết quả [value] thành chuỗi hiển thị cuối cùng (sau dấu `=`).
  String _formatResult(double value) {
    // Buffer chuỗi kết quả thô trước khi đẩy qua formatter hiển thị.
    String raw;

    // Số nguyên + nằm trong ngưỡng mantissa 53-bit (1e15) → toInt() không mất precision.
    if (value == value.truncateToDouble() && value.abs() < 1e15) {
      // Bỏ ".0" cho số nguyên (vd 4.0 → "4").
      raw = value.toInt().toString();
    } else {
      // Cap 6 chữ số sau dấu chấm; luôn pad đủ 6 (vd 4.5 → "4.500000").
      raw = value.toStringAsFixed(6);
      // Trim '0' thừa ở đuôi rồi trim '.' lẻ nếu còn (vd "4.500000" → "4.5").
      raw = raw.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
    }

    // Áp convention dấu thập phân + thousand separator của app.
    return formatNumberForDisplay(raw);
  }

  /// Format số cho preview — cap tối đa 6 chữ số thập phân (round half-up),
  /// bỏ trailing zeros.
  String formatPreviewNumber(double value) {
    String raw;
    if (value == value.truncateToDouble() && value.abs() < 1e15) {
      raw = value.toInt().toString();
    } else {
      raw = value.toStringAsFixed(6);
      raw = raw.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
    }
    return formatNumberForDisplay(raw);
  }

  /// Format toàn bộ biểu thức để hiển thị — tách số và operator, mỗi số chạy
  /// qua [formatNumberForDisplay] để thêm dấu phân cách hàng nghìn.
  String formatFullExpression(String expr) {
    if (expr.isEmpty) return '';

    final List<String> parts = [];
    String currentNumber = '';

    // Gặp operator → flush số đang gom, append operator. Hết loop flush số còn lại.
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

  /// Đếm chữ số trong số hạng cuối (dùng để chặn vượt max digits khi nhập).
  int getLastNumberDigitCount(String expr) {
    final lastNumber = _getLastNumber(expr);
    return lastNumber.replaceAll(RegExp(r'\D'), '').length;
  }

  /// Eval biểu thức nội bộ (đã chuyển sang dạng toán học `*`/`/`/dấu chấm).
  /// Throw [FormatException] nếu cú pháp sai (parser chưa tiêu hết input).
  double _evalInternal(String mathExpression) {
    final parser = _Parser(mathExpression);
    final result = parser.parseExpr();
    if (!parser.isEnd) throw FormatException('Unexpected char at ${parser.pos}');
    return result;
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
