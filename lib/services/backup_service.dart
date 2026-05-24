import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

import '../models/app_state.dart';

class BackupService {
  Future<String?> exportState(AppState state) async {
    final bytes = Uint8List.fromList(utf8.encode(_encode(state)));
    return FilePicker.saveFile(
      dialogTitle: 'Exportar respaldo de Fintual Alert',
      fileName: _fileName(),
      type: FileType.custom,
      allowedExtensions: ['json'],
      bytes: bytes,
    );
  }

  Future<AppState?> importState() async {
    final result = await FilePicker.pickFiles(
      dialogTitle: 'Importar respaldo de Fintual Alert',
      type: FileType.custom,
      allowedExtensions: ['json'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return null;

    final file = result.files.single;
    final bytes = file.bytes ?? await File(file.path!).readAsBytes();
    final json = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
    if (json['format'] != 'fintual_alert_backup') {
      throw const FormatException('El archivo no es un respaldo valido.');
    }
    return AppState.fromJson(json['state'] as Map<String, dynamic>);
  }

  String _encode(AppState state) {
    return const JsonEncoder.withIndent('  ').convert({
      'format': 'fintual_alert_backup',
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'state': state.toJson(),
    });
  }

  String _fileName() {
    final now = DateTime.now();
    final date =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    return 'fintual-alert-backup-$date.json';
  }
}
