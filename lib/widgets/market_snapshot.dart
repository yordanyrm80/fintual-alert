import 'package:flutter/material.dart';

import '../models/market_data.dart';
import '../utils/formatters.dart';

class MarketSnapshot extends StatelessWidget {
  const MarketSnapshot({
    super.key,
    required this.market,
    required this.onEdit,
    required this.onRefresh,
    required this.refreshing,
  });

  final MarketData market;
  final VoidCallback onEdit;
  final VoidCallback onRefresh;
  final bool refreshing;

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
                  tooltip: 'Actualizar en vivo',
                  onPressed: refreshing ? null : onRefresh,
                  icon: refreshing
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.sync),
                ),
                const SizedBox(width: 8),
                IconButton.outlined(
                  tooltip: 'Ajuste manual',
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Datos leidos en vivo desde internet. Puedes ajustar manualmente si hace falta.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            _Row(
              label: 'Caida desde maximo',
              value: '${market.drawdown.toStringAsFixed(1)}%',
            ),
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
