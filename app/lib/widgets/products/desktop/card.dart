import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:dashboard/models/products.dart';

class ProductCardDesktop extends StatelessWidget {
  final Product product;
  final VoidCallback onEdit;

  const ProductCardDesktop(
      {super.key, required this.product, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final NumberFormat formatter =
        NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final formattedPrice = formatter.format(product.price);
    final discountedPrice = product.price * (1 - (product.discount / 100));
    final formattedDiscountedPrice = formatter.format(discountedPrice);

    return GestureDetector(
      onTap: onEdit,
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagem do produto
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      product.imageUrls.isNotEmpty
                          ? product.imageUrls.first
                          : '',
                      loadingBuilder: (BuildContext context, Widget child,
                          ImageChunkEvent? loadingProgress) {
                        if (loadingProgress == null) {
                          return child;
                        } else {
                          return Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(
                              color: Colors.white,
                            ),
                          );
                        }
                      },
                      errorBuilder: (BuildContext context, Object error,
                          StackTrace? stackTrace) {
                        return const Icon(Icons.error,
                            size: 64, color: Colors.red);
                      },
                      fit: BoxFit.cover,
                    )),
              ),
              const SizedBox(height: 12),

              // Título e botão de editar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      product.title,
                      style:
                          Theme.of(context).textTheme.headlineSmall!.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit,
                        color: Colors.blueAccent, size: 24),
                    onPressed: onEdit,
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Descrição do produto
              Text(
                product.description,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Colors.grey[600],
                    ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // Preço e desconto
              Row(
                children: [
                  if (product.discount > 0)
                    Text(
                      formattedPrice,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.red,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  if (product.discount > 0) const SizedBox(width: 8),
                  Text(
                    formattedDiscountedPrice,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color:
                          product.discount > 0 ? Colors.green : Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 20),

                  // Label de "Esgotado"
                  if (product.isOutOfStock)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 4, horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Esgotado',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
