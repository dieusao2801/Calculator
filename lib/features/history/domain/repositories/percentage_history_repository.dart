import 'package:calculator/features/history/domain/entities/percentage_history.dart';

abstract class PercentageHistoryRepository {
  Future<List<PercentageHistory>> getPercentageHistory();
  Future<void> savePercentageHistory(PercentageHistory data);
  Future<void> deletePercentageHistory(int id);
  Future<void> clearAll();
}