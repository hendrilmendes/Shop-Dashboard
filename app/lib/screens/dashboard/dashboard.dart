import 'package:dashboard/screens/category/category.dart';
import 'package:dashboard/screens/dashboard/desktop/desktop.dart';
import 'package:dashboard/screens/orders/orders.dart';
import 'package:dashboard/screens/products/add.dart';
import 'package:dashboard/screens/products/list.dart';
import 'package:dashboard/screens/settings/settings.dart';
import 'package:dashboard/widgets/home/card.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return _buildSmallScreenLayout(context);
        } else {
          return _buildLargeScreenLayout(context);
        }
      },
    );
  }

  Widget _buildSmallScreenLayout(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12.0,
          mainAxisSpacing: 12.0,
          children: [
            DashboardCard(
              title: 'Cadastro de Produtos',
              description: 'Cadastre novos produtos',
              icon: Icons.add_shopping_cart,
              color: Colors.green,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const AddProductScreen()),
              ),
            ),
            DashboardCard(
              title: 'Produtos Cadastrados',
              description: 'Gerencie seus produtos.',
              icon: Icons.list_alt,
              color: Colors.orange,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProductsPage()),
              ),
            ),
            DashboardCard(
              title: 'Pedidos',
              description: 'Verifique os pedidos realizados',
              icon: Icons.shopping_basket,
              color: Colors.blue,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const OrdersScreen()),
              ),
            ),
            DashboardCard(
              title: 'Categorias',
              description: 'Gerencie as categorias de produtos',
              icon: Icons.category,
              color: Colors.amber,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ManageCategoriesScreen()),
              ),
            ),
            DashboardCard(
              title: 'Configurações',
              description: 'Ajuste as preferências do sistema',
              icon: Icons.settings,
              color: Colors.purple,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLargeScreenLayout(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          DashboardSidebar(
            onItemSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: dashboardPages,
            ),
          ),
        ],
      ),
    );
  }
}
