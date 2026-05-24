import 'package:flutter/material.dart';

import '../models/app_state.dart';
import '../services/opportunity_engine.dart';
import '../utils/formatters.dart';
import 'status_panel.dart';

class DashboardSummary extends StatelessWidget {
  const DashboardSummary({
    super.key,
    required this.state,
    required this.result,
    required this.onAddDeposit,
    required this.onUpdateMarket,
    required this.refreshingMarket,
  });

  final AppState state;
  final OpportunityResult result;
  final VoidCallback onAddDeposit;
  final VoidCallback onUpdateMarket;
  final bool refreshingMarket;

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
                Expanded(child: _DecisionHeader(result: result)),
                const SizedBox(width: 12),
                _ScoreBadge(result: result),
              ],
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _Metric(
                  label: 'Sugerido',
                  value: money(result.suggestedDeposit),
                ),
                _Metric(
                  label: 'Invertido',
                  value: money(state.depositedThisYear),
                ),
                _Metric(
                  label: 'Pendiente',
                  value: money(state.remainingTarget),
                ),
                _Metric(
                  label: 'Ritmo mensual',
                  value: money(state.requiredMonthlyRunRate),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(minHeight: 10, value: progress),
            ),
            const SizedBox(height: 8),
            Text(
              '${money(state.depositedThisYear)} / ${money(state.settings.annualTarget)} del objetivo anual',
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                FilledButton.icon(
                  onPressed: onAddDeposit,
                  icon: const Icon(Icons.add),
                  label: const Text('Registrar deposito'),
                ),
                OutlinedButton.icon(
                  onPressed: refreshingMarket ? null : onUpdateMarket,
                  icon: refreshingMarket
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.sync),
                  label: const Text('Actualizar en vivo'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DecisionHeader extends StatelessWidget {
  const _DecisionHeader({required this.result});

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

class _ScoreBadge extends StatelessWidget {
  const _ScoreBadge({required this.result});

  final OpportunityResult result;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 78,
      height: 78,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: signalColor(result.level), width: 6),
      ),
      alignment: Alignment.center,
      child: Text(
        '${result.score}',
        style: Theme.of(
          context,
        ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.labelMedium),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
