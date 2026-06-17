enum CurrencyConverterMode {
  simple,
  advanced;

  int get indexValue => index;

  static CurrencyConverterMode fromIndex(int index) {
    if (index >= 0 && index < values.length) {
      return values[index];
    }
    return CurrencyConverterMode.simple;
  }
}
