import 'package:calculator/features/converter/domain/converter_item.dart';

/// Lọc danh sách item theo query (title/subtitle, case-insensitive) và
/// dedup theo cặp `(title, theme)` — placeholder data có nhiều unique id
/// dùng chung content nên cần dedup để search result không bị trùng.
List<ConverterItem> filterConverterItems({
  required List<ConverterItem> all,
  required String query,
}) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return const [];

  final dedup = <String, ConverterItem>{};
  for (final item in all) {
    if (!item.title.toLowerCase().contains(q) &&
        !item.subtitle.toLowerCase().contains(q)) {
      continue;
    }
    dedup.putIfAbsent('${item.title}|${item.theme}', () => item);
  }
  return dedup.values.toList();
}
