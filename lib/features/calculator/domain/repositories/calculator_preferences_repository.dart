/// Repository interface — tầng Domain.
/// Bọc lớp persistence cho preference riêng của feature Calculator
/// (biểu thức dở dang, future: cấu hình hiển thị, v.v.).
abstract class CalculatorPrefRepository {
  /// Lấy biểu thức đã lưu lần app rời foreground gần nhất. Trả `''` nếu chưa có.
  Future<String> getLastFormula();

  /// Persist biểu thức hiện tại cho lần mở app kế tiếp.
  Future<void> saveLastFormula(String formula);
}
