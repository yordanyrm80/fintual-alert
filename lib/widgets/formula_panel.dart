import 'package:flutter/material.dart';

class FormulaPanel extends StatelessWidget {
  const FormulaPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Regla de calculo',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text(
              'El score suma puntos por mercado barato, miedo alto y ritmo anual.',
            ),
            const SizedBox(height: 12),
            const _FormulaRow(
              'Caida 7% / 10% / 15% / 20% / 30%',
              '+15 / +25 / +34 / +45 / +55',
            ),
            const _FormulaRow('VIX 20 / 25 / 30 / 40', '+6 / +14 / +22 / +28'),
            const _FormulaRow('Peso fuerte vs referencia', '+8 a +15'),
            const _FormulaRow('Atrasado contra objetivo anual', '+10'),
            const Divider(height: 20),
            const _FormulaRow('Score 0-39', 'Momento normal'),
            const _FormulaRow('Score 40-64', 'Buen momento'),
            const _FormulaRow('Score 65+', 'Muy buen momento'),
          ],
        ),
      ),
    );
  }
}

class _FormulaRow extends StatelessWidget {
  const _FormulaRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(label)),
          const SizedBox(width: 12),
          Text(
            value,
            textAlign: TextAlign.right,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
