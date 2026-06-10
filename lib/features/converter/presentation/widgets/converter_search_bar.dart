import 'package:calculator/core/styles/app_dimens.dart';
import 'package:calculator/core/styles/app_text_styles.dart';
import 'package:calculator/features/converter/presentation/providers/converter_search_controller.dart';
import 'package:calculator/gen/assets.gen.dart';
import 'package:calculator/gen/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Thanh search Converter — nền trắng đục, bo góc 16, đổ bóng nhẹ.
/// Trái: kính lúp. Phải: icon category (SVG mới import).
class ConverterSearchBar extends ConsumerStatefulWidget {
  const ConverterSearchBar({super.key});

  @override
  ConsumerState<ConverterSearchBar> createState() => _ConverterSearchBarState();
}

class _ConverterSearchBarState extends ConsumerState<ConverterSearchBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: ref.read(converterSearchControllerProvider));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(converterSearchControllerProvider);
    final isManageMode = ref.watch(converterManageModeControllerProvider);

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.gap12, vertical: AppDimens.gap4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        border: Border.all(color: const Color(0xFFADADAD), width: 1.2),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          if (isManageMode)
            GestureDetector(
              onTap: () => ref.read(converterManageModeControllerProvider.notifier).setMode(false),
              child: const Icon(Icons.arrow_back, size: 24, color: Colors.black45),
            )
          else
            const Icon(Icons.search, size: 24, color: Colors.black45),
          const SizedBox(width: AppDimens.gap12),
          Expanded(
            child: isManageMode
                ? Text(
                    t.converter.manager_favorites,
                    style: const TextStyle(fontSize: 16, color: Colors.black54, fontWeight: FontWeight.w500),
                  )
                : TextField(
                    controller: _controller,
                    style: AppTextStyles.bodyMedium,
                    decoration: InputDecoration(
                      isCollapsed: true,
                      border: InputBorder.none,
                      hintText: t.converter.search_placeholder,
                      hintStyle: const TextStyle(fontSize: 16, color: Color(0x993C3C43)),
                    ),
                    onChanged: (value) {
                      ref.read(converterSearchControllerProvider.notifier).setQuery(value);
                    },
                  ),
          ),
          if (!isManageMode)
            if (query.isNotEmpty)
              GestureDetector(
                onTap: () {
                  _controller.clear();
                  ref.read(converterSearchControllerProvider.notifier).clear();
                },
                child: const Icon(Icons.close, size: 24, color: Colors.black45),
              )
            else
              GestureDetector(
                onTap: () => ref.read(converterManageModeControllerProvider.notifier).toggle(),
                child: Assets.svg.icCategory.svg(width: 24, height: 24, color: Colors.black45),
              ),
        ],
      ),
    );
  }
}
