import 'package:auto_route/auto_route.dart';
import 'package:calculator/core/helpers/app_toast.dart';
import 'package:calculator/core/router/app_router.gr.dart';
import 'package:calculator/core/styles/app_dimens.dart';
import 'package:calculator/features/converter/domain/converter_catalog.dart';
import 'package:calculator/features/converter/domain/converter_item.dart';
import 'package:calculator/features/converter/domain/converter_search.dart';
import 'package:calculator/features/converter/presentation/providers/converter_search_controller.dart';
import 'package:calculator/features/converter/presentation/styles/converter_colors.dart';
import 'package:calculator/features/converter/presentation/widgets/converter_grid_item.dart';
import 'package:calculator/features/converter/presentation/widgets/converter_list_item.dart';
import 'package:calculator/features/converter/presentation/widgets/converter_search_bar.dart';
import 'package:calculator/features/converter/presentation/widgets/converter_section.dart';
import 'package:calculator/gen/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/converter_favorites_controller.dart';

class ConverterTab extends ConsumerWidget {
  const ConverterTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(converterSearchControllerProvider).trim();

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppDimens.gap16, AppDimens.gap16, AppDimens.gap16, 0),
      child: Column(
        children: [
          const ConverterSearchBar(),
          const SizedBox(height: AppDimens.gap16),
          Expanded(child: _ConverterBody(query: query)),
        ],
      ),
    );
  }
}

class _ConverterBody extends ConsumerWidget {
  const _ConverterBody({required this.query});

  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoriteConverterItemsProvider);
    final sections = buildConverterSections();
    return query.isEmpty ? _buildCatalog(context, favorites, sections) : _buildSearchResults(context, favorites, sections);
  }

  Widget _buildCatalog(BuildContext context, List<ConverterItem> favorites, List<ConverterSection> sections) {
    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(child: SizedBox(height: AppDimens.gap8)),
        // Favorites Section
        SliverToBoxAdapter(
          child: ConverterSectionWidget(title: t.converter.section_favorite, child: _buildFavoritesGrid(context, favorites)),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: AppDimens.gap16)),
        // Other Sections
        for (final section in sections) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: AppDimens.gap12, bottom: AppDimens.gap12),
              child: Text(
                section.title.toUpperCase(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: ConverterColors.title,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final item = section.items[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: AppDimens.gap12),
                child: ConverterListItem(item: item, onTap: () => _onItemTap(context, item)),
              );
            }, childCount: section.items.length),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: AppDimens.gap8)),
        ],
        const SliverToBoxAdapter(child: SizedBox(height: AppDimens.gap24)),
      ],
    );
  }

  Widget _buildSearchResults(BuildContext context, List<ConverterItem> favorites, List<ConverterSection> sections) {
    final allItems = <ConverterItem>[...favorites, for (final section in sections) ...section.items];
    final filtered = filterConverterItems(all: allItems, query: query);

    if (filtered.isEmpty) {
      return Center(
        child: Text(t.converter.no_results, style: const TextStyle(fontSize: 16, color: ConverterColors.noResults)),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: AppDimens.gap12),
      itemCount: filtered.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppDimens.gap12),
      itemBuilder: (context, index) {
        final item = filtered[index];
        return ConverterListItem(item: item, onTap: () => _onItemTap(context, item));
      },
    );
  }

  /// Favorites grid: 4 cột, tính toán kích thước item dựa trên width và spacing.
  Widget _buildFavoritesGrid(BuildContext context, List<ConverterItem> items) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const int columns = 4;
        const double gap = AppDimens.gap12;
        final itemWidth = (constraints.maxWidth - (columns - 1) * gap) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: AppDimens.gap16,
          children: items
              .map((item) => ConverterGridItem(item: item, width: itemWidth, onTap: () => _onItemTap(context, item)))
              .toList(),
        );
      },
    );
  }
}

void _onItemTap(BuildContext context, ConverterItem item) {
  if (item.contentId == 'currency_converter') {
    context.pushRoute(const CurrencyConverterRoute());
  } else {
    AppToast.show(context, t.calculator.coming_soon);
  }
}
