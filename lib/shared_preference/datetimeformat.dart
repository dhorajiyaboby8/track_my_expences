import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefrencesHelper {
  static SharedPreferences? _preferences;
  static const _keyformat = 'format';
  static const _keycurrency = 'currency';
  static const _keycurrencycode = 'currencycode';



  static Future init() async =>
      _preferences = await SharedPreferences.getInstance();
  static Future setdateformat(String format) async =>
      await _preferences?.setString(_keyformat, format);

  static String? getdateformat() => _preferences?.getString(_keyformat);


  static Future setcurrency(String currency) async =>
      await _preferences?.setString(_keycurrency, currency);

  static String? getcurrency() => _preferences?.getString( _keycurrency);

  static Future setcurrencycode(String currency) async =>
      await _preferences?.setString(_keycurrencycode, currency);

  static String? getcurrencycode() => _preferences?.getString(_keycurrencycode);

}
