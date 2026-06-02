import 'package:equatable/equatable.dart';

class CurrencyConvertHistory extends Equatable {
  final int? id;
  final DateTime ratesLastUpdated;
  final String currencyCode1; // Mã tiền tệ thứ 1 (Ví dụ: USD).
  final String exchangeRate1; // Tỷ giá hối đoái thứ 1.
  final String amount1; // Số tiền/Giá trị của tiền tệ thứ 1.

  final String currencyCode2; // Mã tiền tệ thứ 2.
  final String exchangeRate2; // Tỷ giá hối đoái thứ 2.
  final String amount2; // Số tiền/Giá trị của tiền tệ thứ 2.

  final String? currencyCode3; // Mã tiền tệ thứ 3.
  final String? exchangeRate3; // Tỷ giá hối đoái thứ 3.
  final String? amount3; // Số tiền/Giá trị của tiền tệ thứ 3.

  final String? currencyCode4; // Mã tiền tệ thứ 4.
  final String? exchangeRate4; // Tỷ giá hối đoái thứ 4.
  final String? amount4; // Số tiền/Giá trị của tiền tệ thứ 4.

  final DateTime createdTime;

  const CurrencyConvertHistory({
    this.id,
    required this.ratesLastUpdated,
    required this.currencyCode1,
    required this.exchangeRate1,
    required this.amount1,
    required this.currencyCode2,
    required this.exchangeRate2,
    required this.amount2,
    this.currencyCode3,
    this.exchangeRate3,
    this.amount3,
    this.currencyCode4,
    this.exchangeRate4,
    this.amount4,
    required this.createdTime,
  });

  @override
  List<Object?> get props => [
    id,
    ratesLastUpdated,
    currencyCode1,
    exchangeRate1,
    amount1,
    currencyCode2,
    exchangeRate2,
    amount2,
    currencyCode3,
    exchangeRate3,
    amount3,
    currencyCode4,
    exchangeRate4,
    amount4,
    createdTime,
  ];
}