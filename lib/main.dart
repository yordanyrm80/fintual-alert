import 'package:flutter/material.dart';

import 'app/fintual_alert_app.dart';
import 'services/alert_service.dart';
import 'services/local_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final alerts = AlertService();
  await alerts.init();

  final store = LocalStore();
  final state = await store.load();

  runApp(FintualAlertApp(store: store, alerts: alerts, initialState: state));
}
