import 'package:equatable/equatable.dart';

class CalculatorState extends Equatable {
  const CalculatorState({
    this.expression = '',
    this.previewResult = '',
    this.history = '',
    this.errorMessage,
    this.justEvaluated = false,
    this.cursorIndex = 0,
    this.previousExpression,
    this.previousPreviewResult,
    this.canUndo = false,
  });

  final String expression;
  final String previewResult;
  final String history;
  final String? errorMessage;
  final bool justEvaluated;
  final int cursorIndex;

  // Trạng thái phục vụ logic Undo sau khi nhấn "="
  final String? previousExpression;
  final String? previousPreviewResult;
  final bool canUndo;

  bool get hasError => errorMessage != null;

  CalculatorState copyWith({
    String? expression,
    String? previewResult,
    String? history,
    String? errorMessage,
    bool clearError = false,
    bool? justEvaluated,
    int? cursorIndex,
    String? previousExpression,
    String? previousPreviewResult,
    bool? canUndo,
  }) {
    return CalculatorState(
      expression: expression ?? this.expression,
      previewResult: previewResult ?? this.previewResult,
      history: history ?? this.history,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      justEvaluated: justEvaluated ?? this.justEvaluated,
      cursorIndex: cursorIndex ?? this.cursorIndex,
      previousExpression: previousExpression ?? this.previousExpression,
      previousPreviewResult: previousPreviewResult ?? this.previousPreviewResult,
      canUndo: canUndo ?? this.canUndo,
    );
  }

  @override
  List<Object?> get props => [
    expression,
    previewResult,
    history,
    errorMessage,
    justEvaluated,
    cursorIndex,
    previousExpression,
    previousPreviewResult,
    canUndo,
  ];
}
