import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:mime/mime.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';

final dbPath = p.join(Directory.current.path, 'database.sqlite');
late Database db;

Database openDatabaseConnection() {
  final db = sqlite3.open(dbPath);

  db.execute('''
    CREATE TABLE IF NOT EXISTS Product (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT,
      description TEXT,
      price REAL,
      imageUrls TEXT NOT NULL,
      colors TEXT NOT NULL,
      sizes TEXT NOT NULL,
      shippingCost REAL,
      category TEXT,
      isOutOfStock INTEGER DEFAULT 0,
      discount REAL DEFAULT 0
    )
  ''');

  db.execute('''
    CREATE TABLE IF NOT EXISTS Category (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT UNIQUE NOT NULL
    )
  ''');

  db.execute('''
    CREATE TABLE IF NOT EXISTS CustomerOrder (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      customerName TEXT NOT NULL,
      address TEXT NOT NULL,
      paymentMethod TEXT NOT NULL,
      amount REAL NOT NULL,
      date TEXT DEFAULT (datetime('now'))
    )
  ''');

  db.execute('''
    CREATE TABLE IF NOT EXISTS OrderItem (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      quantity INTEGER NOT NULL,
      price REAL NOT NULL,
      color TEXT NOT NULL,
      size TEXT NOT NULL,
      orderId INTEGER,
      FOREIGN KEY(orderId) REFERENCES CustomerOrder(id)
    )
  ''');

  return db;
}

void main() async {
  final router = Router();
  var db = openDatabaseConnection();

  // Configure o middleware CORS
  final overrideHeaders = {
    ACCESS_CONTROL_ALLOW_ORIGIN: '*',
    ACCESS_CONTROL_ALLOW_HEADERS: '*',
    ACCESS_CONTROL_ALLOW_METHODS: 'GET,POST,PUT,DELETE,OPTIONS',
    'Content-Type': 'application/json;charset=utf-8'
  };

  // Route Raiz
  router.get('/', (Request request) async {
    return Response.ok(
        'Bem vindo a API! Navegue para /api/products, /api/orders ou /api/categories para mais opções.',
        headers: {'Content-Type': 'text/plain'});
  });

  // Adicionar Produtos
  router.post('/api/products', (Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body);

      db.execute('''
      INSERT INTO Product (title, description, price, imageUrls, colors, sizes, shippingCost, category, isOutOfStock, discount)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ''', [
        data['title'],
        data['description'],
        data['price'],
        (data['imageUrls'] as List).join(';'),
        (data['colors'] as List).join(','),
        (data['sizes'] as List).join(','),
        data['shippingCost'],
        data['category'],
        (data['isOutOfStock'] ?? false)
            ? 1
            : 0, // Usando valor padrão false se for null
        data['discount']
      ]);

      return Response.ok(jsonEncode({'status': 'Product added'}),
          headers: {'Content-Type': 'application/json'});
    } catch (e) {
      return Response(500,
          body: jsonEncode(
              {'message': 'Internal server error', 'error': e.toString()}),
          headers: {'Content-Type': 'application/json'});
    }
  });

  // Obter Produtos
  router.get('/api/products', (Request request) async {
    try {
      final products = db.select('SELECT * FROM Product');

      if (products.isEmpty) {
        return Response.ok(
            jsonEncode([]), // Retorne uma lista vazia se não houver produtos
            headers: {'Content-Type': 'application/json'});
      }

      return Response.ok(
          jsonEncode(products.map((product) {
            return {
              'id': product['id'],
              'title': product['title'],
              'description': product['description'],
              'price': product['price'],
              'imageUrls': (product['imageUrls'] as String).split(';'),
              'colors': (product['colors'] as String).split(','),
              'sizes': (product['sizes'] as String).split(','),
              'shippingCost': product['shippingCost'],
              'category': product['category'],
              'isOutOfStock': product['isOutOfStock'] == 1,
              'discount': product['discount'],
            };
          }).toList()), // Converta para uma lista
          headers: {'Content-Type': 'application/json'});
    } catch (e) {
      return Response(500,
          body: jsonEncode(
              {'message': 'Erro ao listar produtos', 'error': e.toString()}),
          headers: {'Content-Type': 'application/json'});
    }
  });

  // Atualizar Produto
  router.put('/api/products/<id>', (Request request, String id) async {
    final body = await request.readAsString();
    final data = jsonDecode(body);

    // Atualizar o produto
    db.execute('''
    UPDATE Product
    SET title = ?, description = ?, price = ?, imageUrls = ?, colors = ?, sizes = ?, shippingCost = ?, category = ?, isOutOfStock = ?, discount = ?
    WHERE id = ?
  ''', [
      data['title'],
      data['description'],
      data['price'],
      (data['imageUrls'] as List).join(';'),
      (data['colors'] as List).join(','),
      (data['sizes'] as List).join(','),
      data['shippingCost'],
      data['category'],
      data['isOutOfStock'] ? 1 : 0,
      data['discount'],
      id
    ]);

    // Verificar se o produto foi atualizado
    final result = db.select('SELECT changes() as updatedRows');
    final updatedRows =
        result.isNotEmpty ? result.first['updatedRows'] as int : 0;

    if (updatedRows == 0) {
      return Response.notFound(jsonEncode({'message': 'Product not found'}));
    }

    return Response.ok(jsonEncode({'status': 'Product updated'}),
        headers: {'Content-Type': 'application/json'});
  });

  // Apagar Produto
  router.delete('/api/products/<id>', (Request request, String id) async {
    // Executa a exclusão do produto
    db.execute('DELETE FROM Product WHERE id = ?', [id]);

    // Verifica se o produto foi realmente deletado
    final result = db.select('SELECT changes() as deletedRows');
    final deletedRows =
        result.isNotEmpty ? result.first['deletedRows'] as int : 0;

    if (deletedRows == 0) {
      return Response.notFound(jsonEncode({'message': 'Product not found'}));
    }

    return Response.ok(jsonEncode({'status': 'Product deleted'}),
        headers: {'Content-Type': 'application/json'});
  });

  // Obter produto pelo ID
  router.get('/api/products/<id>', (Request request, String id) async {
    final product = db.select('SELECT * FROM Product WHERE id = ?', [id]);

    if (product.isEmpty) {
      return Response.notFound(jsonEncode({'message': 'Product not found'}));
    }

    final productData = product.first;
    final productResponse = {
      'id': productData['id'],
      'title': productData['title'],
      'description': productData['description'],
      'price': productData['price'],
      'imageUrls': (productData['imageUrls'] as String).split(';'),
      'colors': (productData['colors'] as String).split(','),
      'sizes': (productData['sizes'] as String).split(','),
      'shippingCost': productData['shippingCost'],
      'category': productData['category'],
      'isOutOfStock': productData['isOutOfStock'] == 1,
      'discount': productData['discount'],
    };

    return Response.ok(jsonEncode(productResponse),
        headers: {'Content-Type': 'application/json'});
  });

  // Adicionar Categoria
  router.post('/api/categories', (Request request) async {
    final body = await request.readAsString();
    final data = jsonDecode(body);

    if (data['name'] == null) {
      return Response(
        400,
        body: jsonEncode({'message': 'O nome da categoria não pode ser vazio'}),
        headers: {'Content-Type': 'application/json'},
      );
    }

    try {
      db.execute('INSERT INTO Category (name) VALUES (?)', [data['name']]);
      return Response.ok(
        jsonEncode({
          'id': db.lastInsertRowId,
          'name': data['name'],
          'message': 'Categoria Adicionada'
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response(
        500,
        body: jsonEncode({'message': 'Erro ao adicionar categoria'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  });

  // Obter Categoria
  router.get('/api/categories', (Request request) async {
    try {
      final result = db.select('SELECT id, name FROM Category');
      final List<Map<String, dynamic>> categories = result.map((row) {
        return {'id': row['id'], 'name': row['name']};
      }).toList();
      return Response.ok(
        jsonEncode(categories),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response(
        500,
        body: jsonEncode({'message': 'Erro ao obter categorias'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  });

  // Apagar Categoria
  router.delete('/api/categories/<id>', (Request request, String id) async {
    try {
      final result = db
          .select('SELECT COUNT(*) AS count FROM Category WHERE id = ?', [id]);
      final count = result.isNotEmpty ? result.first['count'] as int : 0;

      if (count == 0) {
        return Response.notFound(
          jsonEncode({'message': 'Category not found'}),
        );
      }

      db.execute('DELETE FROM Category WHERE id = ?', [id]);

      return Response.ok(
        jsonEncode({'status': 'Category deleted'}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response(
        500,
        body: jsonEncode({'message': 'Erro ao excluir categoria'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  });

  // Obter Pedidos
  router.get('/api/orders', (Request request) async {
    try {
      final orders = db.select('''
      SELECT "CustomerOrder".*, json_group_array(json_object(
        'id', OrderItem.id,
        'title', OrderItem.title,
        'quantity', OrderItem.quantity,
        'price', OrderItem.price,
        'color', OrderItem.color,
        'size', OrderItem.size
      )) AS items
      FROM "CustomerOrder"
      LEFT JOIN OrderItem ON "CustomerOrder".id = OrderItem.orderId
      GROUP BY "CustomerOrder".id
    ''');
      return Response.ok(jsonEncode(orders),
          headers: {'Content-Type': 'application/json'});
    } catch (e) {
      return Response(500,
          body: jsonEncode(
              {'message': 'Erro ao obter pedidos', 'error': e.toString()}),
          headers: {'Content-Type': 'application/json'});
    }
  });

  // Criar Pedido
  router.post('/api/orders', (Request request) async {
    final body = await request.readAsString();
    final data = jsonDecode(body);

    // Insere o pedido e obtém o ID da última linha inserida
    db.execute('''
    INSERT INTO "CustomerOrder" (customerName, address, paymentMethod, amount, date)
    VALUES (?, ?, ?, ?, ?)
  ''', [
      data['customerName'],
      data['address'],
      data['paymentMethod'],
      data['amount'],
      DateTime.now().toIso8601String()
    ]);

    final orderId = db.lastInsertRowId;

    // Insere os itens do pedido
    for (var item in data['items']) {
      db.execute('''
      INSERT INTO OrderItem (title, quantity, price, color, size, orderId)
      VALUES (?, ?, ?, ?, ?, ?)
    ''', [
        item['title'],
        item['quantity'],
        item['price'],
        item['color'],
        item['size'],
        orderId
      ]);
    }

    return Response.ok(jsonEncode({'status': 'Order created'}),
        headers: {'Content-Type': 'application/json'});
  });

  // Apagar DB
  router.delete('/api/clear', (Request request) async {
    db.execute('DELETE FROM Product');
    db.execute('DELETE FROM Category');
    db.execute('DELETE FROM CustomerOrder');
    db.execute('DELETE FROM OrderItem');
    return Response.ok(jsonEncode({'status': 'Dados Apagados'}),
        headers: {'Content-Type': 'application/json'});
  });

  // Backup DB
  router.get('/api/backup', (Request request) async {
    final backupFile =
        p.join(Directory.current.path, 'backup', 'database-backup.sqlite');
    final file = File(backupFile);
    file.createSync(recursive: true);
    File(dbPath).copySync(backupFile);

    final backupBytes = file.readAsBytesSync();

    return Response.ok(
      backupBytes,
      headers: {
        'Content-Type': 'application/octet-stream',
        'Content-Disposition': 'attachment; filename=database-backup.sqlite'
      },
    );
  });

  // Restaurar DB
  router.post('/api/restore', (Request request) async {
    try {
      final contentType = request.headers['Content-Type'] ?? '';
      if (!contentType.contains('multipart/form-data')) {
        return Response(400,
            body: 'Requisição inválida. Esperado multipart/form-data.');
      }

      // Cria um MultipartRequest para processar multipart/form-data
      final boundary = contentType.split('; boundary=')[1];
      final transformer =
          MimeMultipartTransformer(boundary).cast<Uint8List, MimeMultipart>();
      final parts = await request.read().transform(transformer).toList();

      for (final part in parts) {
        final disposition = part.headers['content-disposition'] ?? '';
        if (disposition.contains('name="backupFile"')) {
          final backupFile = File(dbPath);
          final bytes = await part
              .fold<List<int>>([], (buffer, data) => buffer..addAll(data));

          // Substitui o banco de dados existente pelo backup
          await backupFile.writeAsBytes(bytes);

          // Reabre a conexão com o banco de dados
          db.dispose();
          db = openDatabaseConnection();

          return Response.ok('Backup restaurado com sucesso.',
              headers: {'Content-Type': 'application/json'});
        }
      }

      return Response(400,
          body: 'Arquivo de backup não encontrado na requisição.');
    } catch (e) {
      print('Erro ao restaurar o backup: ${e.toString()}');
      return Response(500, body: 'Erro ao restaurar o backup: ${e.toString()}');
    }
  });

  // Adiciona o middleware de logging e CORS ao pipeline
  final handler = const Pipeline()
      .addMiddleware(corsHeaders(headers: overrideHeaders))
      .addMiddleware(logRequests())
      .addHandler(router.call);

  final server = await io.serve(handler, '0.0.0.0', 3000);
  print('Servidor iniciado: http://${server.address.host}:${server.port}');
}
