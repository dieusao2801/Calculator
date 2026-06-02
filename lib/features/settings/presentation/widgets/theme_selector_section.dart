import 'package:calculator/core/styles/app_dimens.dart';
import 'package:calculator/core/theme/app_theme_id.dart';
import 'package:calculator/core/theme/theme_manager.dart';
import 'package:calculator/gen/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Section "Giao diện" trong Settings hiển thị danh sách Theme theo phân loại.
class ThemeSelectorSection extends ConsumerWidget {
  const ThemeSelectorSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(themeManagerProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimens.gap16,
            AppDimens.gap16,
            AppDimens.gap16,
            AppDimens.gap8,
          ),
          child: Text(
            t.settings.theme_section_title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        for (final category in ThemeCategory.values) ...[
          // Bỏ qua category không có theme nào (vd Special đang chờ asset).
          if (AppThemeId.byCategory(category).isNotEmpty) ...[
            _buildCategoryHeader(context, category),
            _buildThemeList(context, AppThemeId.byCategory(category), current, ref),
          ],
        ],
      ],
    );
  }

  Widget _buildCategoryHeader(BuildContext context, ThemeCategory category) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.gap16, vertical: AppDimens.gap8),
      child: Text(
        category.displayName,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
      ),
    );
  }

  Widget _buildThemeList(
    BuildContext context,
    List<AppThemeId> themes,
    AppThemeId current,
    WidgetRef ref,
  ) {
    return Column(
      children: themes.map((id) {
        return RadioListTile<AppThemeId>(
          value: id,
          groupValue: current,
          title: Text(id.displayName),
          secondary: CircleAvatar(backgroundColor: id.primaryColor, radius: 12),
          onChanged: (selected) {
            if (selected != null) {
              ref.read(themeManagerProvider.notifier).setTheme(selected);
            }
          },
        );
      }).toList(),
    );
  }
}
