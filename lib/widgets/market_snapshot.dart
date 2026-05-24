import 'package:flutter/material.dart';

import '../models/market_data.dart';
import '../utils/formatters.dart';

class MarketSnapshot extends StatelessWidget {
  const MarketSnapshot({super.key, required this.market, required this.onEdit});

  final MarketData market;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Mercado actual',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                IconButton.outlined(
                  tooltip: 'Actualizar mercado',
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _Row(label: 'Caida desde maximo', value: '${market.drawdown}%'),
            _Row(label: 'VIX', value: market.vix.toStringAsFixed(1)),
            _Row(label: 'USD/MXN', value: market.usdMxn.toStringAsFixed(2)),
            _Row(
              label: 'Referencia FX',
              value: market.usdMxnReference.toStringAsFixed(2),
            ),
            const SizedBox(height: 8),
            Text(
              'Actualizado: ${shortDateTime(market.updatedAt)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (market.notes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(market.notes),
            ],
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
