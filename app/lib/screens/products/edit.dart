import 'package:dashboard/api/api.dart';
import 'package:dashboard/screens/preview/preview.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:http_parser/http_parser.dart';

class EditProductScreen extends StatefulWidget {
  final String productId;
  final Map<String, dynamic> initialProductData;

  const EditProductScreen({
    super.key,
    required this.productId,
    required this.initialProductData,
  });

  @override
  State<EditProductScreen> createState() => _EditProductScreenDesktopState();
}

class _EditProductScreenDesktopState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _shippingCostController = TextEditingController();
  final TextEditingController _colorsController = TextEditingController();
  final TextEditingController _sizesController = TextEditingController();

  final List<PlatformFile> _selectedImages = [];
  List<String> _uploadedImageUrls = [];

  String? _selectedCategory;
  List<String> _categories = [];
  bool _isLoading = false;
  String _message = '';
  Color _messageColor = Colors.green;
  bool _isOutOfStock = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _initializeForm();
  }

  void _initializeForm() {
    final product = widget.initialProductData;
    _titleController.text = product['title'] ?? '';
    _descriptionController.text = product['description'] ?? '';
    _priceController.text = product['price']?.toString() ?? '';
    _discountController.text = product['discount']?.toString() ?? '';
    _shippingCostController.text = product['shippingCost']?.toString() ?? '';
    _colorsController.text = (product['colors'] as List?)?.join(', ') ?? '';
    _sizesController.text = (product['sizes'] as List?)?.join(', ') ?? '';
    _selectedCategory = product['category'];
    _isOutOfStock = product['isOutOfStock'] ?? false;
    _uploadedImageUrls = List<String>.from(product['imageUrls'] ?? []);
  }

  Future<void> _loadCategories() async {
    try {
      final response = await http.get(Uri.parse('$apiUrl/api/categories'));
      if (response.statusCode == 200) {
        final List<dynamic> categoriesJson = json.decode(response.body);
        setState(() {
          _categories =
              categoriesJson
                  .map((category) => category['name'].toString())
                  .toList();
        });
      }
    } catch (e) {
      _showMessage('Erro ao carregar categorias: $e', Colors.red);
    }
  }

  Future<void> _pickImages() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
      );

      if (result != null) {
        setState(() {
          _selectedImages.addAll(result.files);
        });
      }
    } catch (e) {
      _showMessage('Erro ao selecionar imagens: $e', Colors.red);
    }
  }

  Future<void> _uploadImages() async {
    if (_selectedImages.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$apiUrl/api/upload'),
      );

      for (var image in _selectedImages) {
        var file = File(image.path!);
        var stream = http.ByteStream(file.openRead());
        var length = await file.length();

        var multipartFile = http.MultipartFile(
          'images',
          stream,
          length,
          filename: image.name,
          contentType: MediaType('image', 'jpeg'),
        );

        request.files.add(multipartFile);
      }

      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var jsonResponse = json.decode(responseData);

        setState(() {
          _uploadedImageUrls = List<String>.from(jsonResponse['imageUrls']);
          _selectedImages.clear();
          _isLoading = false;
        });

        _showMessage('Imagens enviadas com sucesso!', Colors.green);
      } else {
        _showMessage(
          'Erro ao enviar imagens: ${response.reasonPhrase}',
          Colors.red,
        );
      }
    } catch (e) {
      _showMessage('Erro ao enviar imagens: $e', Colors.red);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _removeUploadedImage(int index) {
    setState(() {
      _uploadedImageUrls.removeAt(index);
    });
  }

  Future<void> _updateProduct() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        final response = await http.put(
          Uri.parse('$apiUrl/api/products/${widget.productId}'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'title': _titleController.text,
            'description': _descriptionController.text,
            'price': double.tryParse(_priceController.text) ?? 0,
            'imageUrls': _uploadedImageUrls,
            'colors':
                _colorsController.text.split(',').map((e) => e.trim()).toList(),
            'sizes':
                _sizesController.text.split(',').map((e) => e.trim()).toList(),
            'shippingCost': double.tryParse(_shippingCostController.text) ?? 0,
            'category': _selectedCategory,
            'discount': double.tryParse(_discountController.text) ?? 0,
            'isOutOfStock': _isOutOfStock,
          }),
        );

        if (response.statusCode == 200) {
          _showMessage('Produto atualizado com sucesso!', Colors.green);
        } else {
          _showMessage(
            'Erro ao atualizar produto: ${response.body}',
            Colors.red,
          );
        }
      } catch (e) {
        _showMessage('Erro ao atualizar produto: $e', Colors.red);
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteProduct() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.delete(
        Uri.parse('$apiUrl/api/products/${widget.productId}'),
      );

      if (response.statusCode == 200) {
        _showMessage('Produto excluído com sucesso!', Colors.green);
        // ignore: use_build_context_synchronously
        Navigator.of(context).pop(true);
      } else {
        _showMessage('Erro ao excluir produto', Colors.red);
      }
    } catch (e) {
      _showMessage('Erro ao excluir produto: $e', Colors.red);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showMessage(String message, Color color) {
    setState(() {
      _message = message;
      _messageColor = color;
    });
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Editar Produto',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium!.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
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
                            if (_message.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: Text(
                                  _message,
                                  style: TextStyle(color: _messageColor),
                                ),
                              ),
                            TextFormField(
                              controller: _titleController,
                              decoration: const InputDecoration(
                                labelText: 'Título',
                              ),
                              validator:
                                  (value) =>
                                      value!.isEmpty
                                          ? 'Campo obrigatório'
                                          : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _descriptionController,
                              decoration: const InputDecoration(
                                labelText: 'Descrição',
                              ),
                              maxLines: 5,
                              validator:
                                  (value) =>
                                      value!.isEmpty
                                          ? 'Campo obrigatório'
                                          : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _priceController,
                              decoration: const InputDecoration(
                                labelText: 'Preço',
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              validator:
                                  (value) =>
                                      value!.isEmpty
                                          ? 'Campo obrigatório'
                                          : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _discountController,
                              decoration: const InputDecoration(
                                labelText: 'Desconto (%)',
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _shippingCostController,
                              decoration: const InputDecoration(
                                labelText: 'Custo de Envio',
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _colorsController,
                              decoration: const InputDecoration(
                                labelText: 'Cores (separadas por vírgulas)',
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _sizesController,
                              decoration: const InputDecoration(
                                labelText: 'Tamanhos (separados por vírgulas)',
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                const Text('Sem estoque:'),
                                Switch(
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
                              decoration: const InputDecoration(
                                labelText: 'Categoria',
                              ),
                              items:
                                  _categories.map((category) {
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
                            ),
                            const SizedBox(height: 24),

                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton(
                                  onPressed: _updateProduct,
                                  child: const Text('Atualizar Produto'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder:
                                          (context) => AlertDialog(
                                            title: const Text(
                                              'Confirmar Exclusão',
                                            ),
                                            content: const Text(
                                              'Tem certeza que deseja excluir este produto?',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed:
                                                    () =>
                                                        Navigator.pop(context),
                                                child: const Text('Cancelar'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                  _deleteProduct();
                                                },
                                                child: const Text(
                                                  'Excluir',
                                                  style: TextStyle(
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                  child: const Text('Excluir Produto'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Imagens do Produto',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Botão para selecionar imagens
                            ElevatedButton(
                              onPressed: _pickImages,
                              child: const Text('Selecionar Imagens'),
                            ),

                            // Botão para enviar imagens selecionadas
                            if (_selectedImages.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: ElevatedButton(
                                  onPressed: _uploadImages,
                                  child: const Text('Enviar Imagens'),
                                ),
                              ),

                            // Lista de imagens selecionadas (ainda não enviadas)
                            if (_selectedImages.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              const Text(
                                'Imagens selecionadas:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                height: 100,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _selectedImages.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Stack(
                                        children: [
                                          Image.file(
                                            File(_selectedImages[index].path!),
                                            width: 100,
                                            height: 100,
                                            fit: BoxFit.cover,
                                          ),
                                          Positioned(
                                            top: 0,
                                            right: 0,
                                            child: IconButton(
                                              icon: const Icon(
                                                Icons.close,
                                                color: Colors.red,
                                              ),
                                              onPressed:
                                                  () => _removeImage(index),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],

                            // Lista de imagens já enviadas
                            if (_uploadedImageUrls.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              const Text(
                                'Imagens enviadas:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                height: 100,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _uploadedImageUrls.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Stack(
                                        children: [
                                          Image.network(
                                            _uploadedImageUrls[index],
                                            width: 100,
                                            height: 100,
                                            fit: BoxFit.cover,
                                          ),
                                          Positioned(
                                            top: 0,
                                            right: 0,
                                            child: IconButton(
                                              icon: const Icon(
                                                Icons.close,
                                                color: Colors.red,
                                              ),
                                              onPressed:
                                                  () => _removeUploadedImage(
                                                    index,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
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
                          imageUrls: _uploadedImageUrls,
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
