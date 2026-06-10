import 'package:calculator/features/converter/domain/converter_item.dart';
import 'package:calculator/gen/assets.gen.dart';
import 'package:calculator/gen/strings.g.dart';

/// Registry các tool trong Converter tab: contentId → (title builder + icon asset).
final Map<String, _ConverterToolDef> _converterToolDefs = {
  // Convert section
  'unit_converter': _ConverterToolDef(() => t.converter.items.unit_converter, Assets.svg.icNavUnitConvert),
  'date_difference': _ConverterToolDef(() => t.converter.items.date_difference, Assets.svg.icNavDate),
  'age_calculator': _ConverterToolDef(() => t.converter.items.age_calculator, Assets.svg.icNavAge),
  'size_converter': _ConverterToolDef(() => t.converter.items.size_converter, Assets.svg.icNavSize),
  'gpa_calculator': _ConverterToolDef(() => t.converter.items.gpa_calculator, Assets.svg.icNavGpa),
  'hexadecimal_calculator': _ConverterToolDef(() => t.converter.items.hexadecimal_calculator, Assets.svg.icNavHexa),
  'world_time_converter': _ConverterToolDef(() => t.converter.items.world_time_converter, Assets.svg.icNavWorldTime),
  'time_difference': _ConverterToolDef(() => t.converter.items.time_difference, Assets.svg.icNavTime),

  // Consume section
  'fuel_cost': _ConverterToolDef(() => t.converter.items.fuel_cost_calculator, Assets.svg.icNavFuel),
  'percentage': _ConverterToolDef(() => t.converter.items.percentage_calculator, Assets.svg.icNavPercentage),
  'discount': _ConverterToolDef(() => t.converter.items.discount_calculator, Assets.svg.icNavDiscount),
  'tip': _ConverterToolDef(() => t.converter.items.tip_calculator, Assets.svg.icNavTip),
  'unit_price': _ConverterToolDef(() => t.converter.items.unit_price_calculator, Assets.svg.icNavUnitPrice),
  'sales_tax': _ConverterToolDef(() => t.converter.items.sales_tax_calculator, Assets.svg.icNavTax),

  // Money section
  'currency_converter': _ConverterToolDef(() => t.converter.items.currency_converter, Assets.svg.icNavCurrency),
  'loan_calculator': _ConverterToolDef(() => t.converter.items.loan_calculator, Assets.svg.icNavLoan),
  'savings_calculator': _ConverterToolDef(() => t.converter.items.savings_calculator, Assets.svg.icNavSaving),

  // Health section
  'ovulation_calculator': _ConverterToolDef(() => t.converter.items.ovulation_calculator, Assets.svg.icNavOvulation),
  'health_calculator': _ConverterToolDef(() => t.converter.items.health_calculator, Assets.svg.icNavHealth),
};

class _ConverterToolDef {
  const _ConverterToolDef(this.titleBuilder, this.icon);
  final String Function() titleBuilder;
  final SvgGenImage icon;
}

ConverterItem _buildItem({required String uniqueId, required String contentId, required ConverterColorTheme theme}) {
  final def = _converterToolDefs[contentId];
  return ConverterItem(
    id: uniqueId,
    contentId: contentId, // Thêm contentId vào model
    title: def?.titleBuilder() ?? contentId,
    subtitle: t.converter.item_subtitle_convert,
    icon: def?.icon ?? Assets.svg.icNavUnitConvert,
    theme: theme,
  );
}

/// Lấy thông tin item theo contentId (để build danh sách Favorites động)
ConverterItem? getConverterItem(String contentId) {
  final def = _converterToolDefs[contentId];
  if (def == null) return null;

  // Xác định theme dựa trên section mà nó thuộc về (để icon luôn đúng màu)
  ConverterColorTheme theme = ConverterColorTheme.lightBlue;
  if (['fuel_cost', 'percentage', 'discount', 'tip', 'unit_price', 'sales_tax'].contains(contentId)) {
    theme = ConverterColorTheme.bluish;
  } else if (['currency_converter', 'loan_calculator', 'savings_calculator'].contains(contentId)) {
    theme = ConverterColorTheme.coral;
  } else if (['ovulation_calculator', 'health_calculator'].contains(contentId)) {
    theme = ConverterColorTheme.beige;
  }

  return ConverterItem(
    id: 'fav-$contentId',
    contentId: contentId,
    title: def.titleBuilder(),
    subtitle: t.converter.item_subtitle_convert,
    icon: def.icon,
    theme: theme,
  );
}

/// Favorites — Trả về danh sách mặc định nếu chưa có data lưu trữ
List<String> getDefaultFavoriteIds() {
  return [
    'unit_converter',
    'age_calculator',
    'gpa_calculator',
    'size_converter',
    'currency_converter',
    'date_difference',
    'fuel_cost',
    'percentage',
  ];
}

/// Các section theo đúng order ảnh: CONVERT / CONSUME / MONEY / HEALTH.
List<ConverterSection> buildConverterSections() {
  return [
    ConverterSection(
      id: 'convert',
      title: t.converter.section_convert,
      items: [
        _buildItem(uniqueId: 'c1', contentId: 'unit_converter', theme: ConverterColorTheme.lightBlue),
        _buildItem(uniqueId: 'c2', contentId: 'date_difference', theme: ConverterColorTheme.lightBlue),
        _buildItem(uniqueId: 'c3', contentId: 'age_calculator', theme: ConverterColorTheme.lightBlue),
        _buildItem(uniqueId: 'c4', contentId: 'size_converter', theme: ConverterColorTheme.lightBlue),
        _buildItem(uniqueId: 'c5', contentId: 'gpa_calculator', theme: ConverterColorTheme.lightBlue),
        _buildItem(uniqueId: 'c6', contentId: 'hexadecimal_calculator', theme: ConverterColorTheme.lightBlue),
        _buildItem(uniqueId: 'c7', contentId: 'world_time_converter', theme: ConverterColorTheme.lightBlue),
        _buildItem(uniqueId: 'c8', contentId: 'time_difference', theme: ConverterColorTheme.lightBlue),
      ],
    ),
    ConverterSection(
      id: 'consume',
      title: t.converter.section_consume,
      items: [
        _buildItem(uniqueId: 'cn1', contentId: 'fuel_cost', theme: ConverterColorTheme.bluish),
        _buildItem(uniqueId: 'cn2', contentId: 'percentage', theme: ConverterColorTheme.bluish),
        _buildItem(uniqueId: 'cn3', contentId: 'discount', theme: ConverterColorTheme.bluish),
        _buildItem(uniqueId: 'cn4', contentId: 'tip', theme: ConverterColorTheme.bluish),
        _buildItem(uniqueId: 'cn5', contentId: 'unit_price', theme: ConverterColorTheme.bluish),
        _buildItem(uniqueId: 'cn6', contentId: 'sales_tax', theme: ConverterColorTheme.bluish),
      ],
    ),
    ConverterSection(
      id: 'money',
      title: t.converter.section_money,
      items: [
        _buildItem(uniqueId: 'm1', contentId: 'currency_converter', theme: ConverterColorTheme.coral),
        _buildItem(uniqueId: 'm2', contentId: 'loan_calculator', theme: ConverterColorTheme.coral),
        _buildItem(uniqueId: 'm3', contentId: 'savings_calculator', theme: ConverterColorTheme.coral),
      ],
    ),
    ConverterSection(
      id: 'health',
      title: t.converter.section_health,
      items: [
        _buildItem(uniqueId: 'h1', contentId: 'ovulation_calculator', theme: ConverterColorTheme.beige),
        _buildItem(uniqueId: 'h2', contentId: 'health_calculator', theme: ConverterColorTheme.beige),
      ],
    ),
  ];
}
