import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:dashboard/models/products.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onEdit;

  const ProductCard({
    super.key,
    required this.product,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final formattedPrice = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
    ).format(product.price);
    
    final discountedPrice = product.price * (1 - (product.discount / 100));
    final formattedDiscountedPrice = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
    ).format(discountedPrice);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.dividerColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onEdit,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagem do produto
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: _buildProductImage(),
                ),
                if (product.discount > 0)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '-${product.discount.round()}%',
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // Informações do produto
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título
                  Text(
                    product.title,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 6),

                  // Preço
                  Row(
                    children: [
                      if (product.discount > 0)
                        Text(
                          formattedPrice,
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.error,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      if (product.discount > 0) const SizedBox(width: 6),
                      Text(
                        formattedDiscountedPrice,
                        style: textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: product.discount > 0
                              ? colorScheme.primary
                              : colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),

                  if (product.isOutOfStock)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Esgotado',
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage() {
    if (product.imageUrls.isEmpty) {
      return Container(
        color: Colors.grey[100],
        child: const Center(
          child: Icon(
            Icons.image_outlined,
            size: 32,
            color: Colors.grey,
          ),
        ),
      );
    }

    return Image.network(
      product.imageUrls.first,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Shimmer.fromColors(
          baseColor: Colors.grey[200]!,
          highlightColor: Colors.grey[100]!,
          child: Container(color: Colors.white),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey[100],
          child: const Center(
            child: Icon(
              Icons.broken_image_outlined,
              size: 32,
              color: Colors.grey,
            ),
          ),
        );
      },
    );
  }
}