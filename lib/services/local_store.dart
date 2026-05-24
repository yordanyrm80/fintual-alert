import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../models/app_state.dart';
import '../models/deposit.dart';
import '../models/market_data.dart';
import '../models/settings_data.dart';

class LocalStore {
  Database? _db;

  Future<AppState> load() async {
    final db = await _database();
    return _readState(db);
  }

  Future<void> save(AppState state) async {
    await _writeState(await _database(), state);
  }

  Future<Database> _database() async {
    if (_db != null) return _db!;
    _initFactory();
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}${Platform.pathSeparator}fintual_alert.db';
    _db = await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(version: 1, onCreate: _createSchema),
    );
    return _db!;
  }

  void _initFactory() {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  }

  Future<void> _createSchema(Database db, int version) async {
    await db.execute('''
      CREATE TABLE settings (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        annual_target REAL NOT NULL,
        monthly_deductible_cap REAL NOT NULL,
        notifications_enabled INTEGER NOT NULL,
        last_alert_key TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE market (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        drawdown REAL NOT NULL,
        vix REAL NOT NULL,
        usd_mxn REAL NOT NULL,
        usd_mxn_reference REAL NOT NULL,
        notes TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE deposits (
        id TEXT PRIMARY KEY,
        date TEXT NOT NULL,
        amount REAL NOT NULL,
        note TEXT NOT NULL
      )
    ''');
  }

  Future<AppState> _readState(Database db) async {
    final settingsRows = await db.query('settings', limit: 1);
    final marketRows = await db.query('market', limit: 1);
    final depositRows = await db.query('deposits', orderBy: 'date DESC');
    if (settingsRows.isEmpty || marketRows.isEmpty) {
      final state = AppState.defaults();
      await _writeState(db, state);
      return state;
    }
    return AppState(
      settings: _settingsFromRow(settingsRows.single),
      market: _marketFromRow(marketRows.single),
      deposits: depositRows.map(_depositFromRow).toList(),
      lastAlertKey: settingsRows.single['last_alert_key'] as String? ?? '',
    );
  }

  Future<void> _writeState(Database db, AppState state) async {
    await db.transaction((txn) async {
      await txn.insert(
        'settings',
        _settingsRow(state.settings, state.lastAlertKey),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      await txn.insert(
        'market',
        _marketRow(state.market),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      await txn.delete('deposits');
      for (final deposit in state.deposits) {
        await txn.insert('deposits', _depositRow(deposit));
      }
    });
  }

  Map<String, Object?> _settingsRow(
    SettingsData settings,
    String lastAlertKey,
  ) => {
    'id': 1,
    'annual_target': settings.annualTarget,
    'monthly_deductible_cap': settings.monthlyDeductibleCap,
    'notifications_enabled': settings.notificationsEnabled ? 1 : 0,
    'last_alert_key': lastAlertKey,
  };

  SettingsData _settingsFromRow(Map<String, Object?> row) => SettingsData(
    annualTarget: (row['annual_target'] as num).toDouble(),
    monthlyDeductibleCap: (row['monthly_deductible_cap'] as num).toDouble(),
    notificationsEnabled: row['notifications_enabled'] == 1,
  );

  Map<String, Object?> _marketRow(MarketData market) => {
    'id': 1,
    'drawdown': market.drawdown,
    'vix': market.vix,
    'usd_mxn': market.usdMxn,
    'usd_mxn_reference': market.usdMxnReference,
    'notes': market.notes,
    'updated_at': market.updatedAt.toIso8601String(),
  };

  MarketData _marketFromRow(Map<String, Object?> row) => MarketData(
    drawdown: (row['drawdown'] as num).toDouble(),
    vix: (row['vix'] as num).toDouble(),
    usdMxn: (row['usd_mxn'] as num).toDouble(),
    usdMxnReference: (row['usd_mxn_reference'] as num).toDouble(),
    notes: row['notes'] as String? ?? '',
    updatedAt:
        DateTime.tryParse(row['updated_at'] as String? ?? '') ?? DateTime.now(),
  );

  Map<String, Object?> _depositRow(Deposit deposit) => {
    'id': deposit.id,
    'date': deposit.date.toIso8601String(),
    'amount': deposit.amount,
    'note': deposit.note,
  };

  Deposit _depositFromRow(Map<String, Object?> row) => Deposit(
    id: row['id'] as String,
    date: DateTime.tryParse(row['date'] as String? ?? '') ?? DateTime.now(),
    amount: (row['amount'] as num).toDouble(),
    note: row['note'] as String? ?? '',
  );
}
