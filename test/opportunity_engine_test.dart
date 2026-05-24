import 'package:flutter_test/flutter_test.dart';
import 'package:fintual_alert/models/app_state.dart';
import 'package:fintual_alert/models/market_data.dart';
import 'package:fintual_alert/models/settings_data.dart';
import 'package:fintual_alert/services/opportunity_engine.dart';

void main() {
  test('detecta una oportunidad muy buena con caida y VIX altos', () {
    final state = AppState(
      settings: SettingsData.defaults(),
      market: MarketData(
        drawdown: 22,
        vix: 34,
        usdMxn: 17.2,
        usdMxnReference: 18.2,
        notes: '',
        updatedAt: DateTime(2026, 5, 24),
      ),
      deposits: const [],
      lastAlertKey: '',
    );

    final result = OpportunityEngine.evaluate(state);

    expect(result.level, SignalLevel.great);
    expect(result.suggestedDeposit, greaterThan(0));
  });

  test('mantiene aportacion normal cuando las senales estan calmadas', () {
    final state = AppState(
      settings: SettingsData.defaults(),
      market: MarketData(
        drawdown: 1,
        vix: 16,
        usdMxn: 18,
        usdMxnReference: 18,
        notes: '',
        updatedAt: DateTime(2026, 5, 24),
      ),
      deposits: const [],
      lastAlertKey: '',
    );

    final result = OpportunityEngine.evaluate(state);

    expect(result.level, SignalLevel.normal);
    expect(result.suggestedDeposit, greaterThan(0));
    expect(result.suggestedDeposit, lessThanOrEqualTo(2000));
  });
}
