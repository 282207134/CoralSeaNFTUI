import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

abstract interface class MarketplaceRepository {
  Map<String, dynamic> load();
  Future<void> save(Map<String, dynamic> data);
}

class LocalRepository implements MarketplaceRepository {
  LocalRepository(this._preferences);
  final SharedPreferences _preferences;
  static const _key = 'coralsea.marketplace.v1';
  static Future<LocalRepository> open() async =>
      LocalRepository(await SharedPreferences.getInstance());
  @override
  Map<String, dynamic> load() {
    try {
      return jsonDecode(_preferences.getString(_key) ?? '{}')
          as Map<String, dynamic>;
    } on FormatException {
      return {};
    } on TypeError {
      return {};
    }
  }

  @override
  Future<void> save(Map<String, dynamic> data) async {
    if (!await _preferences.setString(_key, jsonEncode(data))) {
      throw StateError('Your changes could not be saved on this device.');
    }
  }
}
