import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../utils/formatters.dart';
import 'opportunity_engine.dart';

class AlertService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
      macOS: DarwinInitializationSettings(),
      linux: LinuxInitializationSettings(defaultActionName: 'Abrir'),
      windows: WindowsInitializationSettings(
        appName: 'Fintual Alert',
        appUserModelId: 'Yordany.Fintual.Ppr',
        guid: 'bd51b171-0f39-473d-81af-05a71f245d95',
      ),
    );

    await _plugin.initialize(settings: settings);
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  Future<void> showOpportunity(OpportunityResult result) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'ppr_opportunities',
        'Oportunidades PPR',
        channelDescription: 'Alertas locales para depositos del PPR',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
      macOS: DarwinNotificationDetails(),
      linux: LinuxNotificationDetails(),
      windows: WindowsNotificationDetails(
        subtitle: 'Fintual Alert',
        duration: WindowsNotificationDuration.long,
      ),
    );

    await _plugin.show(
      id: 1001,
      title: result.title,
      body: 'Deposito sugerido: ${money(result.suggestedDeposit)}',
      notificationDetails: details,
    );
  }
}
