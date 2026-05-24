import 'package:flutter/material.dart';

import '../models/app_state.dart';
import '../models/deposit.dart';
import '../models/market_data.dart';
import '../models/settings_data.dart';
import '../services/alert_service.dart';
import '../services/local_store.dart';
import '../services/opportunity_engine.dart';
import '../widgets/deposit_dialog.dart';
import '../widgets/deposits_panel.dart';
import '../widgets/market_form.dart';
import '../widgets/settings_form.dart';
import '../widgets/signals_panel.dart';
import '../widgets/status_panel.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.store,
    required this.alerts,
    required this.initialState,
  });

  final LocalStore store;
  final AlertService alerts;
  final AppState initialState;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late AppState _state;

  OpportunityResult get _result => OpportunityEngine.evaluate(_state);

  @override
  void initState() {
    super.initState();
    _state = widget.initialState;
  }

  Future<void> _save({bool checkAlert = true}) async {
    await widget.store.save(_state);
    if (!mounted || !checkAlert) return;

    final result = _result;
    if (!_state.settings.notificationsEnabled ||
        result.level != SignalLevel.great) {
      return;
    }

    final key =
        '${DateTime.now().year}-${result.score}-${_state.market.updatedAt.millisecondsSinceEpoch}';
    if (_state.lastAlertKey == key) return;

    _state = _state.copyWith(lastAlertKey: key);
    await widget.store.save(_state);
    await widget.alerts.showOpportunity(result);
  }

  Future<void> _updateSettings(SettingsData settings) async {
    setState(() => _state = _state.copyWith(settings: settings));
    await _save(checkAlert: false);
  }

  Future<void> _updateMarket(MarketData market) async {
    setState(() => _state = _state.copyWith(market: market));
    await _save();
  }

  Future<void> _addDeposit(Deposit deposit) async {
    final deposits = [..._state.deposits, deposit]
      ..sort((a, b) => b.date.compareTo(a.date));
    setState(() => _state = _state.copyWith(deposits: deposits));
    await _save(checkAlert: false);
  }

  Future<void> _deleteDeposit(String id) async {
    final deposits = _state.deposits.where((item) => item.id != id).toList();
    setState(() => _state = _state.copyWith(deposits: deposits));
    await _save(checkAlert: false);
  }

  Future<void> _openDepositDialog() async {
    final deposit = await showDialog<Deposit>(
      context: context,
      builder: (context) => DepositDialog(),
    );
    if (deposit != null) await _addDeposit(deposit);
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 960;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fintual Alert'),
        actions: [
          IconButton(
            tooltip: 'Agregar deposito',
            onPressed: _openDepositDialog,
            icon: const Icon(Icons.add_card_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: isWide ? _wideLayout() : _narrowLayout(),
            ),
          ),
        ),
      ),
      floatingActionButton: isWide
          ? null
          : FloatingActionButton.extended(
              onPressed: _openDepositDialog,
              icon: const Icon(Icons.add),
              label: const Text('Deposito'),
            ),
    );
  }

  Widget _wideLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 5, child: _mainColumn()),
        const SizedBox(width: 16),
        Expanded(flex: 4, child: _sideColumn()),
      ],
    );
  }

  Widget _narrowLayout() {
    return Column(
      children: [_mainColumn(), const SizedBox(height: 16), _sideColumn()],
    );
  }

  Widget _mainColumn() {
    return Column(
      children: [
        StatusPanel(
          state: _state,
          result: _result,
          onAddDeposit: _openDepositDialog,
        ),
        const SizedBox(height: 16),
        SignalsPanel(state: _state, result: _result),
      ],
    );
  }

  Widget _sideColumn() {
    return Column(
      children: [
        MarketForm(market: _state.market, onChanged: _updateMarket),
        const SizedBox(height: 16),
        SettingsForm(
          settings: _state.settings,
          onChanged: _updateSettings,
          onTestAlert: () => widget.alerts.showOpportunity(_result),
        ),
        const SizedBox(height: 16),
        DepositsPanel(deposits: _state.deposits, onDelete: _deleteDeposit),
      ],
    );
  }
}
