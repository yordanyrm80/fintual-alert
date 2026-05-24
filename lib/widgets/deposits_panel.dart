import 'package:flutter/material.dart';

import '../models/deposit.dart';
import '../utils/formatters.dart';

class DepositsPanel extends StatelessWidget {
  const DepositsPanel({
    super.key,
    required this.deposits,
    required this.onDelete,
  });

  final List<Deposit> deposits;
  final ValueChanged<String> onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Depositos', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            if (deposits.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 18),
                child: Text('Aun no hay depositos registrados este ano.'),
              )
            else
              ...deposits.map(
                (deposit) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.savings_outlined),
                  title: Text(money(deposit.amount)),
                  subtitle: Text(_subtitle(deposit)),
                  trailing: IconButton(
                    tooltip: 'Eliminar',
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => onDelete(deposit.id),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _subtitle(Deposit deposit) {
    return [
      shortDate(deposit.date),
      if (deposit.note.isNotEmpty) deposit.note,
    ].join(' - ');
  }
}
