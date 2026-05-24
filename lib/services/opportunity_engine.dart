import 'dart:math';

import '../models/app_state.dart';
import '../utils/number_utils.dart';

enum SignalLevel { normal, good, great }

class OpportunityResult {
  const OpportunityResult({
    required this.score,
    required this.level,
    required this.suggestedDeposit,
    required this.reasons,
    required this.drawdownText,
    required this.vixText,
    required this.fxText,
    required this.calendarText,
  });

  final int score;
  final SignalLevel level;
  final double suggestedDeposit;
  final List<String> reasons;
  final String drawdownText;
  final String vixText;
  final String fxText;
  final String calendarText;

  String get title => switch (level) {
    SignalLevel.great => 'Muy buen momento',
    SignalLevel.good => 'Buen momento',
    SignalLevel.normal => 'Momento normal',
  };

  String get message => switch (level) {
    SignalLevel.great => 'Las senales justifican adelantar deposito.',
    SignalLevel.good => 'Puedes meter algo extra sin forzar la mano.',
    SignalLevel.normal => 'Aporta base y conserva reserva para caidas.',
  };
}

class OpportunityEngine {
  static OpportunityResult evaluate(AppState state) {
    final market = state.market;
    final reasons = <String>[];
    var score = _drawdownScore(market.drawdown) + _vixScore(market.vix);

    if (market.drawdown >= 20) {
      reasons.add('Caida profunda: usar la reserva oportunista tiene sentido.');
    } else if (market.drawdown >= 10) {
      reasons.add('Caida suficiente para adelantar parte del ano.');
    }

    if (market.vix >= 30) {
      reasons.add('VIX alto: hay miedo real en el mercado.');
    } else if (market.vix >= 25) {
      reasons.add('VIX elevado: buen filtro para no comprar solo por impulso.');
    }

    final double fxDelta = market.usdMxnReference <= 0
        ? 0
        : (market.usdMxnReference - market.usdMxn) / market.usdMxnReference;
    if (fxDelta >= 0.05) {
      score += 15;
      reasons.add(
        'Peso fuerte contra tu referencia: ayuda a comprar global en MXN.',
      );
    } else if (fxDelta >= 0.02) {
      score += 8;
    } else if (fxDelta <= -0.06) {
      score -= 5;
    }

    if (state.remainingTarget > 0 &&
        state.requiredMonthlyRunRate > state.settings.monthlyDeductibleCap) {
      score += 10;
      reasons.add('Vas atrasado contra el ano: conviene recuperar ritmo.');
    }

    score = score.clamp(0, 100);
    final level = score >= 65
        ? SignalLevel.great
        : score >= 40
        ? SignalLevel.good
        : SignalLevel.normal;

    if (reasons.isEmpty) {
      reasons.add(
        'Las senales no justifican acelerar; mantener aportacion base.',
      );
    }

    return OpportunityResult(
      score: score,
      level: level,
      suggestedDeposit: _suggestedDeposit(state, level),
      reasons: reasons,
      drawdownText: _drawdownText(market.drawdown),
      vixText: _vixText(market.vix),
      fxText: _fxText(fxDelta),
      calendarText: _calendarText(state),
    );
  }

  static int _drawdownScore(double value) {
    if (value >= 30) return 55;
    if (value >= 20) return 45;
    if (value >= 15) return 34;
    if (value >= 10) return 25;
    if (value >= 7) return 15;
    if (value >= 5) return 8;
    return 0;
  }

  static int _vixScore(double value) {
    if (value >= 40) return 28;
    if (value >= 30) return 22;
    if (value >= 25) return 14;
    if (value >= 20) return 6;
    return 0;
  }

  static double _suggestedDeposit(AppState state, SignalLevel level) {
    final remaining = state.remainingTarget;
    if (remaining <= 0) return 0;

    final base = state.requiredMonthlyRunRate;
    final cap = state.settings.monthlyDeductibleCap;
    final marketBoost = switch (level) {
      SignalLevel.great => cap * 1.6,
      SignalLevel.good => cap,
      SignalLevel.normal => min(base, cap),
    };

    return min(remaining, roundToHundreds(max(base, marketBoost)));
  }

  static String _drawdownText(double value) {
    if (value >= 20) return 'muy atractiva';
    if (value >= 10) return 'atractiva';
    if (value >= 7) return 'ligera ventaja';
    return 'normal';
  }

  static String _vixText(double value) {
    if (value >= 30) return 'miedo alto';
    if (value >= 25) return 'miedo util';
    if (value >= 20) return 'nervioso';
    return 'calmado';
  }

  static String _fxText(double delta) {
    if (delta >= 0.05) return 'peso fuerte';
    if (delta >= 0.02) return 'algo favorable';
    if (delta <= -0.06) return 'peso debil';
    return 'neutral';
  }

  static String _calendarText(AppState state) {
    if (state.remainingTarget <= 0) return 'completo';
    if (state.requiredMonthlyRunRate > state.settings.monthlyDeductibleCap) {
      return 'atrasado';
    }
    return 'a tiempo';
  }
}
