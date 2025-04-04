// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dashboard/theme/theme.dart';
import 'package:dashboard/widgets/settings/settings.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dashboard/manager/manager.dart';
import 'package:dashboard/updater/updater.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  BackupRestoreManager? _backupRestoreManager;
  final TextEditingController _apiUrlController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedApiUrl =
        prefs.getString('apiUrl') ?? 'http://192.168.1.100:3000';

    setState(() {
      _apiUrlController.text = savedApiUrl;
      _backupRestoreManager = BackupRestoreManager(
        context: context,
        apiUrl: savedApiUrl,
      );
      _isLoading = false;
    });
  }

  Future<void> _saveApiUrl() async {
    final prefs = await SharedPreferences.getInstance();
    String url = _apiUrlController.text.trim();

    // URL formatting
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'http://$url';
    }
    if (!url.contains(':3000')) {
      url =
          url.endsWith('/')
              ? '${url.substring(0, url.length - 1)}:3000'
              : '$url:3000';
    }

    await prefs.setString('apiUrl', url);

    setState(() {
      _backupRestoreManager = BackupRestoreManager(
        context: context,
        apiUrl: url,
      );
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Text('Server URL updated to $url'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(Theme.of(context).primaryColor),
          ),
        ),
      );
    }

    final theme = Theme.of(context);
    final themeModel = Provider.of<ThemeModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Configurações',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SettingsSection(
            title: 'Aparencia',
            icon: Icons.palette_outlined,
            children: [ThemeSettings(themeModel: themeModel)],
          ),
          const SizedBox(height: 16),
          _SettingsSection(
            title: 'Gerenciamento de Dados',
            icon: Icons.cloud_sync_outlined,
            children: [
              _SettingsTile(
                title: 'Criar Backup',
                subtitle: 'Salve os dados do sistema',
                icon: Icons.backup_outlined,
                onTap: _backupRestoreManager!.backup,
              ),
              _SettingsTile(
                title: 'Restaurar Backup',
                subtitle: 'Restaurar os dados do sistema',
                icon: Icons.restore_outlined,
                onTap: _backupRestoreManager!.restore,
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (!foundation.kIsWeb)
            _SettingsSection(
              title: 'Atualizações',
              icon: Icons.system_update_outlined,
              children: [
                _SettingsTile(
                  title: 'Verificar Atualizações',
                  subtitle: 'Verifique se há atualizações',
                  icon: Icons.update_outlined,
                  onTap: () => Updater.checkForUpdates(context),
                ),
              ],
            ),
          const SizedBox(height: 16),
          _SettingsSection(
            title: 'Configurações do Servidor',
            icon: Icons.dns_outlined,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _apiUrlController,
                  decoration: InputDecoration(
                    labelText: 'IP do Servidor',
                    hintText: 'Digite o IP do servidor',
                    prefixIcon: Icon(Icons.link_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: FilledButton.icon(
                  icon: Icon(Icons.save_outlined, size: 20),
                  label: Text('Salvar'),
                  style: FilledButton.styleFrom(
                    minimumSize: Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _saveApiUrl,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SettingsSection(
            title: 'Sobre',
            icon: Icons.info_outline,
            children: [
              _SettingsTile(
                title: 'Licenças',
                subtitle:
                    'Softwares de terceiros usados na construção da plataforma',
                icon: Icons.description_outlined,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => LicensePage(
                            applicationName: "Dashboard ShopTem",
                            applicationIcon: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Icon(
                                Icons.shopping_cart_outlined,
                                size: 40,
                              ),
                            ),
                          ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(icon, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        Card(
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: Theme.of(context).dividerColor.withOpacity(0.1),
            ),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.title,
    this.subtitle,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Theme.of(context).colorScheme.primary),
      ),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing:
          onTap != null
              ? Icon(
                Icons.chevron_right_outlined,
                color: Theme.of(context).colorScheme.outline,
              )
              : null,
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
