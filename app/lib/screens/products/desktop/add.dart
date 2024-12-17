import 'package:dashboard/api/api.dart';
import 'package:dashboard/screens/preview/preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddProductScreenDesktop extends StatefulWidget {
  const AddProductScreenDesktop({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AddProductScreenDesktopState createState() =>
      _AddProductScreenDesktopState();
}

class _AddProductScreenDesktopState extends State<AddProductScreenDesktop> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _shippingCostController = TextEditingController();
  final TextEditingController _colorsController = TextEditingController();
  final TextEditingController _sizesController = TextEditingController();
  final List<TextEditingController> _imageUrlControllers = [];

  String? _selectedCategory;
  List<String> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _addImageUrlField();
  }

  void _addImageUrlField() {
    setState(() {
      _imageUrlControllers.add(TextEditingController());
    });
  }

  void _removeImageUrlField(int index) {
    setState(() {
      _imageUrlControllers.removeAt(index);
    });
  }

  Future<void> _loadCategories() async {
    try {
      if (kDebugMode) {
        print('Iniciando o carregamento das categorias...');
      }
      final response = await http.get(Uri.parse('$apiUrl/api/categories'));

      if (kDebugMode) {
        print('Resposta recebida com status: ${response.statusCode}');
      }
      if (response.statusCode == 200) {
        final List<dynamic> categoriesJson = json.decode(response.body);
        if (kDebugMode) {
          print('Categorias recebidas: $categoriesJson');
        }

        setState(() {
          _categories = categoriesJson.map((category) {
            return category['name'].toString();
          }).toList();
        });

        if (kDebugMode) {
          print('Categorias carregadas com sucesso: $_categories');
        }
      } else {
        if (kDebugMode) {
          print(
              'Erro ao carregar categorias. Código de status: ${response.statusCode}');
        }
        _showMessage('Erro ao carregar categorias', 'error');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Exceção ao carregar categorias: $e');
      }
      _showMessage('Erro ao carregar categorias: $e', 'error');
    }
  }

  Future<void> _addCategory(String category) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/api/categories'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'name': category}),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showMessage(responseData['message'], 'success');
        setState(() {
          _categories.add(category);
        });
        // ignore: use_build_context_synchronously
        Navigator.of(context).pop();
        _loadCategories(); // Atualiza a lista de categorias
      } else {
        _showMessage(
            'Erro ao adicionar categoria: ${responseData['message']}', 'error');
      }
    } catch (e) {
      _showMessage('Erro ao adicionar categoria: $e', 'error');
    }
  }

  Future<void> _showAddCategoryDialog() async {
    final TextEditingController categoryController = TextEditingController();
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Adicionar Nova Categoria'),
          content: TextField(
            controller: categoryController,
            decoration:
                const InputDecoration(hintText: 'Digite o nome da categoria'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Adicionar'),
              onPressed: () {
                final newCategory = categoryController.text.trim();
                if (newCategory.isNotEmpty) {
                  _addCategory(newCategory);
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      final title = _titleController.text;
      final description = _descriptionController.text;
      final price = double.tryParse(_priceController.text) ?? 0;
      final discount = double.tryParse(_discountController.text) ?? 0;
      final shippingCost = double.tryParse(_shippingCostController.text) ?? 0;
      final colors =
          _colorsController.text.split(',').map((e) => e.trim()).toList();
      final sizes =
          _sizesController.text.split(',').map((e) => e.trim()).toList();
      final category = _selectedCategory;
      final imageUrls = _imageUrlControllers.map((c) => c.text).toList();

      final requestBody = json.encode({
        'title': title,
        'description': description,
        'price': price,
        'imageUrls': imageUrls,
        'colors': colors,
        'sizes': sizes,
        'shippingCost': shippingCost,
        'category': category,
        'discount': discount,
      });

      if (kDebugMode) {
        print('Dados a serem enviados:');
      }
      if (kDebugMode) {
        print(requestBody);
      }

      try {
        final response = await http.post(
          Uri.parse('$apiUrl/api/products'),
          headers: {'Content-Type': 'application/json'},
          body: requestBody,
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          _showMessage('Produto adicionado com sucesso!', 'success');
          _formKey.currentState?.reset();
          _imageUrlControllers.clear();
          _addImageUrlField();
        } else {
          _showMessage('Erro ao adicionar produto: ${response.body}', 'error');
        }
      } catch (e) {
        _showMessage('Erro ao adicionar produto: $e', 'error');
      }
    }
  }

  void _showMessage(String message, String type) {
    final color = type == 'success' ? Colors.green : Colors.red;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _discountController.dispose();
    _shippingCostController.dispose();
    _colorsController.dispose();
    _sizesController.dispose();
    for (var controller in _imageUrlControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Cadastro de Produtos',
          style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(labelText: 'Título'),
                      validator: (value) =>
                          value!.isEmpty ? 'Campo obrigatório' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(labelText: 'Descrição'),
                      maxLines: 5,
                      validator: (value) =>
                          value!.isEmpty ? 'Campo obrigatório' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(labelText: 'Preço'),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) =>
                          value!.isEmpty ? 'Campo obrigatório' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _discountController,
                      decoration:
                          const InputDecoration(labelText: 'Desconto (%)'),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) =>
                          value!.isEmpty ? 'Campo obrigatório' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _shippingCostController,
                      decoration:
                          const InputDecoration(labelText: 'Custo de Envio'),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) =>
                          value!.isEmpty ? 'Campo obrigatório' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _colorsController,
                      decoration: const InputDecoration(
                          labelText: 'Cores (separadas por vírgulas)'),
                      validator: (value) =>
                          value!.isEmpty ? 'Campo obrigatório' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _sizesController,
                      decoration: const InputDecoration(
                          labelText: 'Tamanhos (separados por vírgulas)'),
                      validator: (value) =>
                          value!.isEmpty ? 'Campo obrigatório' : null,
                    ),
                    const SizedBox(height: 24),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(labelText: 'Categoria'),
                      items: _categories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      },
                      validator: (value) =>
                          value == null ? 'Campo obrigatório' : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: _showAddCategoryDialog,
                            child: const Text('Adicionar Categoria'),
                          ),
                          ElevatedButton(
                            onPressed: _submitForm,
                            child: const Text('Salvar Produto'),
                          ),
                        ]),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Imagens do Produto',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    ..._imageUrlControllers.asMap().entries.map((entry) {
                      final index = entry.key;
                      final controller = entry.value;
                      return Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: controller,
                              decoration: const InputDecoration(
                                  labelText: 'URL da Imagem'),
                              validator: (value) =>
                                  value!.isEmpty ? 'Campo obrigatório' : null,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.remove_circle),
                            color: Colors.red,
                            onPressed: () => _removeImageUrlField(index),
                          ),
                        ],
                      );
                    }),
                    const SizedBox(height: 16),
                    Center(
                      child: ElevatedButton(
                        onPressed: _addImageUrlField,
                        child: const Text('Adicionar Imagem'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                flex: 1,
                child: ProductPreview(
                  title: _titleController.text,
                  description: _descriptionController.text,
                  price: _priceController.text,
                  discount: _discountController.text,
                  imageUrls: _imageUrlControllers
                      .map((controller) => controller.text)
                      .toList(),
                  selectedCategory: _selectedCategory,
                  isOutOfStock: false,
                  colors: _colorsController.text,
                  sizes: _sizesController.text,
                  shippingCost: _shippingCostController.text,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
