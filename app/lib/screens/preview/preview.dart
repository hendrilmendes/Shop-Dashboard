import 'package:flutter/material.dart';

class ProductPreview extends StatelessWidget {
  final String title;
  final String description;
  final String price;
  final String discount;
  final List<String> imageUrls;
  final String? selectedCategory;
  final bool isOutOfStock;
  final String colors;
  final String sizes;
  final String shippingCost;

  const ProductPreview({
    super.key,
    required this.title,
    required this.description,
    required this.price,
    required this.discount,
    required this.imageUrls,
    this.selectedCategory,
    this.isOutOfStock = false,
    required this.colors,
    required this.sizes,
    required this.shippingCost,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pré-visualização do Produto',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 16),
            if (imageUrls.isNotEmpty && _isValidUrl(imageUrls[0]))
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  imageUrls[0],
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Text(
                      'Erro ao carregar a imagem',
                      style: TextStyle(color: Colors.red),
                    );
                  },
                ),
              )
            else
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  color: Colors.grey[300],
                ),
                child: const Center(
                  child: Text(
                    'Nenhuma imagem disponível',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Text(
              title.isEmpty ? 'Título do Produto' : title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'Preço: R\$ ${price.isEmpty ? '0.00' : price}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                if (discount.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      '$discount% OFF',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description.isEmpty
                  ? 'Descrição do produto'
                  : description,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: [
                if (colors.isNotEmpty)
                  _buildChip('Cores: $colors'),
                if (sizes.isNotEmpty)
                  _buildChip('Tamanhos: $sizes'),
                if (selectedCategory != null)
                  _buildChip('Categoria: $selectedCategory'),
                if (shippingCost.isNotEmpty)
                  _buildChip('Frete: R\$ $shippingCost'),
              ],
            ),
            const SizedBox(height: 16),
            if (isOutOfStock)
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  'Este produto está fora de estoque',
                  style: TextStyle(fontSize: 16, color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label) {
    return Chip(
      label: Text(label),
      backgroundColor: Colors.white,
      labelStyle: const TextStyle(color: Colors.blueAccent),
    );
  }

  bool _isValidUrl(String url) {
    return Uri.tryParse(url)?.hasAbsolutePath ?? false;
  }
}
