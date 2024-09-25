import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class BackupRestoreManager {
  final BuildContext context;
  final String apiUrl;

  BackupRestoreManager({
    required this.context,
    required this.apiUrl,
  });

  Future<void> backup() async {
    try {
      final response = await http.get(Uri.parse('$apiUrl/api/backup'));
      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        await _backupForOtherPlatforms(bytes);
      } else {
        _showSnackBar('Erro ao realizar backup. Código: ${response.statusCode}', Colors.red);
      }
    } catch (error) {
      _showSnackBar('Erro ao realizar backup: $error', Colors.red);
      if (kDebugMode) {
        print('Erro ao realizar backup: $error');
      }
    }
  }

  Future<void> _backupForOtherPlatforms(Uint8List bytes) async {
    final result = await FilePicker.platform.saveFile(
      dialogTitle: 'Salvar backup',
      fileName: 'database-backup.sqlite',
    );

    if (result != null) {
      final file = File(result);
      await file.writeAsBytes(bytes);
      _showSnackBar('Backup realizado com sucesso!', Colors.green);
    } else {
      _showSnackBar('Backup não salvo', Colors.orange);
    }
  }

  Future<void> restore() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['sqlite'],
    );

    if (result != null && result.files.isNotEmpty) {
      final bytes = result.files.single.bytes;

      if (bytes != null) {
        try {
          final request = http.MultipartRequest('POST', Uri.parse('$apiUrl/api/restore'))
            ..files.add(http.MultipartFile.fromBytes(
              'backupFile',
              bytes,
              filename: 'database-backup.sqlite',
            ));

          final response = await request.send();
          final responseBody = await response.stream.bytesToString();

          if (response.statusCode == 200) {
            _showSnackBar('Backup restaurado com sucesso!', Colors.green);
          } else {
            _showSnackBar('Erro ao restaurar backup: ${response.statusCode}', Colors.red);
            if (kDebugMode) {
              print('Resposta do servidor: $responseBody');
            }
          }
        } catch (error) {
          _showSnackBar('Erro ao restaurar backup: $error', Colors.red);
        }
      } else {
        _showSnackBar('Erro ao ler o arquivo.', Colors.red);
      }
    } else {
      _showSnackBar('Nenhum arquivo selecionado para restauração.', Colors.orange);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }
}
