import 'package:dashboard/api/api.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ManageCategoriesScreen extends StatefulWidget {
  const ManageCategoriesScreen({super.key});

  @override
  State<ManageCategoriesScreen> createState() => _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends State<ManageCategoriesScreen> {
  final TextEditingController _categoryController = TextEditingController();
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = false;
  bool _isAdding = false;

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
    setState(() => _isLoading = true);
    try {
      final response = await http.get(Uri.parse('$apiUrl/api/categories'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        setState(() {
          _categories =
              data
                  .map((c) => {'id': c['id'], 'name': c['name'].toString()})
                  .toList();
        });
      } else {
        _showMessage('Erro ao carregar categorias', false);
      }
    } catch (e) {
      _showMessage('Erro: ${e.toString()}', false);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addCategory() async {
    final name = _categoryController.text.trim();
    if (name.isEmpty) {
      _showMessage('Digite um nome para a categoria', false);
      return;
    }

    setState(() => _isAdding = true);
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/api/categories'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'name': name}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        json.decode(response.body);
        _showMessage('Categoria adicionada com sucesso!', true);
        _categoryController.clear();
        await _loadCategories();
      } else {
        final error = json.decode(response.body);
        _showMessage(error['message'] ?? 'Erro ao adicionar', false);
      }
    } catch (e) {
      _showMessage('Erro: ${e.toString()}', false);
    } finally {
      setState(() => _isAdding = false);
    }
  }

  Future<void> _deleteCategory(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$apiUrl/api/categories/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        _showMessage('Categoria removida com sucesso!', true);
        await _loadCategories();
      } else {
        final error = json.decode(response.body);
        _showMessage(error['message'] ?? 'Erro ao remover', false);
      }
    } catch (e) {
      _showMessage('Erro: ${e.toString()}', false);
    }
  }

  void _showMessage(String message, bool isSuccess) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showDeleteDialog(int id) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmar Exclusão'),
            content: const Text(
              'Tem certeza que deseja excluir esta categoria?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _deleteCategory(id);
                },
                child: const Text(
                  'Excluir',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLargeScreen = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Categorias'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCategories,
            tooltip: 'Recarregar',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed:
            () => showDialog(
              context: context,
              builder:
                  (context) => Dialog(
                    insetPadding: EdgeInsets.symmetric(
                      horizontal:
                          isLargeScreen
                              ? MediaQuery.of(context).size.width * 0.2
                              : 20,
                      vertical: 20,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Nova Categoria',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 24),
                          TextField(
                            controller: _categoryController,
                            decoration: InputDecoration(
                              labelText: 'Nome da Categoria',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(Icons.category),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: isLargeScreen ? 20 : 16,
                              ),
                            ),
                            autofocus: true,
                            style: TextStyle(
                              fontSize: isLargeScreen ? 18 : null,
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: isLargeScreen ? 60 : 48,
                            child: ElevatedButton(
                              onPressed: _isAdding ? null : _addCategory,
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child:
                                  _isAdding
                                      ? const CircularProgressIndicator()
                                      : Text(
                                        'Adicionar Categoria',
                                        style: TextStyle(
                                          fontSize: isLargeScreen ? 18 : null,
                                        ),
                                      ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
            ),
        icon: const Icon(Icons.add),
        label: const Text('Adicionar Categoria'),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal:
              isLargeScreen ? MediaQuery.of(context).size.width * 0.1 : 16,
          vertical: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Suas Categorias',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child:
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _categories.isEmpty
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.category_outlined,
                              size: 80,
                              color: theme.colorScheme.outline,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Nenhuma categoria encontrada',
                              style: theme.textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Clique no botão abaixo para adicionar uma nova categoria',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.outline,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                      : GridView.builder(
                        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: isLargeScreen ? 400 : 300,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: isLargeScreen ? 4 : 3,
                        ),
                        itemCount: _categories.length,
                        itemBuilder: (context, index) {
                          final category = _categories[index];
                          return Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),

                              child: Padding(
                                padding: EdgeInsets.all(
                                  isLargeScreen ? 20 : 16,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        category['name'],
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              fontSize:
                                                  isLargeScreen ? 20 : null,
                                            ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.delete,
                                        size: isLargeScreen ? 28 : 24,
                                        color: theme.colorScheme.error,
                                      ),
                                      onPressed:
                                          () =>
                                              _showDeleteDialog(category['id']),
                                    ),
                                  ],
                                ),
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
