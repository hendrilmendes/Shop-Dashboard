import 'package:flutter/material.dart';
import 'package:dashboard/screens/home/home.dart';
import 'package:dashboard/screens/category/category.dart';
import 'package:dashboard/screens/orders/orders.dart';
import 'package:dashboard/screens/products/add.dart';
import 'package:dashboard/screens/products/list.dart';
import 'package:dashboard/screens/settings/settings.dart';

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

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  void _onItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
                  ),
                )
              else
                const SizedBox.shrink(),
              Expanded(
                child: dashboardPages[_selectedIndex],
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
                ),
        );
      },
    );
  }
}

class DashboardDrawer extends StatelessWidget {
  final Function(int) onItemSelected;

  const DashboardDrawer({super.key, required this.onItemSelected});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.blueGrey.shade900,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blueGrey.shade800),
              child: const Text(
                'Shop Dashboard',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            _buildDrawerItem(
              context,
              'Dashboard',
              Icons.dashboard,
              0,
            ),
            _buildDrawerItem(
              context,
              'Cadastro de Produtos',
              Icons.add_shopping_cart,
              1,
            ),
            _buildDrawerItem(
              context,
              'Produtos Cadastrados',
              Icons.list_alt,
              2,
            ),
            _buildDrawerItem(
              context,
              'Pedidos',
              Icons.shopping_basket,
              3,
            ),
            _buildDrawerItem(
              context,
              'Categorias',
              Icons.category,
              4,
            ),
            _buildDrawerItem(
              context,
              'Configurações',
              Icons.settings,
              5,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
      BuildContext context, String title, IconData icon, int index) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
      onTap: () => onItemSelected(index),
    );
  }
}
