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
        _showSnackBar('Erro ao realizar backup. Código: ${response.statusCode}',
            Colors.red);
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
    // Selecionar arquivo
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['sqlite'],
    );

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.single;
      Uint8List? bytes;

      // Tentativa de obter bytes diretamente
      if (file.bytes != null) {
        bytes = file.bytes;
        if (kDebugMode) {
          print('Bytes carregados diretamente.');
        }
      } else if (file.path != null) {
        // Caso os bytes sejam nulos, lê do caminho do arquivo
        final localFile = File(file.path!);
        if (await localFile.exists()) {
          bytes = await localFile.readAsBytes();
          if (kDebugMode) {
            print('Bytes lidos do caminho: ${file.path}');
          }
        } else {
          if (kDebugMode) {
            print('Arquivo não encontrado no caminho: ${file.path}');
          }
        }
      }

      // Verifica se os bytes foram carregados
      if (bytes != null) {
        if (kDebugMode) {
          print(
              'Arquivo carregado com sucesso. Tamanho: ${bytes.length} bytes');
        }
        try {
          final request =
              http.MultipartRequest('POST', Uri.parse('$apiUrl/api/restore'))
                ..files.add(http.MultipartFile.fromBytes(
                  'backupFile',
                  bytes,
                  filename: file.name,
                ));

          if (kDebugMode) {
            print('Iniciando envio do arquivo...');
          }
          final response = await request.send();
          final responseBody = await response.stream.bytesToString();

          if (kDebugMode) {
            print('Resposta do servidor: ${response.statusCode}');
          }
          if (response.statusCode == 200) {
            _showSnackBar('Backup restaurado com sucesso!', Colors.green);
          } else {
            _showSnackBar(
                'Erro ao restaurar backup: ${response.statusCode}', Colors.red);
            if (kDebugMode) {
              print('Detalhes do erro: $responseBody');
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print('Erro durante o envio: $e');
          }
          _showSnackBar('Erro ao restaurar backup: $e', Colors.red);
        }
      } else {
        if (kDebugMode) {
          print('Erro: não foi possível carregar os bytes do arquivo.');
        }
        _showSnackBar('Erro ao carregar o arquivo.', Colors.red);
      }
    } else {
      if (kDebugMode) {
        print('Nenhum arquivo selecionado.');
      }
      _showSnackBar('Nenhum arquivo selecionado.', Colors.orange);
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
