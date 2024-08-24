import 'package:dashboard/api/api.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ManageCategoriesScreen extends StatefulWidget {
  const ManageCategoriesScreen({super.key});

  @override
  _ManageCategoriesScreenState createState() => _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends State<ManageCategoriesScreen> {
  final TextEditingController _categoryController = TextEditingController();
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await http.get(Uri.parse('$apiUrl/api/categories'));
      if (response.statusCode == 200) {
        final List<dynamic> categoriesJson = json.decode(response.body);
        setState(() {
          _categories = categoriesJson.map((category) {
            return {
              'id': category['id'],
              'name': category['name'].toString(),
            };
          }).toList();
        });
      } else {
        _showMessage('Erro ao carregar categorias', 'error');
      }
    } catch (e) {
      _showMessage('Erro ao carregar categorias: $e', 'error');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addCategory(String category) async {
    if (category.isEmpty) {
      _showMessage('O nome da categoria não pode ser vazio.', 'error');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$apiUrl/api/categories'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'name': category}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        _showMessage(responseData['message'], 'success');
        setState(() {
          _categories.add({'id': responseData['id'], 'name': category});
        });
        Navigator.of(context).pop();
        _loadCategories(); // Atualiza a lista de categorias
      } else {
        final responseData = json.decode(response.body);
        _showMessage(
            'Erro ao adicionar categoria: ${responseData['message']}', 'error');
      }
    } catch (e) {
      _showMessage('Erro ao adicionar categoria: $e', 'error');
    }
  }

  Future<void> _deleteCategory(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$apiUrl/api/categories/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        String message = 'Categoria excluída com sucesso.';
        if (response.statusCode == 200) {
          // Se a resposta contém uma mensagem, decodifique o JSON
          final responseData = json.decode(response.body);
          message = responseData['message'] ?? message;
        }
        _showMessage(message, 'success');
        // Recarregar categorias após exclusão
        await _loadCategories();
      } else {
        final responseData = json.decode(response.body);
        _showMessage(
            'Erro ao excluir categoria: ${responseData['message'] ?? 'Desconhecido'}',
            'error');
      }
    } catch (e) {
      _showMessage('Erro ao excluir categoria: $e', 'error');
    }
  }

  Future<void> _confirmDeleteCategory(int id) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content:
              const Text('Você tem certeza de que deseja excluir a categoria?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Excluir'),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteCategory(id);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showAddCategoryDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Adicionar Nova Categoria'),
          content: TextField(
            controller: _categoryController,
            decoration: const InputDecoration(
              hintText: 'Digite o nome da categoria',
            ),
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
                final newCategory = _categoryController.text.trim();
                if (newCategory.isNotEmpty) {
                  _addCategory(newCategory);
                } else {
                  _showMessage(
                      'O nome da categoria não pode ser vazio.', 'error');
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showMessage(String message, String type) {
    final color = type == 'success' ? Colors.green : Colors.red;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Gerenciar Categorias',
          style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCategories,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _showAddCategoryDialog,
              child: const Text('Adicionar Categoria'),
            ),
            const SizedBox(height: 16.0),
            _isLoading
                ? const Center(child: CircularProgressIndicator.adaptive())
                : Expanded(
                    child: ListView.builder(
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          elevation: 4.0,
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16.0),
                            title: Text(category['name'],
                                style: const TextStyle(fontSize: 16.0)),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () =>
                                  _confirmDeleteCategory(category['id']),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
