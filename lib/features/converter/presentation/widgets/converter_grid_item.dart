import 'package:calculator/core/styles/app_dimens.dart';
import 'package:calculator/features/converter/domain/converter_item.dart';
import 'package:calculator/features/converter/presentation/providers/converter_favorites_controller.dart';
import 'package:calculator/features/converter/presentation/providers/converter_search_controller.dart';
import 'package:calculator/features/converter/presentation/styles/converter_colors.dart';
import 'package:calculator/features/converter/presentation/widgets/converter_icon_tile.dart';
import 'package:calculator/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Item dạng grid (Favorites): icon 70 + label 14 Regular center.
class ConverterGridItem extends ConsumerWidget {
  const ConverterGridItem({super.key, required this.item, required this.onTap, this.width = 70});

  final ConverterItem item;
  final VoidCallback onTap;
  final double width;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isManageMode = ref.watch(converterManageModeControllerProvider);
    final isFavorite = ref.watch(converterFavoritesControllerProvider).contains(item.contentId);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                ConverterIconTile(icon: item.icon, theme: item.theme, contentId: item.contentId, big: true, size: width),
                if (isManageMode)
                  Positioned(
                    bottom: -6,
                    right: -6,
                    child: GestureDetector(
                      onTap: () => ref.read(converterFavoritesControllerProvider.notifier).toggleFavorite(item.contentId),
                      child: isFavorite
                          ? Assets.svg.icRemove.svg(width: 24, height: 24)
                          : Assets.svg.icAdd.svg(width: 24, height: 24),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppDimens.gap6),
            Text(
              item.title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: ConverterColors.label, height: 1.2),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
