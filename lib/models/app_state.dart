import 'dart:math';

import 'deposit.dart';
import 'market_data.dart';
import 'settings_data.dart';

class AppState {
  const AppState({
    required this.settings,
    required this.market,
    required this.deposits,
    required this.lastAlertKey,
  });

  factory AppState.defaults() => AppState(
    settings: SettingsData.defaults(),
    market: MarketData.defaults(),
    deposits: const [],
    lastAlertKey: '',
  );

  final SettingsData settings;
  final MarketData market;
  final List<Deposit> deposits;
  final String lastAlertKey;

  double get depositedThisYear {
    final year = DateTime.now().year;
    return deposits
        .where((deposit) => deposit.date.year == year)
        .fold(0.0, (sum, deposit) => sum + deposit.amount);
  }

  double get remainingTarget =>
      max(0, settings.annualTarget - depositedThisYear);

  double get progress {
    if (settings.annualTarget <= 0) return 0;
    return depositedThisYear / settings.annualTarget;
  }

  int get monthsLeftInYear => 13 - DateTime.now().month;

  double get requiredMonthlyRunRate =>
      remainingTarget / max(1, monthsLeftInYear);

  AppState copyWith({
    SettingsData? settings,
    MarketData? market,
    List<Deposit>? deposits,
    String? lastAlertKey,
  }) {
    return AppState(
      settings: settings ?? this.settings,
      market: market ?? this.market,
      deposits: deposits ?? this.deposits,
      lastAlertKey: lastAlertKey ?? this.lastAlertKey,
    );
  }

  Map<String, dynamic> toJson() => {
    'settings': settings.toJson(),
    'market': market.toJson(),
    'deposits': deposits.map((deposit) => deposit.toJson()).toList(),
    'lastAlertKey': lastAlertKey,
  };

  factory AppState.fromJson(Map<String, dynamic> json) => AppState(
    settings: SettingsData.fromJson(json['settings'] as Map<String, dynamic>?),
    market: MarketData.fromJson(json['market'] as Map<String, dynamic>?),
    deposits: (json['deposits'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(Deposit.fromJson)
        .toList(),
    lastAlertKey: json['lastAlertKey'] as String? ?? '',
  );
}
