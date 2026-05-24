import 'package:flutter/material.dart';

import '../models/app_state.dart';
import '../services/opportunity_engine.dart';
import '../utils/formatters.dart';
import 'status_panel.dart';

class SignalsPanel extends StatelessWidget {
  const SignalsPanel({super.key, required this.state, required this.result});

  final AppState state;
  final OpportunityResult result;

  @override
  Widget build(BuildContext context) {
    final items = [
      _SignalItem(
        'Caida',
        '${state.market.drawdown.toStringAsFixed(1)}%',
        result.drawdownText,
        Icons.trending_down,
      ),
      _SignalItem(
        'VIX',
        state.market.vix.toStringAsFixed(1),
        result.vixText,
        Icons.speed_outlined,
      ),
      _SignalItem(
        'USD/MXN',
        state.market.usdMxn.toStringAsFixed(2),
        result.fxText,
        Icons.currency_exchange,
      ),
      _SignalItem(
        'Ritmo',
        money(state.requiredMonthlyRunRate),
        result.calendarText,
        Icons.calendar_month_outlined,
      ),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Senales',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth > 640 ? 2 : 1;
                return GridView.count(
                  crossAxisCount: columns,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: constraints.maxWidth > 640 ? 3.2 : 3.8,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: items
                      .map((item) => _SignalTile(item: item))
                      .toList(),
                );
              },
            ),
            const SizedBox(height: 12),
            ...result.reasons.map(
              (reason) => Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 18,
                      color: signalColor(result.level),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(reason)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SignalItem {
  const _SignalItem(this.label, this.value, this.note, this.icon);
  final String label;
  final String value;
  final String note;
  final IconData icon;
}

class _SignalTile extends StatelessWidget {
  const _SignalTile({required this.item});

  final _SignalItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xffdfe5dc)),
      ),
      child: Row(
        children: [
          Icon(item.icon),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.label,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                Text(
                  item.value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  item.note,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
