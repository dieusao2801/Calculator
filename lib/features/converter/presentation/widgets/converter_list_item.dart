import 'package:calculator/core/styles/app_dimens.dart';
import 'package:calculator/features/converter/domain/converter_item.dart';
import 'package:calculator/features/converter/presentation/providers/converter_favorites_controller.dart';
import 'package:calculator/features/converter/presentation/providers/converter_search_controller.dart';
import 'package:calculator/features/converter/presentation/styles/converter_colors.dart';
import 'package:calculator/features/converter/presentation/widgets/converter_icon_tile.dart';
import 'package:calculator/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Item dạng list: icon 56 + title/subtitle + nút Add/Remove ở far-right khi Manage Mode.
class ConverterListItem extends ConsumerWidget {
  const ConverterListItem({super.key, required this.item, required this.onTap});

  final ConverterItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isManageMode = ref.watch(converterManageModeControllerProvider);
    final isFavorite = ref.watch(converterFavoritesControllerProvider).contains(item.contentId);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppDimens.gap6),
        child: Row(
          children: [
            // Icon bên trái
            ConverterIconTile(icon: item.icon, theme: item.theme, contentId: item.contentId),
            const SizedBox(width: AppDimens.gap16),

            // Text ở giữa
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: ConverterColors.title),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    item.subtitle,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: ConverterColors.subtitle),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Nút Add/Remove ở far-right (chỉ hiện khi Manage Mode)
            if (isManageMode)
              Padding(
                padding: const EdgeInsets.only(left: AppDimens.gap12),
                child: GestureDetector(
                  onTap: () => ref.read(converterFavoritesControllerProvider.notifier).toggleFavorite(item.contentId),
                  child: isFavorite
                      ? Assets.svg.icRemove.svg(width: 24, height: 24)
                      : Assets.svg.icAdd.svg(width: 24, height: 24),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
