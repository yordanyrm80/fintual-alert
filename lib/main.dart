import 'package:flutter/material.dart';

import 'app/fintual_alert_app.dart';
import 'services/alert_service.dart';
import 'services/backup_service.dart';
import 'services/local_store.dart';
import 'services/market_data_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final alerts = AlertService();
  await alerts.init();

  final store = LocalStore();
  final state = await store.load();
  final backup = BackupService();
  const marketData = MarketDataService();

  runApp(
    FintualAlertApp(
      store: store,
      alerts: alerts,
      backup: backup,
      marketData: marketData,
      initialState: state,
    ),
  );
}
