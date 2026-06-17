import 'package:auto_route/auto_route.dart';
import 'package:calculator/core/styles/app_colors.dart';
import 'package:calculator/core/styles/app_dimens.dart';
import 'package:calculator/core/styles/app_text_styles.dart';
import 'package:calculator/core/widgets/dialogs/app_base_dialog.dart';
import 'package:calculator/features/converter/currency/data/currency_name_loader.dart';
import 'package:calculator/features/converter/currency/data/providers/currency_repository_providers.dart';
import 'package:calculator/features/converter/currency/domain/entities/currency_rate.dart';
import 'package:calculator/gen/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CurrencySelectorDialog extends ConsumerStatefulWidget {
  const CurrencySelectorDialog({super.key, required this.selectedCode});

  final String selectedCode;

  static Future<String?> show(BuildContext context, {required String title, required String selectedCode}) {
    return AppBaseDialog.show<String>(
      context: context,
      title: title,
      expandContent: true,
      content: CurrencySelectorDialog(selectedCode: selectedCode),
      actions: [
        Builder(
          builder: (ctx) => TextButton(
            onPressed: () => ctx.maybePop(),
            child: Text(
              t.common.cancel.toUpperCase(),
              style: AppTextStyles.labelLarge.copyWith(color: const Color(0xFF333333), fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  @override
  ConsumerState<CurrencySelectorDialog> createState() => _CurrencySelectorDialogState();
}

class _CurrencySelectorDialogState extends ConsumerState<CurrencySelectorDialog> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<CurrencyRate> _allCurrencies = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrencies();
  }

  Future<void> _loadCurrencies() async {
    final repo = ref.read(currencyRepositoryProvider);
    // Load song song: list rate từ DB + map name đã localize từ JSON theo locale app.
    final results = await Future.wait([repo.getAll(), loadCurrencyNamesForCurrentLanguage()]);
    final rates = results[0] as List<CurrencyRate>;
    final localizedNames = results[1] as Map<String, String>;

    final merged = [for (final r in rates) r.copyWith(name: localizedNames[r.code] ?? r.name)]
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    if (mounted) {
      setState(() {
        _allCurrencies = merged;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2.5));
    }

    final filtered = _allCurrencies.where((c) {
      final q = _searchQuery.toLowerCase();
      return c.code.toLowerCase().contains(q) || c.name.toLowerCase().contains(q);
    }).toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSearchBar(),
        const SizedBox(height: AppDimens.gap12),
        // Body slot đã được AppBaseDialog buộc tight fit → Column này có bounded
        // maxHeight, Expanded(ListView) chia đúng remaining mà không overflow.
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: filtered.length,
            separatorBuilder: (_, _) => const Divider(height: 1, color: Color(0xFFB0B0B0)),
            itemBuilder: (context, index) {
              final item = filtered[index];
              final isSelected = item.code == widget.selectedCode;
              return _CurrencyItem(currency: item, isSelected: isSelected, onTap: () => context.maybePop(item.code));
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFCCCCCC)),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (val) => setState(() => _searchQuery = val),
        decoration: InputDecoration(
          hintText: t.converter.search_placeholder,
          hintStyle: AppTextStyles.bodyMedium.copyWith(color: Colors.grey),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }
}

class _CurrencyItem extends StatelessWidget {
  const _CurrencyItem({required this.currency, required this.isSelected, required this.onTap});

  final CurrencyRate currency;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            _buildRadio(),
            const SizedBox(width: 12),
            _buildFlag(),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                '${currency.name} (${currency.code})',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadio() {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF333333), width: 1.5),
      ),
      padding: const EdgeInsets.all(3),
      child: isSelected
          ? Container(
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF333333)),
            )
          : null,
    );
  }

  Widget _buildFlag() {
    final assetPath = 'assets/flags/${currency.code.toLowerCase()}.png';
    return Image.asset(
      assetPath,
      width: 32,
      height: 24,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        width: 32,
        height: 24,
        color: Colors.grey.shade300,
        child: const Icon(Icons.flag, size: 16, color: Colors.white),
      ),
    );
  }
}
