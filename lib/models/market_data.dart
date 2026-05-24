import '../utils/number_utils.dart';

class MarketData {
  const MarketData({
    required this.drawdown,
    required this.vix,
    required this.usdMxn,
    required this.usdMxnReference,
    required this.notes,
    required this.updatedAt,
  });

  factory MarketData.defaults() => MarketData(
    drawdown: 0,
    vix: 18,
    usdMxn: 18,
    usdMxnReference: 18,
    notes: '',
    updatedAt: DateTime.now(),
  );

  final double drawdown;
  final double vix;
  final double usdMxn;
  final double usdMxnReference;
  final String notes;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() => {
    'drawdown': drawdown,
    'vix': vix,
    'usdMxn': usdMxn,
    'usdMxnReference': usdMxnReference,
    'notes': notes,
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory MarketData.fromJson(Map<String, dynamic>? json) {
    if (json == null) return MarketData.defaults();
    return MarketData(
      drawdown: readDouble(json['drawdown'], 0),
      vix: readDouble(json['vix'], 18),
      usdMxn: readDouble(json['usdMxn'], 18),
      usdMxnReference: readDouble(json['usdMxnReference'], 18),
      notes: json['notes'] as String? ?? '',
      updatedAt:
          DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
