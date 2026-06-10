import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'converter_search_controller.g.dart';

/// Quản lý nội dung tìm kiếm trong Converter tab.
@riverpod
class ConverterSearchController extends _$ConverterSearchController {
  @override
  String build() => '';

  void setQuery(String value) {
    state = value;
  }

  void clear() {
    state = '';
  }
}

/// Quản lý chế độ chỉnh sửa (Manage Mode) của mục Yêu thích.
@riverpod
class ConverterManageModeController extends _$ConverterManageModeController {
  @override
  bool build() => false;

  void toggle() {
    state = !state;
  }

  void setMode(bool value) {
    state = value;
  }
}
