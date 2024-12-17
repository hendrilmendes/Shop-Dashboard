import 'dart:convert';
import 'package:dashboard/api/api.dart';
import 'package:dashboard/models/products.dart';
import 'package:dashboard/screens/products/desktop/list.dart';
import 'package:dashboard/screens/products/edit.dart';
import 'package:dashboard/widgets/products/card.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ProductsPageState createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage>
    with SingleTickerProviderStateMixin {
  List<Product> products = [];
  List<Product> filteredProducts = [];
  final TextEditingController _searchController = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProducts();
    _searchController.addListener(() {
      _filterProducts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void fetchProducts() async {
    final url = '$apiUrl/api/products';
    try {
      if (kDebugMode) {
        print('Fetching products from: $url');
      }
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> productList = json.decode(response.body);
        if (kDebugMode) {
          print('Product List JSON: $productList'); // Log do JSON bruto
        }
        setState(() {
          products = productList.map((json) {
            final product = Product.fromJson(json);
            if (kDebugMode) {
              print('Product object: $product'); // Log do objeto Produto
            }
            return product;
          }).toList();
          filteredProducts = products;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching products: $e');
      }
      setState(() {
        isLoading = false;
      });
    }
  }

  void _filterProducts() {
    final searchTerm = _searchController.text.toLowerCase();
    setState(() {
      filteredProducts = products
          .where((product) => product.title.toLowerCase().contains(searchTerm))
          .toList();
    });
  }

  void _navigateToEditScreen(String productId) async {
    final shouldReload = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProductScreen(productId: productId),
      ),
    );

    if (shouldReload == true) {
      fetchProducts(); // Atualiza a lista de produtos se um produto foi excluído
    }
  }

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
        title: Text(
          'Produtos Cadastrados',
          style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: SizedBox(
                width: 600,
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Pesquisar produtos...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
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
          isLoading
              ? const Expanded(
                  child: Center(child: CircularProgressIndicator.adaptive()),
                )
              : Expanded(
                  child: filteredProducts.isEmpty
                      ? const Center(child: Text('Nenhum produto encontrado'))
                      : GridView.builder(
                          padding: const EdgeInsets.all(8),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount:
                                MediaQuery.of(context).size.width > 600 ? 4 : 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 0.75,
                          ),
                          itemCount: filteredProducts.length,
                          itemBuilder: (context, index) {
                            final product = filteredProducts[index];
                            return GestureDetector(
                              onTap: () => _navigateToEditScreen(product.id),
                              child: Hero(
                                tag: 'product_${product.id}',
                                child: ProductCard(
                                  product: product,
                                  onEdit: () =>
                                      _navigateToEditScreen(product.id),
                                ),
                              ),
                            );
                          },
                        ),
                ),
        ],
      ),
    );
  }

  Widget _buildLargeScreenLayout(BuildContext context) {
    return ProductsPageDesktop(
      filteredProducts: filteredProducts,
      searchController: _searchController,
      isLoading: isLoading,
      navigateToEditScreen: _navigateToEditScreen,
    );
  }
}
