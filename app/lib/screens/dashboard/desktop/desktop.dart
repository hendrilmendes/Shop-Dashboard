import 'package:flutter/material.dart';
import 'package:dashboard/screens/home/desktop_home.dart';
import 'package:dashboard/screens/category/category.dart';
import 'package:dashboard/screens/orders/orders.dart';
import 'package:dashboard/screens/products/add.dart';
import 'package:dashboard/screens/products/list.dart';
import 'package:dashboard/screens/settings/settings.dart';

final List<Widget> dashboardPages = [
  const DesktopHomeScreen(),
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
    return Scaffold(
      body: Row(
        children: [
          DashboardSidebar(onItemSelected: _onItemSelected),
          Expanded(
            child: dashboardPages[_selectedIndex],
          ),
        ],
      ),
    );
  }
}

class DashboardSidebar extends StatelessWidget {
  final Function(int) onItemSelected;

  const DashboardSidebar({super.key, required this.onItemSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: Colors.blueGrey.shade900,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
            child: Text(
              'Dashboard',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: Colors.white),
            ),
          ),
          const Divider(color: Colors.white70),
          _buildSidebarItem(
              context, 'Cadastro de Produtos', Icons.add_shopping_cart, 1),
          _buildSidebarItem(context, 'Produtos Cadastrados', Icons.list_alt, 2),
          _buildSidebarItem(context, 'Pedidos', Icons.shopping_basket, 3),
          _buildSidebarItem(context, 'Categorias', Icons.category, 4),
          _buildSidebarItem(context, 'Configurações', Icons.settings, 5),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(
      BuildContext context, String title, IconData icon, int index) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      onTap: () => onItemSelected(index),
    );
  }
}
