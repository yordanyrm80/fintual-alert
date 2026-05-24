import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NumberField extends StatelessWidget {
  const NumberField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      autofocus: autofocus,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
    );
  }
}
