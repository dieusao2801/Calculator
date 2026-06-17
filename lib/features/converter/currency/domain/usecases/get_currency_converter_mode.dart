import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../entities/currency_converter_mode.dart';
import '../repositories/currency_preferences_repository.dart';
import '../../data/providers/currency_preferences_providers.dart';

part 'get_currency_converter_mode.g.dart';

class GetCurrencyConverterModeUseCase {
  GetCurrencyConverterModeUseCase(this._repository);

  final CurrencyPreferencesRepository _repository;

  Future<CurrencyConverterMode> execute() => _repository.getMode();
}

@riverpod
GetCurrencyConverterModeUseCase getCurrencyConverterModeUseCase(Ref ref) {
  return GetCurrencyConverterModeUseCase(ref.watch(currencyPreferencesRepositoryProvider));
}
