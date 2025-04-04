import 'dart:convert';
import 'package:dashboard/api/api.dart';
import 'package:dashboard/models/products.dart';
import 'package:dashboard/screens/products/edit.dart';
import 'package:dashboard/widgets/products/card.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final TextEditingController _searchController = TextEditingController();
  late List<Product> _products = [];
  late List<Product> _filteredProducts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    _searchController.addListener(_filterProducts);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchProducts() async {
    try {
      final response = await http.get(Uri.parse('$apiUrl/api/products'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _products = data.map((json) => Product.fromJson(json)).toList();
          _filteredProducts = _products;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      if (kDebugMode) print('Error fetching products: $e');
      setState(() => _isLoading = false);
    }
  }

  void _filterProducts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProducts =
          _products
              .where(
                (product) =>
                    product.title.toLowerCase().contains(query) ||
                    product.description.toLowerCase().contains(query),
              )
              .toList();
    });
  }

  Future<void> _navigateToEditScreen(String productId) async {
    final product = _products.firstWhere((p) => p.id == productId);

    final shouldReload = await Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => EditProductScreen(
              productId: productId,
              initialProductData: product.toJson(),
            ),
      ),
    );

    if (shouldReload == true) {
      await _fetchProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Produtos Cadastrados',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Pesquisar produtos...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon:
                        _searchController.text.isNotEmpty
                            ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _filterProducts();
                              },
                            )
                            : null,
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16.0),
                  ),
                ),
              ),
            ),
          ),
          Expanded(child: _buildProductGrid()),
        ],
      ),
    );
  }

  Widget _buildProductGrid() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    if (_filteredProducts.isEmpty) {
      return const Center(
        child: Text(
          'Nenhum produto encontrado',
          style: TextStyle(fontSize: 18, color: Colors.blueGrey),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth ~/ 300;
        return GridView.builder(
          padding: const EdgeInsets.all(16.0),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount > 0 ? crossAxisCount : 1,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.75,
          ),
          itemCount: _filteredProducts.length,
          itemBuilder: (context, index) {
            final product = _filteredProducts[index];
            return GestureDetector(
              onTap: () => _navigateToEditScreen(product.id),
              child: Hero(
                tag: 'product_${product.id}',
                child: ProductCard(
                  product: product,
                  onEdit: () => _navigateToEditScreen(product.id),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
