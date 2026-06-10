import 'package:calculator/core/prefs/app_prefs.dart';
import 'package:calculator/features/converter/domain/converter_catalog.dart';
import 'package:calculator/features/converter/domain/converter_item.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'converter_favorites_controller.g.dart';

@riverpod
class ConverterFavoritesController extends _$ConverterFavoritesController {
  @override
  List<String> build() {
    final saved = ref.watch(appPrefsProvider).favoriteConverters;
    if (saved.isEmpty) {
      return getDefaultFavoriteIds();
    }
    return saved;
  }

  void toggleFavorite(String contentId) {
    final current = [...state];
    if (current.contains(contentId)) {
      current.remove(contentId);
    } else {
      current.add(contentId);
    }
    state = current;
    ref.read(appPrefsProvider).setFavoriteConverters(current);
  }

  bool isFavorite(String contentId) => state.contains(contentId);
}

/// Derived: map favorite IDs → ConverterItem list (skip invalid IDs).
@riverpod
List<ConverterItem> favoriteConverterItems(Ref ref) {
  final ids = ref.watch(converterFavoritesControllerProvider);
  return ids.map(getConverterItem).whereType<ConverterItem>().toList();
}
