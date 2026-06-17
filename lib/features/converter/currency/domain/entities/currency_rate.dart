import 'package:equatable/equatable.dart';

/// Pure Domain — không phụ thuộc Drift hay framework.
/// [rate] lưu theo convention "1 unit của currency này = ? USD" (= 1/quote server).
class CurrencyRate extends Equatable {
  final String code;
  final String name;
  final double? rate;
  final DateTime? updatedAt;

  const CurrencyRate({required this.code, required this.name, this.rate, this.updatedAt});

  CurrencyRate copyWith({String? code, String? name, double? rate, DateTime? updatedAt}) {
    return CurrencyRate(
      code: code ?? this.code,
      name: name ?? this.name,
      rate: rate ?? this.rate,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [code, name, rate, updatedAt];
}