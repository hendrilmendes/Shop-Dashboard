// ignore_for_file: use_build_context_synchronously

import 'package:dashboard/screens/preview/preview.dart';
import 'package:dashboard/screens/products/desktop/edit.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditProductScreen extends StatefulWidget {
  final String productId;

  const EditProductScreen({super.key, required this.productId});

  @override
  // ignore: library_private_types_in_public_api
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _discountController = TextEditingController();
  final _colorsController = TextEditingController();
  final _sizesController = TextEditingController();
  final _shippingCostController = TextEditingController();
  String? _selectedCategory;
  final List<TextEditingController> _imageUrls = [];
  bool _isOutOfStock = false;

  String _message = '';
  Color _messageColor = Colors.black;
  bool _isLoading = false;
  List<String> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadProductDetails();
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoading = true);
    try {
      final response = await http
          .get(Uri.parse('http://45.174.192.150:3000/api/categories'));
      if (response.statusCode == 200) {
        setState(() {
          _categories = List<String>.from(json.decode(response.body));
          if (_categories.isNotEmpty && _selectedCategory == null) {
            _selectedCategory =
                _categories[0]; // Set default category if available
          }
        });
      } else {
        setState(() {
          _message = 'Erro ao carregar categorias';
          _messageColor = Colors.red;
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Erro: ${e.toString()}';
        _messageColor = Colors.red;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadProductDetails() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(Uri.parse(
          'http://45.174.192.150:3000/api/products/${widget.productId}'));
      if (response.statusCode == 200) {
        final product = json.decode(response.body);
        setState(() {
          _titleController.text = product['title'];
          _descriptionController.text = product['description'];
          _priceController.text = product['price'].toString();
          _discountController.text = product['discount'].toString();
          _colorsController.text = (product['colors'] as List).join(', ');
          _sizesController.text = (product['sizes'] as List).join(', ');
          _shippingCostController.text = product['shippingCost'].toString();
          _selectedCategory = product['category'];
          _isOutOfStock = product['isOutOfStock'];

          _imageUrls.clear();
          _imageUrls.addAll((product['imageUrls'] as List<dynamic>)
              .map((url) => TextEditingController(text: url as String))
              .toList());
        });
      } else {
        setState(() {
          _message = 'Erro ao carregar detalhes do produto';
          _messageColor = Colors.red;
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Erro: ${e.toString()}';
        _messageColor = Colors.red;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateProduct() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      try {
        final response = await http.put(
          Uri.parse(
              'http://45.174.192.150:3000/api/products/${widget.productId}'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'title': _titleController.text,
            'description': _descriptionController.text,
            'price': double.tryParse(_priceController.text),
            'discount': double.tryParse(_discountController.text),
            'imageUrls': _imageUrls.map((e) => e.text).toList(),
            'colors':
                _colorsController.text.split(',').map((e) => e.trim()).toList(),
            'sizes':
                _sizesController.text.split(',').map((e) => e.trim()).toList(),
            'shippingCost': double.tryParse(_shippingCostController.text),
            'category': _selectedCategory,
            'isOutOfStock': _isOutOfStock,
          }),
        );
        if (response.statusCode == 200) {
          Navigator.pop(
              context, true); // Indica que a atualização foi bem-sucedida
        } else {
          setState(() {
            _message = 'Erro ao atualizar produto';
            _messageColor = Colors.red;
          });
        }
      } catch (e) {
        setState(() {
          _message = 'Erro: ${e.toString()}';
          _messageColor = Colors.red;
        });
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteProduct() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir Produto'),
          content:
              const Text('Você tem certeza que deseja excluir este produto?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      try {
        final response = await http.delete(
          Uri.parse(
              'http://45.174.192.150:3000/api/products/${widget.productId}'),
        );
        if (response.statusCode == 200) {
          Navigator.pop(context, true); // Indica que o produto foi excluído
        } else {
          setState(() {
            _message = 'Erro ao excluir produto';
            _messageColor = Colors.red;
          });
        }
      } catch (e) {
        setState(() {
          _message = 'Erro: ${e.toString()}';
          _messageColor = Colors.red;
        });
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  bool _isValidUrl(String url) {
    final uri = Uri.tryParse(url);
    return uri != null && uri.isAbsolute;
  }

  void _addImageUrlField() {
    setState(() {
      _imageUrls.add(TextEditingController());
    });
  }

  void _removeImageUrlField(int index) {
    setState(() {
      _imageUrls.removeAt(index);
    });
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
        title: const Text('Editar Produto'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_message.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        _message,
                        style: TextStyle(color: _messageColor, fontSize: 16),
                      ),
                    ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _titleController,
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
                              controller: _descriptionController,
                              decoration:
                                  const InputDecoration(labelText: 'Descrição'),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor, insira uma descrição';
                                }
                                return null;
                              },
                            ),
                            TextFormField(
                              controller: _priceController,
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
                              controller: _discountController,
                              decoration:
                                  const InputDecoration(labelText: 'Desconto'),
                              keyboardType: TextInputType.number,
                            ),
                            TextFormField(
                              controller: _colorsController,
                              decoration:
                                  const InputDecoration(labelText: 'Cores'),
                            ),
                            TextFormField(
                              controller: _sizesController,
                              decoration:
                                  const InputDecoration(labelText: 'Tamanhos'),
                            ),
                            TextFormField(
                              controller: _shippingCostController,
                              decoration:
                                  const InputDecoration(labelText: 'Frete'),
                              keyboardType: TextInputType.number,
                            ),
                            Row(
                              children: [
                                const Text('Sem Estoque:'),
                                Switch.adaptive(
                                  value: _isOutOfStock,
                                  onChanged: (value) {
                                    setState(() {
                                      _isOutOfStock = value;
                                    });
                                  },
                                ),
                              ],
                            ),
                            DropdownButtonFormField<String>(
                              value: _selectedCategory,
                              items: _categories.map((category) {
                                return DropdownMenuItem<String>(
                                  value: category,
                                  child: Text(category),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedCategory = value;
                                });
                              },
                              decoration:
                                  const InputDecoration(labelText: 'Categoria'),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor, selecione uma categoria';
                                }
                                return null;
                              },
                            ),
                            ..._imageUrls.asMap().entries.map((entry) {
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
                                    onPressed: () =>
                                        _removeImageUrlField(index),
                                  ),
                                ],
                              );
                            }).toList(),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _addImageUrlField,
                              child: const Text('Adicionar URL de Imagem'),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton(
                                  onPressed: _updateProduct,
                                  child: const Text('Atualizar Produto'),
                                ),
                                ElevatedButton(
                                  onPressed: _deleteProduct,
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red),
                                  child: const Text('Excluir Produto'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            ProductPreview(
                              title: _titleController.text,
                              description: _descriptionController.text,
                              price: _priceController.text,
                              discount: _discountController.text,
                              imageUrls: _imageUrls
                                  .map((controller) => controller.text)
                                  .toList(),
                              selectedCategory: _selectedCategory,
                              isOutOfStock: _isOutOfStock,
                              colors: _colorsController.text,
                              sizes: _sizesController.text,
                              shippingCost: _shippingCostController.text,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildLargeScreenLayout(BuildContext context) {
    return EditProductScreenDesktop(
      formKey: _formKey,
      titleController: _titleController,
      descriptionController: _descriptionController,
      priceController: _priceController,
      discountController: _discountController,
      colorsController: _colorsController,
      sizesController: _sizesController,
      shippingCostController: _shippingCostController,
      imageUrls: _imageUrls,
      selectedCategory: _selectedCategory,
      categories: _categories,
      isOutOfStock: _isOutOfStock,
      isLoading: _isLoading,
      message: _message,
      messageColor: _messageColor,
      onAddImageUrlField: _addImageUrlField,
      onRemoveImageUrlField: _removeImageUrlField,
      onCategoryChanged: (value) {
        setState(() {
          _selectedCategory = value;
        });
      },
      onOutOfStockChanged: (value) {
        setState(() {
          _isOutOfStock = value;
        });
      },
      onUpdateProduct: _updateProduct,
      onDeleteProduct: _deleteProduct,
    );
  }
}
