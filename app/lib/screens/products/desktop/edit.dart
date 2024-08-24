// edit_product_screen_desktop.dart
import 'package:dashboard/screens/preview/preview.dart';
import 'package:flutter/material.dart';

class EditProductScreenDesktop extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController priceController;
  final TextEditingController discountController;
  final TextEditingController colorsController;
  final TextEditingController sizesController;
  final TextEditingController shippingCostController;
  final List<TextEditingController> imageUrls;
  final String? selectedCategory;
  final List<String> categories;
  final bool isOutOfStock;
  final bool isLoading;
  final String message;
  final Color messageColor;
  final VoidCallback onAddImageUrlField;
  final Function(int) onRemoveImageUrlField;
  final ValueChanged<String?> onCategoryChanged;
  final ValueChanged<bool> onOutOfStockChanged;
  final VoidCallback onUpdateProduct;
  final VoidCallback onDeleteProduct;

  const EditProductScreenDesktop({
    super.key,
    required this.formKey,
    required this.titleController,
    required this.descriptionController,
    required this.priceController,
    required this.discountController,
    required this.colorsController,
    required this.sizesController,
    required this.shippingCostController,
    required this.imageUrls,
    required this.selectedCategory,
    required this.categories,
    required this.isOutOfStock,
    required this.isLoading,
    required this.message,
    required this.messageColor,
    required this.onAddImageUrlField,
    required this.onRemoveImageUrlField,
    required this.onCategoryChanged,
    required this.onOutOfStockChanged,
    required this.onUpdateProduct,
    required this.onDeleteProduct,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Editar Produto',
          style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator.adaptive())
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Form(
                      key: formKey,
                      child: ListView(
                        children: [
                          if (message.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: Text(
                                message,
                                style: TextStyle(
                                    color: messageColor, fontSize: 16),
                              ),
                            ),
                          TextFormField(
                            controller: titleController,
                            decoration:
                                const InputDecoration(labelText: 'Título'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, insira um título';
                              }
                              return null;
                            },
                          ),
                          TextFormField(
                            controller: descriptionController,
                            decoration:
                                const InputDecoration(labelText: 'Descrição'),
                            maxLines: 5,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, insira uma descrição';
                              }
                              return null;
                            },
                          ),
                          TextFormField(
                            controller: priceController,
                            decoration:
                                const InputDecoration(labelText: 'Preço'),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, insira um preço';
                              }
                              return null;
                            },
                          ),
                          TextFormField(
                            controller: discountController,
                            decoration:
                                const InputDecoration(labelText: 'Desconto'),
                            keyboardType: TextInputType.number,
                          ),
                          TextFormField(
                            controller: colorsController,
                            decoration:
                                const InputDecoration(labelText: 'Cores'),
                          ),
                          TextFormField(
                            controller: sizesController,
                            decoration:
                                const InputDecoration(labelText: 'Tamanhos'),
                          ),
                          TextFormField(
                            controller: shippingCostController,
                            decoration:
                                const InputDecoration(labelText: 'Frete'),
                            keyboardType: TextInputType.number,
                          ),
                          Row(
                            children: [
                              const Text('Sem Estoque:'),
                              Switch.adaptive(
                                value: isOutOfStock,
                                onChanged: onOutOfStockChanged,
                              ),
                            ],
                          ),
                          DropdownButtonFormField<String>(
                            value: selectedCategory,
                            items: categories.map((category) {
                              return DropdownMenuItem<String>(
                                value: category,
                                child: Text(category),
                              );
                            }).toList(),
                            onChanged: onCategoryChanged,
                            decoration:
                                const InputDecoration(labelText: 'Categoria'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, selecione uma categoria';
                              }
                              return null;
                            },
                          ),
                          ...imageUrls.asMap().entries.map((entry) {
                            int index = entry.key;
                            TextEditingController controller = entry.value;
                            return Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: controller,
                                    decoration: InputDecoration(
                                        labelText:
                                            'URL da Imagem ${index + 1}'),
                                    validator: (value) {
                                      if (value != null &&
                                          value.isNotEmpty &&
                                          !_isValidUrl(value)) {
                                        return 'URL inválido';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.remove_circle),
                                  color: Colors.red,
                                  onPressed: () => onRemoveImageUrlField(index),
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton(
                                  onPressed: onAddImageUrlField,
                                  child: const Text('Adicionar URL de Imagem'),
                                ),
                              ],
                            );
                          }),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton(
                                onPressed: onUpdateProduct,
                                child: const Text('Atualizar Produto'),
                              ),
                              ElevatedButton(
                                onPressed: onDeleteProduct,
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red),
                                child: const Text('Excluir Produto'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    flex: 1,
                    child: ProductPreview(
                      title: titleController.text,
                      description: descriptionController.text,
                      price: priceController.text,
                      discount: discountController.text,
                      imageUrls: imageUrls
                          .map((controller) => controller.text)
                          .toList(),
                      selectedCategory: selectedCategory,
                      isOutOfStock: isOutOfStock,
                      colors: colorsController.text,
                      sizes: sizesController.text,
                      shippingCost: shippingCostController.text,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  bool _isValidUrl(String url) {
    final uri = Uri.tryParse(url);
    return uri != null && uri.isAbsolute;
  }
}
