import 'package:equatable/equatable.dart';

/// Pure Domain - Không phụ thuộc vào Drift hay bất kỳ thư viện ngoài nào.
class CalculationHistory extends Equatable {
  final int? id;
  final String expression;
  final String result;
  final bool isLock;
  final String note;
  final DateTime createdTime;

  const CalculationHistory({
    this.id,
    required this.expression,
    required this.result,
    required this.isLock,
    required this.note,
    required this.createdTime,
  });

  @override
  List<Object?> get props => [id, expression, result, isLock, note, createdTime];

  CalculationHistory copyWith({
    int? id,
    String? expression,
    String? result,
    bool? isLock,
    String? note,
    DateTime? createdTime,
  }) {
    return CalculationHistory(
      id: id ?? this.id,
      expression: expression ?? this.expression,
      result: result ?? this.result,
      isLock: isLock ?? this.isLock,
      note: note ?? this.note,
      createdTime: createdTime ?? this.createdTime,
    );
  }
}