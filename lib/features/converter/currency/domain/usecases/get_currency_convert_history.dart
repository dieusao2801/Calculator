import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:calculator/features/history/domain/entities/currency_convert_history.dart';
import '../repositories/currency_preferences_repository.dart';
import '../../data/providers/currency_preferences_providers.dart';

part 'get_currency_convert_history.g.dart';

class GetCurrencyConvertHistoryUseCase {
  GetCurrencyConvertHistoryUseCase(this._repository);

  final CurrencyPreferencesRepository _repository;

  Future<CurrencyConvertHistory?> execute({required bool isSimple}) {
    if (isSimple) {
      return _repository.getSimpleHistory();
    } else {
      return _repository.getAdvanceHistory();
    }
  }
}

@riverpod
GetCurrencyConvertHistoryUseCase getCurrencyConvertHistoryUseCase(Ref ref) {
  return GetCurrencyConvertHistoryUseCase(ref.watch(currencyPreferencesRepositoryProvider));
}
