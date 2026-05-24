import 'package:flutter/material.dart';

import '../models/app_state.dart';
import '../models/deposit.dart';
import '../models/market_data.dart';
import '../models/settings_data.dart';
import '../screens/plan_page.dart';
import '../services/alert_service.dart';
import '../services/backup_service.dart';
import '../services/local_store.dart';
import '../services/market_data_service.dart';
import '../services/opportunity_engine.dart';
import '../widgets/dashboard_summary.dart';
import '../widgets/deposit_dialog.dart';
import '../widgets/deposits_panel.dart';
import '../widgets/formula_panel.dart';
import '../widgets/market_form.dart';
import '../widgets/market_snapshot.dart';
import '../widgets/signals_panel.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.store,
    required this.alerts,
    required this.backup,
    required this.marketData,
    required this.initialState,
  });

  final LocalStore store;
  final AlertService alerts;
  final BackupService backup;
  final MarketDataService marketData;
  final AppState initialState;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late AppState _state;
  bool _refreshingMarket = false;

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

  Future<void> _refreshMarket() async {
    setState(() => _refreshingMarket = true);
    try {
      final market = await widget.marketData.fetch();
      await _updateMarket(market);
      if (mounted) _showMessage('Mercado actualizado en vivo.');
    } on MarketDataException catch (error) {
      if (mounted) _showMessage(error.message);
    } catch (_) {
      if (mounted) _showMessage('No se pudo actualizar el mercado.');
    } finally {
      if (mounted) setState(() => _refreshingMarket = false);
    }
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

  Future<void> _openMarketDialog() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => _MarketSheet(
        market: _state.market,
        onChanged: (market) async {
          Navigator.of(context).pop();
          await _updateMarket(market);
        },
      ),
    );
  }

  Future<void> _openPlanPage() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => PlanPage(
          settings: _state.settings,
          onChanged: _updateSettings,
          onTestAlert: () => widget.alerts.showOpportunity(_result),
        ),
      ),
    );
  }

  Future<void> _exportBackup() async {
    final path = await widget.backup.exportState(_state);
    if (!mounted || path == null) return;
    _showMessage('Respaldo exportado.');
  }

  Future<void> _importBackup() async {
    try {
      final imported = await widget.backup.importState();
      if (imported == null) return;
      setState(() => _state = imported);
      await _save(checkAlert: false);
      if (mounted) _showMessage('Respaldo importado.');
    } on FormatException catch (error) {
      if (mounted) _showMessage(error.message);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 960;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fintual Alert'),
        actions: [
          IconButton(
            tooltip: 'Plan',
            onPressed: _openPlanPage,
            icon: const Icon(Icons.settings_outlined),
          ),
          IconButton(
            tooltip: 'Importar respaldo',
            onPressed: _importBackup,
            icon: const Icon(Icons.upload_file_outlined),
          ),
          IconButton(
            tooltip: 'Exportar respaldo',
            onPressed: _exportBackup,
            icon: const Icon(Icons.download_outlined),
          ),
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
        DashboardSummary(
          state: _state,
          result: _result,
          onAddDeposit: _openDepositDialog,
          onUpdateMarket: _refreshMarket,
          refreshingMarket: _refreshingMarket,
        ),
        const SizedBox(height: 16),
        SignalsPanel(state: _state, result: _result),
        const SizedBox(height: 16),
        const FormulaPanel(),
      ],
    );
  }

  Widget _sideColumn() {
    return Column(
      children: [
        MarketSnapshot(
          market: _state.market,
          onEdit: _openMarketDialog,
          onRefresh: _refreshMarket,
          refreshing: _refreshingMarket,
        ),
        const SizedBox(height: 16),
        DepositsPanel(deposits: _state.deposits, onDelete: _deleteDeposit),
      ],
    );
  }
}

class _MarketSheet extends StatelessWidget {
  const _MarketSheet({required this.market, required this.onChanged});

  final MarketData market;
  final ValueChanged<MarketData> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: MarketForm(market: market, onChanged: onChanged),
        ),
      ),
    );
  }
}
