import 'package:calculator/features/history/domain/entities/calculation_history.dart';

/// Repository interface - Nằm ở tầng Domain.
/// Chỉ sử dụng các Entity thuần túy.
abstract class CalculationHistoryRepository {
  /// Lấy danh sách lịch sử.
  Future<List<CalculationHistory>> getAllHistory();

  /// Lưu lịch sử.
  Future<void> saveHistory(CalculationHistory calculationHistory);

  /// Xóa lịch sử theo ID.
  Future<void> deleteHistory(int id);

  /// Xóa sạch lịch sử.
  Future<void> clearHistory();

  /// Get Last History
  Future<CalculationHistory?> getLastHistory();

  /// Update History
  Future<void> updateHistory(CalculationHistory calculationHistory);
}
