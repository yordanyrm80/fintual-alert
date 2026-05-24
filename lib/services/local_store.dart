import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_state.dart';

const _storeKey = 'fintual_alert_state_v1';

class LocalStore {
  Future<AppState> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storeKey);
    if (raw == null) return AppState.defaults();

    try {
      return AppState.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return AppState.defaults();
    }
  }

  Future<void> save(AppState state) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storeKey, jsonEncode(state.toJson()));
  }
}
