import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefrencesHelper {
  static SharedPreferences? _preferences;
  static const _dateFormat = 'format';
  static const _currencySymbol = 'currency_symbol';
  static const _currencyCode = 'currency_code';



  static Future init() async =>
      _preferences = await SharedPreferences.getInstance();
  static Future setDateFormat(String format) async =>
      await _preferences?.setString(_dateFormat, format);

  static String? getDateFormat() => _preferences?.getString(_dateFormat);


  static Future setCurrencySymbol(String currency) async =>
      await _preferences?.setString(_currencySymbol, currency);

  static String? getCurrencySymbol() => _preferences?.getString( _currencySymbol);

  static Future setCurrencyCode(String currency) async =>
      await _preferences?.setString(_currencyCode, currency);

  static String? getCurrencyCode() => _preferences?.getString(_currencyCode);

}
