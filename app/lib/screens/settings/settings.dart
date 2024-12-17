import 'package:dashboard/manager/manager.dart';
import 'package:dashboard/updater/updater.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:dashboard/theme/theme.dart';
import 'package:dashboard/widgets/settings/settings.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String appVersion = '';
  String appBuild = '';
  BackupRestoreManager? _backupRestoreManager;
  final TextEditingController _apiUrlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((packageInfo) {
      setState(() {
        appVersion = packageInfo.version;
        appBuild = packageInfo.buildNumber;
      });
    });

    _loadApiUrl();
  }

  Future<void> _loadApiUrl() async {
    final prefs = await SharedPreferences.getInstance();
    String savedApiUrl =
        prefs.getString('apiUrl') ?? 'http://192.168.1.100:3000';
    _apiUrlController.text = savedApiUrl;

    setState(() {
      _backupRestoreManager = BackupRestoreManager(
        context: context,
        apiUrl: savedApiUrl,
      );
    });
  }

  void _saveApiUrl() async {
    final prefs = await SharedPreferences.getInstance();
    String url = _apiUrlController.text;

    // Adiciona o protocolo caso não esteja presente
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'http://$url';
    }

    // Verifica se a porta 3000 está presente, caso contrário, adiciona
    if (!url.contains(':3000')) {
      url = url.endsWith('/')
          ? '${url.substring(0, url.length - 1)}:3000'
          : '$url:3000';
    }

    // Salva a URL no SharedPreferences
    await prefs.setString('apiUrl', url);

    // Atualiza o estado com o novo valor
    setState(() {
      _backupRestoreManager = BackupRestoreManager(
        context: context,
        apiUrl: url,
      );
    });

    // Feedback ao usuário
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('URL da API salva: $url')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_backupRestoreManager == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Configurações')),
        body: Center(child: CircularProgressIndicator.adaptive()),
      );
    }
    final themeModel = Provider.of<ThemeModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Configurações',
          style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                        onPressed: _backupRestoreManager!.backup,
                      ),
                      _buildElevatedButton(
                        text: 'Restaurar Backup',
                        icon: Icons.restore_outlined,
                        onPressed: _backupRestoreManager!.restore,
                      ),
                    ],
                  ),
                  _buildCard(
                    title: 'Informações do Sistema',
                    icon: Icons.info_outline,
                    children: [
                      _buildInfoRow(
                          'Versão', '$appVersion | Build: ($appBuild)'),
                      _buildInfoRow('Sistema Operacional', _getPlatformName()),
                    ],
                  ),
                  if (!foundation.kIsWeb)
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
                  // Adicionando a opção para mudar o IP do servidor
                  _buildCard(
                    title: 'Configuração do Servidor',
                    icon: Icons.network_check,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: TextField(
                          controller: _apiUrlController,
                          decoration: InputDecoration(
                            labelText: 'Endereço do Servidor',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      _buildElevatedButton(
                        text: 'Salvar Configuração',
                        icon: Icons.save_outlined,
                        onPressed: _saveApiUrl,
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
                                applicationName: "Shop Dashboard",
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
    );
  }

  String _getPlatformName() {
    if (foundation.kIsWeb) {
      return 'Web';
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return 'iOS';
      case TargetPlatform.android:
        return 'Android';
      case TargetPlatform.linux:
        return 'Linux';
      case TargetPlatform.macOS:
        return 'macOS';
      case TargetPlatform.windows:
        return 'Windows';
      default:
        return 'Desconhecido';
    }
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
                Icon(icon, size: 28),
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
        icon: Icon(
          icon,
          color: Colors.blue,
        ),
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
