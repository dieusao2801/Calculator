import 'package:calculator/core/database/app_database.dart';
import 'package:calculator/features/history/domain/entities/calculation_history.dart';
import 'package:drift/drift.dart';

class CalculationHistoryMapper {
  static CalculationHistory toDomainModel(CalculationHistoryTableData data) {
    return CalculationHistory(
      id: data.id,
      expression: data.expression,
      result: data.result,
      isLock: data.isLock,
      note: data.note,
      createdTime: data.createdTime,
    );
  }

  static CalculationHistoryTableCompanion toCompanion(CalculationHistory data) {
    return CalculationHistoryTableCompanion(
      id: data.id != null ? Value(data.id!) : const Value.absent(),
      expression: Value(data.expression),
      result: Value(data.result),
      isLock: Value(data.isLock),
      note: Value(data.note),
      createdTime: Value(data.createdTime),
    );
  }
}