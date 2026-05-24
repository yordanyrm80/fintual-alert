import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;

import '../models/market_data.dart';

class MarketDataService {
  const MarketDataService({http.Client? client}) : _client = client;

  final http.Client? _client;

  Future<MarketData> fetch() async {
    final client = _client ?? http.Client();
    try {
      final sp500 = await _fetchSeries(client, '%5EGSPC', '1y');
      final vix = await _fetchSeries(client, '%5EVIX', '1mo');
      final usdMxn = await _fetchSeries(client, 'MXN%3DX', '1y');
      final currentSp500 = sp500.last;
      final highSp500 = sp500.reduce(max);
      final currentUsdMxn = usdMxn.last;

      return MarketData(
        drawdown: ((highSp500 - currentSp500) / highSp500) * 100,
        vix: vix.last,
        usdMxn: currentUsdMxn,
        usdMxnReference: _average(usdMxn.skip(max(0, usdMxn.length - 90))),
        notes: 'Fuente: Yahoo Finance. Referencia FX: promedio aprox. 90 dias.',
        updatedAt: DateTime.now(),
      );
    } finally {
      if (_client == null) client.close();
    }
  }

  Future<List<double>> _fetchSeries(
    http.Client client,
    String symbol,
    String range,
  ) async {
    final url = Uri.parse(
      'https://query1.finance.yahoo.com/v8/finance/chart/$symbol?range=$range&interval=1d',
    );
    final response = await client.get(url);
    if (response.statusCode != 200) {
      throw MarketDataException('No se pudo leer $symbol.');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final result =
        ((json['chart'] as Map<String, dynamic>)['result'] as List).first
            as Map<String, dynamic>;
    final quote =
        ((result['indicators'] as Map<String, dynamic>)['quote'] as List).first
            as Map<String, dynamic>;
    final closes = (quote['close'] as List)
        .whereType<num>()
        .map((value) => value.toDouble())
        .where((value) => value > 0)
        .toList();

    if (closes.isEmpty) {
      throw MarketDataException('Sin datos validos para $symbol.');
    }
    return closes;
  }

  double _average(Iterable<double> values) {
    final list = values.toList();
    return list.reduce((a, b) => a + b) / list.length;
  }
}

class MarketDataException implements Exception {
  const MarketDataException(this.message);

  final String message;

  @override
  String toString() => message;
}
