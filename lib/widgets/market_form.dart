import 'package:flutter/material.dart';

import '../models/market_data.dart';
import '../utils/formatters.dart';
import '../utils/number_utils.dart';
import 'number_field.dart';

class MarketForm extends StatefulWidget {
  const MarketForm({super.key, required this.market, required this.onChanged});

  final MarketData market;
  final ValueChanged<MarketData> onChanged;

  @override
  State<MarketForm> createState() => _MarketFormState();
}

class _MarketFormState extends State<MarketForm> {
  late final TextEditingController _drawdown;
  late final TextEditingController _vix;
  late final TextEditingController _usdMxn;
  late final TextEditingController _usdMxnReference;
  late final TextEditingController _notes;

  @override
  void initState() {
    super.initState();
    _drawdown = TextEditingController(
      text: widget.market.drawdown.toStringAsFixed(1),
    );
    _vix = TextEditingController(text: widget.market.vix.toStringAsFixed(1));
    _usdMxn = TextEditingController(
      text: widget.market.usdMxn.toStringAsFixed(2),
    );
    _usdMxnReference = TextEditingController(
      text: widget.market.usdMxnReference.toStringAsFixed(2),
    );
    _notes = TextEditingController(text: widget.market.notes);
  }

  @override
  void dispose() {
    _drawdown.dispose();
    _vix.dispose();
    _usdMxn.dispose();
    _usdMxnReference.dispose();
    _notes.dispose();
    super.dispose();
  }

  void _save() {
    widget.onChanged(
      MarketData(
        drawdown: parseNumber(_drawdown.text),
        vix: parseNumber(_vix.text),
        usdMxn: parseNumber(_usdMxn.text),
        usdMxnReference: parseNumber(_usdMxnReference.text),
        notes: _notes.text.trim(),
        updatedAt: DateTime.now(),
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
            Text(
              'Ajuste manual',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            NumberField(
              controller: _drawdown,
              label: 'Caida desde maximo (%)',
              icon: Icons.trending_down,
            ),
            const SizedBox(height: 10),
            NumberField(
              controller: _vix,
              label: 'VIX',
              icon: Icons.speed_outlined,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: NumberField(
                    controller: _usdMxn,
                    label: 'USD/MXN',
                    icon: Icons.attach_money,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: NumberField(
                    controller: _usdMxnReference,
                    label: 'Referencia',
                    icon: Icons.compare_arrows,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _notes,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Notas',
                prefixIcon: Icon(Icons.notes_outlined),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save_outlined),
                label: const Text('Guardar senales'),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ultima actualizacion: ${shortDateTime(widget.market.updatedAt)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
