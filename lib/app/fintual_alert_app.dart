import 'package:flutter/material.dart';

import '../models/app_state.dart';
import '../screens/home_page.dart';
import '../services/alert_service.dart';
import '../services/local_store.dart';

class FintualAlertApp extends StatelessWidget {
  const FintualAlertApp({
    super.key,
    required this.store,
    required this.alerts,
    required this.initialState,
  });

  final LocalStore store;
  final AlertService alerts;
  final AppState initialState;

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xff147d6f);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fintual Alert',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: seed),
        scaffoldBackgroundColor: const Color(0xfff6f7f4),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          isDense: true,
        ),
        cardTheme: const CardThemeData(
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            side: BorderSide(color: Color(0xffdfe5dc)),
          ),
        ),
      ),
      home: HomePage(store: store, alerts: alerts, initialState: initialState),
    );
  }
}
