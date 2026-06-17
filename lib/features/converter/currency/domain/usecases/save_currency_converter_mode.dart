import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../entities/currency_converter_mode.dart';
import '../repositories/currency_preferences_repository.dart';
import '../../data/providers/currency_preferences_providers.dart';

part 'save_currency_converter_mode.g.dart';

class SaveCurrencyConverterModeUseCase {
  SaveCurrencyConverterModeUseCase(this._repository);

  final CurrencyPreferencesRepository _repository;

  Future<void> execute(CurrencyConverterMode mode) => _repository.saveMode(mode);
}

@riverpod
SaveCurrencyConverterModeUseCase saveCurrencyConverterModeUseCase(Ref ref) {
  return SaveCurrencyConverterModeUseCase(ref.watch(currencyPreferencesRepositoryProvider));
}
