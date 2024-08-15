import 'dart:io';
import 'package:dashboard/updater/updater.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:dashboard/theme/theme.dart';
import 'package:dashboard/widgets/settings/settings.dart';

class SettingsScreenDesktop extends StatefulWidget {
  const SettingsScreenDesktop({super.key});

  @override
  // ignore: library_private_types_in_public_api
  createState() => _SettingsScreenDesktopState();
}

class _SettingsScreenDesktopState extends State<SettingsScreenDesktop> {
  String appVersion = '';
  String appBuild = '';

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((packageInfo) {
      setState(() {
        appVersion = packageInfo.version;
        appBuild = packageInfo.buildNumber;
      });
    });
  }

  Future<void> _backup() async {
    try {
      final response =
          await http.get(Uri.parse('http://45.174.192.150:3000/api/backup'));
      if (response.statusCode == 200) {
        final message = response.body;
        _showSnackBar('Backup realizado com sucesso! $message', Colors.green);
      } else {
        _showSnackBar('Erro ao realizar backup', Colors.red);
      }
    } catch (error) {
      _showSnackBar('Erro ao realizar backup: $error', Colors.red);
    }
  }

  Future<void> _restore() async {
    final result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['gz']);
    if (result != null && result.files.isNotEmpty) {
      final file = File(result.files.single.path!);
      try {
        final request = http.MultipartRequest(
            'POST', Uri.parse('http://45.174.192.150:3000/api/restore'))
          ..files
              .add(await http.MultipartFile.fromPath('backupFile', file.path));
        final response = await request.send();
        if (response.statusCode == 200) {
          _showSnackBar('Backup restaurado com sucesso!', Colors.green);
        } else {
          _showSnackBar('Erro ao restaurar backup', Colors.red);
        }
      } catch (error) {
        _showSnackBar('Erro ao restaurar backup: $error', Colors.red);
      }
    } else {
      _showSnackBar(
          'Nenhum arquivo selecionado para restauração.', Colors.orange);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeModel = Provider.of<ThemeModel>(context);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Configurações',
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey[700],
                      ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: ListView(
                    children: [
                      _buildCard(
                        title: 'Personalização',
                        icon: Icons.color_lens_outlined,
                        children: [
                          ThemeSettings(themeModel: themeModel),
                        ],
                      ),
                      _buildCard(
                        title: 'Backup e Restauração',
                        icon: Icons.cloud_upload_outlined,
                        children: [
                          _buildElevatedButton(
                            text: 'Fazer Backup',
                            icon: Icons.backup_outlined,
                            onPressed: _backup,
                          ),
                          _buildElevatedButton(
                            text: 'Restaurar Backup',
                            icon: Icons.restore_outlined,
                            onPressed: _restore,
                          ),
                        ],
                      ),
                      _buildCard(
                        title: 'Informações do Sistema',
                        icon: Icons.info_outline,
                        children: [
                          _buildInfoRow(
                              'Versão', '$appVersion | Build: ($appBuild)'),
                        ],
                      ),
                      _buildCard(
                        title: 'Atualizações',
                        icon: Icons.update_outlined,
                        children: [
                          ListTile(
                            title: const Text("Verificar atualizações"),
                            onTap: () {
                              Updater.checkForUpdates(context);
                            },
                          ),
                        ],
                      ),
                      _buildCard(
                        title: 'Outros',
                        icon: Icons.library_books_outlined,
                        children: [
                          ListTile(
                            title: const Text("Licenças"),
                            subtitle: const Text(
                                "Softwares de terceiros usados na construção da plataforma"),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LicensePage(
                                    applicationName: "Dashboard",
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 28, color: Colors.blueGrey[700]),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildElevatedButton({
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(text),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(50),
          backgroundColor: Colors.blueGrey[600],
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, [String value = '']) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          if (value.isNotEmpty)
            Text(value, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
