import 'package:flutter/material.dart';

import '../models/settings_data.dart';
import '../widgets/settings_form.dart';

class PlanPage extends StatelessWidget {
  const PlanPage({
    super.key,
    required this.settings,
    required this.onChanged,
    required this.onTestAlert,
  });

  final SettingsData settings;
  final ValueChanged<SettingsData> onChanged;
  final VoidCallback onTestAlert;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Plan')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: SettingsForm(
                settings: settings,
                onChanged: (settings) {
                  onChanged(settings);
                  Navigator.of(context).maybePop();
                },
                onTestAlert: onTestAlert,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
