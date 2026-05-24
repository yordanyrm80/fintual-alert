import 'package:flutter/material.dart';

import '../models/app_state.dart';
import '../services/opportunity_engine.dart';
import '../utils/formatters.dart';

class StatusPanel extends StatelessWidget {
  const StatusPanel({
    super.key,
    required this.state,
    required this.result,
    required this.onAddDeposit,
  });

  final AppState state;
  final OpportunityResult result;
  final VoidCallback onAddDeposit;

  @override
  Widget build(BuildContext context) {
    final progress = state.progress.clamp(0, 1).toDouble();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _Headline(result: result)),
                const SizedBox(width: 12),
                _ScoreDial(
                  score: result.score,
                  color: signalColor(result.level),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _MetricTile(
                    label: 'Deposito sugerido',
                    value: money(result.suggestedDeposit),
                    icon: Icons.payments_outlined,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MetricTile(
                    label: 'Pendiente 2026',
                    value: money(state.remainingTarget),
                    icon: Icons.flag_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                minHeight: 11,
                value: progress,
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${money(state.depositedThisYear)} de ${money(state.settings.annualTarget)} capturados este ano',
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onAddDeposit,
              icon: const Icon(Icons.add),
              label: const Text('Registrar deposito'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Headline extends StatelessWidget {
  const _Headline({required this.result});

  final OpportunityResult result;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          result.title,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: signalColor(result.level),
          ),
        ),
        const SizedBox(height: 6),
        Text(result.message, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}

class _ScoreDial extends StatelessWidget {
  const _ScoreDial({required this.score, required this.color});

  final int score;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 82,
      height: 82,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: score / 100,
            strokeWidth: 8,
            color: color,
            backgroundColor: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest,
          ),
          Text(
            '$score',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.labelMedium),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Color signalColor(SignalLevel level) => switch (level) {
  SignalLevel.great => const Color(0xff0b6b45),
  SignalLevel.good => const Color(0xffb26a00),
  SignalLevel.normal => const Color(0xff59635d),
};
