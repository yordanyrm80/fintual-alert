import 'package:flutter/material.dart';

import '../models/deposit.dart';
import '../utils/formatters.dart';
import '../utils/number_utils.dart';
import 'number_field.dart';

class DepositDialog extends StatefulWidget {
  DepositDialog({super.key}) : today = DateTime.now();

  final DateTime today;

  @override
  State<DepositDialog> createState() => _DepositDialogState();
}

class _DepositDialogState extends State<DepositDialog> {
  final _amount = TextEditingController();
  final _note = TextEditingController();
  late DateTime _date;

  @override
  void initState() {
    super.initState();
    _date = widget.today;
  }

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(widget.today.year - 1),
      lastDate: DateTime(widget.today.year + 1),
    );
    if (date != null) setState(() => _date = date);
  }

  void _save() {
    final amount = parseNumber(_amount.text);
    if (amount <= 0) return;
    Navigator.of(context).pop(
      Deposit(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        date: _date,
        amount: amount,
        note: _note.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Registrar deposito'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            NumberField(
              controller: _amount,
              label: 'Monto',
              icon: Icons.payments_outlined,
              autofocus: true,
            ),
            const SizedBox(height: 10),
            _DateField(date: _date, onTap: _pickDate),
            const SizedBox(height: 10),
            TextField(
              controller: _note,
              decoration: const InputDecoration(
                labelText: 'Nota',
                prefixIcon: Icon(Icons.notes_outlined),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _save, child: const Text('Guardar')),
      ],
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({required this.date, required this.onTap});

  final DateTime date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextField(
      readOnly: true,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: 'Fecha',
        prefixIcon: const Icon(Icons.calendar_today_outlined),
        suffixIcon: IconButton(
          tooltip: 'Cambiar fecha',
          onPressed: onTap,
          icon: const Icon(Icons.edit_calendar_outlined),
        ),
      ),
      controller: TextEditingController(text: shortDate(date)),
    );
  }
}
