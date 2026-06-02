import 'package:equatable/equatable.dart';

class CalculatorState extends Equatable {
  const CalculatorState({
    this.expression = '',
    this.display = '',
    this.history = '',
    this.errorMessage,
    this.justEvaluated = false,
    this.cursorIndex = 0,
  });

  final String expression;
  final String display;
  final String history;
  final String? errorMessage;
  final bool justEvaluated;
  final int cursorIndex;

  bool get hasError => errorMessage != null;

  CalculatorState copyWith({
    String? expression,
    String? display,
    String? history,
    String? errorMessage,
    bool clearError = false,
    bool? justEvaluated,
    int? cursorIndex,
  }) {
    return CalculatorState(
      expression: expression ?? this.expression,
      display: display ?? this.display,
      history: history ?? this.history,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      justEvaluated: justEvaluated ?? this.justEvaluated,
      cursorIndex: cursorIndex ?? this.cursorIndex,
    );
  }

  @override
  List<Object?> get props => [expression, display, history, errorMessage, justEvaluated, cursorIndex];
}
