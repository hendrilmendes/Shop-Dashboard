import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';
import 'package:dashboard/screens/home/home.dart';
import 'package:dashboard/screens/category/category.dart';
import 'package:dashboard/screens/orders/orders.dart';
import 'package:dashboard/screens/products/add.dart';
import 'package:dashboard/screens/products/list.dart';
import 'package:dashboard/screens/settings/settings.dart';
import 'package:package_info_plus/package_info_plus.dart';

final List<Widget> dashboardPages = [
  const HomeScreen(),
  const AddProductScreen(),
  const ProductsPage(),
  const OrdersScreen(),
  const ManageCategoriesScreen(),
  const SettingsScreen(),
];

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  String appVersion = '';
  String appBuild = '';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
    
    // Configuração da animação
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.bounceInOut,
      ),
    );
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadPackageInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        appVersion = packageInfo.version;
        appBuild = packageInfo.buildNumber;
      });
    } catch (e) {
      debugPrint('Erro ao obter informações do pacote: $e');
    }
  }

  void _onItemSelected(int index) {
    if (index != _selectedIndex) {
      setState(() {
        _selectedIndex = index;
      });
      
      // Reinicia a animação ao trocar de tela
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isLargeScreen = constraints.maxWidth >= 1024;

        return Scaffold(
          appBar: isLargeScreen ? null : AppBar(),
          body: Row(
            children: [
              if (isLargeScreen)
                SizedBox(
                  width: 250,
                  child: DashboardDrawer(
                    onItemSelected: _onItemSelected,
                    appVersion: appVersion,
                    appBuild: appBuild,
                    selectedIndex: _selectedIndex,
                  ),
                )
              else
                const SizedBox.shrink(),
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.2, 0.0),
                      end: Offset.zero,
                    ).animate(_animationController),
                    child: dashboardPages[_selectedIndex],
                  ),
                ),
              ),
            ],
          ),
          drawer: isLargeScreen
              ? null
              : DashboardDrawer(
                  onItemSelected: (index) {
                    _onItemSelected(index);
                    Navigator.of(context).pop();
                  },
                  appVersion: appVersion,
                  appBuild: appBuild,
                  selectedIndex: _selectedIndex,
                ),
        );
      },
    );
  }
}

class DashboardDrawer extends StatelessWidget {
  final Function(int) onItemSelected;
  final String appVersion;
  final String appBuild;
  final int selectedIndex;

  const DashboardDrawer({
    super.key,
    required this.onItemSelected,
    required this.appVersion,
    required this.appBuild,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  child: Icon(Icons.person, size: 40),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Bem-vindo!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text('admin@shoptem.com', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  context,
                  'Dashboard',
                  Icons.dashboard_outlined,
                  0,
                ),
                _buildDrawerItem(
                  context,
                  'Cadastro de Produtos',
                  Icons.add_circle_outline,
                  1,
                ),
                _buildDrawerItem(
                  context,
                  'Produtos Cadastrados',
                  Icons.list,
                  2,
                ),
                _buildDrawerItem(
                  context,
                  'Pedidos',
                  Icons.shopping_cart_outlined,
                  3,
                ),
                _buildDrawerItem(
                  context,
                  'Categorias',
                  Icons.category_outlined,
                  4,
                ),
                _buildDrawerItem(
                  context,
                  'Configurações',
                  Icons.settings_outlined,
                  5,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 12.0,
              horizontal: 16.0,
            ),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 1.0,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Versão e Build
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Theme.of(context).hintColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Versão: $appVersion (Build $appBuild)',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Informações da Plataforma
                Row(
                  children: [
                    Icon(
                      Icons.devices,
                      size: 16,
                      color: Theme.of(context).hintColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getPlatformInfo(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                Row(
                  children: [
                    Icon(
                      Icons.people,
                      size: 16,
                      color: Theme.of(context).hintColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Desenvolvedor: Hendril Mendes',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context,
    String title,
    IconData icon,
    int index,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      selected: index == selectedIndex,
      // ignore: deprecated_member_use
      selectedTileColor: Theme.of(context).primaryColor.withOpacity(0.1),
      onTap: () => onItemSelected(index),
    );
  }

  String _getPlatformInfo() {
    if (foundation.kIsWeb) {
      return 'Plataforma: Web';
    } else {
      return 'Sistema: ${foundation.defaultTargetPlatform.toString().split('.')[1]}';
    }
  }
}