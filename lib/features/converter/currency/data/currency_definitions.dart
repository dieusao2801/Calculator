import 'package:calculator/features/converter/currency/domain/entities/currency_rate.dart';

/// Port từ Android `UnitConverter.CurrencyDefinition` — list currency được app
/// support kèm rate fallback. Rate = "1 unit currency này = ? USD" (1/quote).
/// Server fetch sau đó sẽ override rate realtime.
class _CurrencyDef {
  const _CurrencyDef(this.code, this.name, this.rate);

  final String code;
  final String name;
  final double rate;
}

const List<_CurrencyDef> _kCurrencyDefinitions = [
  _CurrencyDef('AFN', 'Afghan afghani', 0.01132486021602),
  _CurrencyDef('ALL', 'Albanian lek', 0.0088166079087423),
  _CurrencyDef('DZD', 'Algerian Dinar', 0.0068671654120101),
  _CurrencyDef('AOA', 'Angolan kwanza', 0.0023353468214583),
  _CurrencyDef('ARS', 'Argentine Peso', 0.0079955778962103),
  _CurrencyDef('AMD', 'Armenia Dram', 0.0022502627818956),
  _CurrencyDef('AWG', 'Aruban florin', 0.55233197853278),
  _CurrencyDef('AUD', 'Australian Dollar', 0.68848830169123),
  _CurrencyDef('AZN', 'Azerbaijan Manat', 0.5894699801841),
  _CurrencyDef('BSD', 'Bahamian Dollar', 1),
  _CurrencyDef('BHD', 'Bahrain Dinar', 2.6542731069982),
  _CurrencyDef('BDT', 'Bangladeshi taka', 0.011109771165637),
  _CurrencyDef('BBD', 'Barbadian Dollar', 0.49502616037545),
  _CurrencyDef('BYN', 'Belarussian Ruble', 0.34958829765952),
  _CurrencyDef('BZD', 'Belize dollar', 0.49587946017559),
  _CurrencyDef('BOB', 'Bolivian Boliviano', 0.14557369617776),
  _CurrencyDef('BAM', 'Bosnia and Herzegovina convertible mark', 0.53609682707206),
  _CurrencyDef('BWP', 'Botswana Pula', 0.081243123077266),
  _CurrencyDef('BRL', 'Brazilian Real', 0.19257765871267),
  _CurrencyDef('BND', 'Brunei Dollar', 0.7198706577145),
  _CurrencyDef('BGN', 'Bulgarian Lev', 0.53778674660083),
  _CurrencyDef('BIF', 'Burundian franc', 0.0004857072283475),
  _CurrencyDef('XPF', 'CFP Franc', 0.0087849459951051),
  _CurrencyDef('KHR', 'Cambodian riel', 0.00024566052141109),
  _CurrencyDef('CAD', 'Canadian Dollar', 0.7769378238258),
  _CurrencyDef('CVE', 'Cape Verde escudo', 0.0094985740911239),
  _CurrencyDef('XAF', 'Central African CFA Franc', 0.0016014841703323),
  _CurrencyDef('CLP', 'Chilean Peso', 0.0010901925378079),
  _CurrencyDef('CNY', 'Chinese Yuan', 0.14928354794538),
  _CurrencyDef('COP', 'Colombian Peso', 0.00024376401209333),
  _CurrencyDef('KMF', 'Comoro franc', 0.0021341477106864),
  _CurrencyDef('CDF', 'Congolese franc', 0.00049962948824468),
  _CurrencyDef('CRC', 'Costa Rican Colón', 0.0014531554362804),
  _CurrencyDef('HRK', 'Croatian Kuna', 0.1396967430612),
  _CurrencyDef('CUP', 'Cuban peso', 1),
  _CurrencyDef('CZK', 'Czech Koruna', 0.042505419910199),
  _CurrencyDef('DKK', 'Danish Krone', 0.14136534203271),
  _CurrencyDef('DJF', 'Djiboutian franc', 0.0056144881323963),
  _CurrencyDef('DOP', 'Dominican Peso', 0.018197937781712),
  _CurrencyDef('XCD', 'East Caribbean Dollar', 0.36880515572721),
  _CurrencyDef('EGP', 'Egyptian Pound', 0.053217302646656),
  _CurrencyDef('ERN', 'Eritrean nakfa', 0.066287921316777),
  _CurrencyDef('ETB', 'Ethiopian birr', 0.019176790245436),
  _CurrencyDef('EUR', 'Euro', 1.0491504297869),
  _CurrencyDef('FJD', 'Fiji Dollar', 0.45442705409472),
  _CurrencyDef('GMD', 'Gambian dalasi', 0.018435766734781),
  _CurrencyDef('GEL', 'Georgian lari', 0.33596456004605),
  _CurrencyDef('GHS', 'Ghanaian Cedi', 0.12572698897447),
  _CurrencyDef('GIP', 'Gibraltar pound', 1.2177210910873),
  _CurrencyDef('GTQ', 'Guatemalan Quetzal', 0.12893809085397),
  _CurrencyDef('GNF', 'Guinean franc', 0.00011497092044102),
  _CurrencyDef('GYD', 'Guyanese dollar', 0.004777580670514),
  _CurrencyDef('HTG', 'Haitian gourde', 0.00870686511502),
  _CurrencyDef('HNL', 'Honduran Lempira', 0.040666472054431),
  _CurrencyDef('HKD', 'Hong Kong Dollar', 0.12742917294908),
  _CurrencyDef('HUF', 'Hungarian Forint', 0.002666002619358),
  _CurrencyDef('ISK', 'Icelandic Krona', 0.0075174919411889),
  _CurrencyDef('INR', 'Indian Rupee', 0.012664971908841),
  _CurrencyDef('IDR', 'Indonesian Rupiah', 6.7485064772832e-5),
  _CurrencyDef('IRR', 'Iranian rial', 2.3809039751302e-5),
  _CurrencyDef('IQD', 'Iraqi dinar', 0.00068493965658163),
  _CurrencyDef('ILS', 'Israeli New Sheqel', 0.28944785155092),
  _CurrencyDef('JMD', 'Jamaican Dollar', 0.0066467563379963),
  _CurrencyDef('JPY', 'Japanese Yen', 0.0073290067005682),
  _CurrencyDef('JOD', 'Jordanian Dinar', 1.41020392821),
  _CurrencyDef('KZT', 'Kazakhstani Tenge', 0.0021370304096711),
  _CurrencyDef('KES', 'Kenyan shilling', 0.008481575460894),
  _CurrencyDef('KWD', 'Kuwaiti Dinar', 3.260717923022),
  _CurrencyDef('KGS', 'Kyrgyzstan Som', 0.012295623276462),
  _CurrencyDef('LAK', 'Lao kip', 6.6467563379963e-5),
  _CurrencyDef('LBP', 'Lebanese Pound', 0.00066288056055034),
  _CurrencyDef('LSL', 'Lesotho loti', 0.061998967058135),
  _CurrencyDef('LRD', 'Liberian dollar', 0.0065569353064021),
  _CurrencyDef('LYD', 'Libyan Dinar', 0.20978472640589),
  _CurrencyDef('MOP', 'Macanese pataca', 0.1235937394741),
  _CurrencyDef('MKD', 'Macedonian denar', 0.017059259425594),
  _CurrencyDef('MGA', 'Malagasy ariary', 0.00024498686367413),
  _CurrencyDef('MWK', 'Malawian kwacha', 0.00097365998248493),
  _CurrencyDef('MYR', 'Malaysian Ringgit', 0.22754306701126),
  _CurrencyDef('MVR', 'Maldivian rufiyaa', 0.064648687490178),
  _CurrencyDef('MRO', 'Mauritanian Ouguiya', 0.027510809019223),
  _CurrencyDef('MRU', 'Mauritanian ouguiya', 0.027530146183729),
  _CurrencyDef('MUR', 'Mauritian Rupee', 0.022253160577549),
  _CurrencyDef('MXN', 'Mexican Peso', 0.049672181419948),
  _CurrencyDef('MDL', 'Moldova Lei', 0.052193272244178),
  _CurrencyDef('MNT', 'Mongolian togrog', 0.00031774189926571),
  _CurrencyDef('MAD', 'Moroccan Dirham', 0.1006408904626),
  _CurrencyDef('MZN', 'Mozambican metical', 0.015583948981654),
  _CurrencyDef('MMK', 'Myanma Kyat', 0.00053982439988322),
  _CurrencyDef('NAD', 'Namibian dollar', 0.061998967058135),
  _CurrencyDef('NPR', 'Nepalese Rupee', 0.007922256293237),
  _CurrencyDef('ANG', 'Neth. Antillean Guilder', 0.5578493768886),
  _CurrencyDef('TWD', 'New Taiwan Dollar', 0.03371821409765),
  _CurrencyDef('TMT', 'New Turkmenistan Manat', 0.285740049248),
  _CurrencyDef('NZD', 'New Zealand Dollar', 0.62254725091649),
  _CurrencyDef('NIO', 'Nicaraguan Córdoba', 0.027866975052208),
  _CurrencyDef('NGN', 'Nigerian Naira', 0.0024092001729919),
  _CurrencyDef('NOK', 'Norwegian Krone', 0.10158204592563),
  _CurrencyDef('OMR', 'Omani Rial', 2.5968904406012),
  _CurrencyDef('PKR', 'Pakistani Rupee', 0.0049907659932132),
  _CurrencyDef('PAB', 'Panamanian Balboa', 1),
  _CurrencyDef('PGK', 'Papua New Guinean kina', 0.28363249614669),
  _CurrencyDef('PYG', 'Paraguayan Guaraní', 0.00014575360678417),
  _CurrencyDef('PEN', 'Peruvian Nuevo Sol', 0.26401326960599),
  _CurrencyDef('PHP', 'Philippine Peso', 0.018203372705744),
  _CurrencyDef('PLN', 'Polish Zloty', 0.22440084396285),
  _CurrencyDef('QAR', 'Qatari Rial', 0.27251892589149),
  _CurrencyDef('RON', 'Romanian New Leu', 0.21281306120777),
  _CurrencyDef('RUB', 'Russian Rouble', 0.018676582748096),
  _CurrencyDef('RWF', 'Rwandan franc', 0.00097770192890661),
  _CurrencyDef('SVC', 'Salvadoran colon', 0.11416253115667),
  _CurrencyDef('WST', 'Samoan tala', 0.36880515572721),
  _CurrencyDef('SAR', 'Saudi Riyal', 0.26651050120422),
  _CurrencyDef('RSD', 'Serbian Dinar', 0.009089358901203),
  _CurrencyDef('SCR', 'Seychelles rupee', 0.077942200166168),
  _CurrencyDef('SLL', 'Sierra Leonean leone', 7.5898771697394e-5),
  _CurrencyDef('SGD', 'Singapore Dollar', 0.71892402363232),
  _CurrencyDef('SBD', 'Solomon Islands dollar', 0.12287517122134),
  _CurrencyDef('SOS', 'Somali shilling', 0.0017277075427211),
  _CurrencyDef('ZAR', 'South African Rand', 0.061786304309833),
  _CurrencyDef('KRW', 'South Korean Won', 0.00077000168503924),
  _CurrencyDef('SSP', 'South Sudanese pound', 0.0020189522376664),
  _CurrencyDef('LKR', 'Sri Lanka Rupee', 0.0027748974598279),
  _CurrencyDef('SDG', 'Sudanese pound', 0.0017515101160937),
  _CurrencyDef('SRD', 'Surinamese dollar', 0.045269799923652),
  _CurrencyDef('SZL', 'Swazi lilangeni', 0.061998967058135),
  _CurrencyDef('SEK', 'Swedish Krona', 0.098054935088659),
  _CurrencyDef('CHF', 'Swiss Franc', 1.0488323500727),
  _CurrencyDef('SYP', 'Syrian pound', 0.00040419464217546),
  _CurrencyDef('STN', 'São Tomé and Príncipe Dobra', 0.042462892686322),
  _CurrencyDef('TJS', 'Tajikistan Ruble', 0.08829042119346),
  _CurrencyDef('TZS', 'Tanzanian shilling', 0.00042867087328498),
  _CurrencyDef('THB', 'Thai Baht', 0.028623344394537),
  _CurrencyDef('TOP', 'Tongan paʻanga', 0.42640289223722),
  _CurrencyDef('TTD', 'Trinidad Tobago Dollar', 0.14705948397817),
  _CurrencyDef('TND', 'Tunisian Dinar', 0.32606429132959),
  _CurrencyDef('TRY', 'Turkish Lira', 0.060157086404689),
  _CurrencyDef('AED', 'U.A.E Dirham', 0.27224734590936),
  _CurrencyDef('GBP', 'U.K. Pound Sterling', 1.2152450785161),
  _CurrencyDef('USD', 'US Dollar', 1.0),
  _CurrencyDef('UGX', 'Ugandan shilling', 0.00026564570094087),
  _CurrencyDef('UAH', 'Ukrainian Hryvnia', 0.034049192672692),
  _CurrencyDef('UYU', 'Uruguayan Peso', 0.025311700245939),
  _CurrencyDef('UZS', 'Uzbekistan Sum', 9.1160793500197e-5),
  _CurrencyDef('VUV', 'Vanuatu vatu', 0.0085642108099612),
  _CurrencyDef('VES', 'Venezuelan Bolivar', 0.18193403186875),
  _CurrencyDef('VND', 'Vietnamese Dong', 4.3078660411508e-5),
  _CurrencyDef('XOF', 'West African CFA Franc', 0.0016020884369195),
  _CurrencyDef('YER', 'Yemeni rial', 0.0039945658275885),
  _CurrencyDef('ZMW', 'Zambian kwacha', 0.058361215278556),
];

/// Trả list currency đã clean name + dedupe + sort theo name ASC.
/// Khớp logic Android `Utils.getListSupportedCurrency`:
/// - clean name: bỏ \t, trim, capitalize từng chữ
/// - đảm bảo USD luôn có trong list
/// - sort theo name ASC
List<CurrencyRate> getSupportedCurrencies() {
  final map = <String, CurrencyRate>{};
  for (final d in _kCurrencyDefinitions) {
    map[d.code] = CurrencyRate(code: d.code, name: _capitalizeWords(d.name), rate: d.rate);
  }
  // Logic luôn force-add USD; map.putIfAbsent đảm bảo không duplicate.
  map.putIfAbsent('USD', () => const CurrencyRate(code: 'USD', name: 'US Dollar', rate: 1.0));
  final list = map.values.toList();
  list.sort((a, b) => a.name.compareTo(b.name));
  return list;
}

String _capitalizeWords(String s) {
  final cleaned = s.replaceAll('\t', '').trim();
  return cleaned.split(' ').map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}').join(' ');
}
