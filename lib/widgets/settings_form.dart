import 'package:flutter/material.dart';

import '../models/settings_data.dart';
import '../utils/number_utils.dart';
import 'number_field.dart';

class SettingsForm extends StatefulWidget {
  const SettingsForm({
    super.key,
    required this.settings,
    required this.onChanged,
    required this.onTestAlert,
  });

  final SettingsData settings;
  final ValueChanged<SettingsData> onChanged;
  final VoidCallback onTestAlert;

  @override
  State<SettingsForm> createState() => _SettingsFormState();
}

class _SettingsFormState extends State<SettingsForm> {
  late final TextEditingController _annualTarget;
  late final TextEditingController _monthlyDeductibleCap;
  late bool _notifications;

  @override
  void initState() {
    super.initState();
    _annualTarget = TextEditingController(
      text: widget.settings.annualTarget.toStringAsFixed(0),
    );
    _monthlyDeductibleCap = TextEditingController(
      text: widget.settings.monthlyDeductibleCap.toStringAsFixed(0),
    );
    _notifications = widget.settings.notificationsEnabled;
  }

  @override
  void dispose() {
    _annualTarget.dispose();
    _monthlyDeductibleCap.dispose();
    super.dispose();
  }

  void _save() {
    widget.onChanged(
      widget.settings.copyWith(
        annualTarget: parseNumber(_annualTarget.text),
        monthlyDeductibleCap: parseNumber(_monthlyDeductibleCap.text),
        notificationsEnabled: _notifications,
      ),
    );
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Plan', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            NumberField(
              controller: _annualTarget,
              label: 'Objetivo anual',
              icon: Icons.flag_outlined,
            ),
            const SizedBox(height: 10),
            NumberField(
              controller: _monthlyDeductibleCap,
              label: 'Tope mensual deducible',
              icon: Icons.receipt_long_outlined,
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _notifications,
              title: const Text('Notificar oportunidad muy buena'),
              subtitle: const Text(
                'Se evalua con las senales locales guardadas.',
              ),
              onChanged: (value) => setState(() => _notifications = value),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Guardar plan'),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton.outlined(
                  tooltip: 'Probar alerta',
                  onPressed: widget.onTestAlert,
                  icon: const Icon(Icons.notifications_active_outlined),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
