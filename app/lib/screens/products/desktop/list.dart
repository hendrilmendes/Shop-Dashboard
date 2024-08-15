// products_page_desktop.dart
import 'package:flutter/material.dart';
import 'package:dashboard/models/products.dart';
import 'package:dashboard/widgets/products/card.dart';

class ProductsPageDesktop extends StatelessWidget {
  final List<Product> filteredProducts;
  final TextEditingController searchController;
  final bool isLoading;
  final Function(String) navigateToEditScreen;

  const ProductsPageDesktop({
    super.key,
    required this.filteredProducts,
    required this.searchController,
    required this.isLoading,
    required this.navigateToEditScreen,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produtos Cadastrados'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: SizedBox(
                width: 600,
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Pesquisar produtos...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              searchController.clear();
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
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredProducts.isEmpty
                    ? const Center(
                        child: Text(
                          'Nenhum produto encontrado',
                          style:
                              TextStyle(fontSize: 18, color: Colors.blueGrey),
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(16.0),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: filteredProducts.length,
                        itemBuilder: (context, index) {
                          final product = filteredProducts[index];
                          return GestureDetector(
                            onTap: () => navigateToEditScreen(product.id),
                            child: ProductCard(
                              product: product,
                              onEdit: () => navigateToEditScreen(product.id),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
