import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefHelper {
  SharedPrefHelper(this.sharedPreferences);

  final SharedPreferences sharedPreferences;

  Future<bool> saveData({required String key, required Object val}) {
    return switch (val) {
      int() => sharedPreferences.setInt(key, val),
      double() => sharedPreferences.setDouble(key, val),
      String() => sharedPreferences.setString(key, val),
      bool() => sharedPreferences.setBool(key, val),
      _ => sharedPreferences.setString(key, val.toString()),
    };
  }

  Object? getData({required String key}) => sharedPreferences.get(key);

  Future<bool> removeData({required String key}) {
    return sharedPreferences.remove(key);
  }
}
