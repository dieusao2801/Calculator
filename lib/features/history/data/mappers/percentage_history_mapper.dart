import 'package:calculator/core/database/app_database.dart';
import 'package:calculator/features/history/domain/entities/percentage_history.dart';
import 'package:drift/drift.dart';

class PercentageHistoryMapper {
  static PercentageHistory toDomainModel(PercentageHistoryTableData data) {
    return PercentageHistory(
      id: data.id,
      createdTime: data.createdTime,
      initialValue: data.initialValue,
      percentValue: data.percentValue,
      changeValue: data.changeValue,
      finalValue: data.finalValue,
      changedPosition1: data.changedPosition1,
      changedPosition2: data.changedPosition2,
    );
  }

  static PercentageHistoryTableCompanion toCompanion(PercentageHistory data) {
    return PercentageHistoryTableCompanion(
      id: data.id != null ? Value(data.id!) : const Value.absent(),
      createdTime: Value(data.createdTime),
      initialValue: Value(data.initialValue),
      percentValue: Value(data.percentValue),
      changeValue: Value(data.changeValue),
      finalValue: Value(data.finalValue),
      changedPosition1: Value(data.changedPosition1),
      changedPosition2: Value(data.changedPosition2),
    );
  }
}