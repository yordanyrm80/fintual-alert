import '../utils/number_utils.dart';

class Deposit {
  const Deposit({
    required this.id,
    required this.date,
    required this.amount,
    required this.note,
  });

  final String id;
  final DateTime date;
  final double amount;
  final String note;

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'amount': amount,
    'note': note,
  };

  factory Deposit.fromJson(Map<String, dynamic> json) => Deposit(
    id: json['id'] as String? ?? '',
    date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
    amount: readDouble(json['amount'], 0),
    note: json['note'] as String? ?? '',
  );
}
