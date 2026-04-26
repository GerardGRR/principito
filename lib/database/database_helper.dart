import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';
import '../models/product.dart';
import '../models/service.dart';
import '../models/sale.dart';
import '../models/sale_history.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'el_principito.db');
    return await openDatabase(
      path,
      version: 7, // Incrementado para agregar campo date a sales
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE products ADD COLUMN isActive INTEGER DEFAULT 1',
      );
      await db.execute(
        'ALTER TABLE services ADD COLUMN isActive INTEGER DEFAULT 1',
      );
    }
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE products ADD COLUMN brand TEXT');
      await db.execute('ALTER TABLE products ADD COLUMN imagePath TEXT');
    }
    if (oldVersion < 4) {
      await db.execute(
        'ALTER TABLE products ADD COLUMN isQuantifiable INTEGER DEFAULT 1',
      );
      await db.execute(
        'ALTER TABLE products ADD COLUMN isAvailable INTEGER DEFAULT 1',
      );
    }
    if (oldVersion < 6) {
      // Intentamos añadir los nuevos campos a servicios
      try {
        await db.execute('ALTER TABLE services ADD COLUMN link TEXT');
        await db.execute('ALTER TABLE services ADD COLUMN imagePath TEXT');
      } catch (e) {
        // Ignorar si ya existen
      }
    }
    if (oldVersion < 7) {
      // Agregar campo date a la tabla sales
      try {
        await db.execute(
          'ALTER TABLE sales ADD COLUMN date TEXT DEFAULT CURRENT_TIMESTAMP',
        );
      } catch (e) {
        // Ignorar si ya existe
      }
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        userId INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        name TEXT NOT NULL,
        password TEXT NOT NULL,
        role TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE services (
        serviceId INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        price REAL NOT NULL,
        link TEXT,
        imagePath TEXT,
        isActive INTEGER DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE products (
        productId INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        quantity INTEGER NOT NULL,
        tags TEXT,
        price REAL NOT NULL,
        brand TEXT,
        imagePath TEXT,
        isActive INTEGER DEFAULT 1,
        isQuantifiable INTEGER DEFAULT 1,
        isAvailable INTEGER DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE sales (
        saleId INTEGER PRIMARY KEY AUTOINCREMENT,
        total REAL NOT NULL,
        userId INTEGER NOT NULL,
        date TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (userId) REFERENCES users (userId)
      )
    ''');

    await db.execute('''
      CREATE TABLE sale_products (
        saleId INTEGER NOT NULL,
        productId INTEGER NOT NULL,
        FOREIGN KEY (saleId) REFERENCES sales (saleId),
        FOREIGN KEY (productId) REFERENCES products (productId)
      )
    ''');

    await db.execute('''
      CREATE TABLE sale_services (
        saleId INTEGER NOT NULL,
        serviceId INTEGER NOT NULL,
        FOREIGN KEY (saleId) REFERENCES sales (saleId),
        FOREIGN KEY (serviceId) REFERENCES services (serviceId)
      )
    ''');

    await db.execute('''
      CREATE TABLE sale_history (
        historyId INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        date TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (userId)
      )
    ''');

    await db.execute('''
      CREATE TABLE history_sales (
        historyId INTEGER NOT NULL,
        saleId INTEGER NOT NULL,
        FOREIGN KEY (historyId) REFERENCES sale_history (historyId),
        FOREIGN KEY (saleId) REFERENCES sales (saleId)
      )
    ''');
  }

  // --- CRUD para Product ---
  Future<int> insertProduct(Product product) async {
    Database db = await database;
    return await db.insert('products', product.toMap());
  }

  Future<List<Product>> getProducts({bool onlyActive = true}) async {
    Database db = await database;
    List<Map<String, dynamic>> maps;
    if (onlyActive) {
      maps = await db.query('products', where: 'isActive = ?', whereArgs: [1]);
    } else {
      maps = await db.query('products');
    }
    return List.generate(maps.length, (i) => Product.fromMap(maps[i]));
  }

  Future<int> updateProduct(Product product) async {
    Database db = await database;
    return await db.update(
      'products',
      product.toMap(),
      where: 'productId = ?',
      whereArgs: [product.productId],
    );
  }

  Future<int> softDeleteProduct(int id) async {
    Database db = await database;
    return await db.update(
      'products',
      {'isActive': 0},
      where: 'productId = ?',
      whereArgs: [id],
    );
  }

  // --- CRUD para Service ---
  Future<int> insertService(Service service) async {
    Database db = await database;
    return await db.insert('services', service.toMap());
  }

  Future<List<Service>> getServices({bool onlyActive = true}) async {
    Database db = await database;
    List<Map<String, dynamic>> maps;
    if (onlyActive) {
      maps = await db.query('services', where: 'isActive = ?', whereArgs: [1]);
    } else {
      maps = await db.query('services');
    }
    return List.generate(maps.length, (i) => Service.fromMap(maps[i]));
  }

  Future<int> updateService(Service service) async {
    Database db = await database;
    return await db.update(
      'services',
      service.toMap(),
      where: 'serviceId = ?',
      whereArgs: [service.serviceId],
    );
  }

  Future<int> softDeleteService(int id) async {
    Database db = await database;
    return await db.update(
      'services',
      {'isActive': 0},
      where: 'serviceId = ?',
      whereArgs: [id],
    );
  }

  // --- CRUD para Sales ---
  Future<int> insertSale(Sale sale) async {
    Database db = await database;
    return await db.transaction((txn) async {
      int saleId = await txn.insert('sales', sale.toMap());

      for (var product in sale.products) {
        await txn.insert('sale_products', {
          'saleId': saleId,
          'productId': product.productId,
        });
      }

      for (var service in sale.services) {
        await txn.insert('sale_services', {
          'saleId': saleId,
          'serviceId': service.serviceId,
        });
      }

      return saleId;
    });
  }

  Future<List<Sale>> getSales() async {
    Database db = await database;
    List<Map<String, dynamic>> saleMaps = await db.query(
      'sales',
      orderBy: 'date DESC',
    );

    List<Sale> sales = [];
    for (var saleMap in saleMaps) {
      int saleId = saleMap['saleId'];

      // Obtener productos de esta venta
      List<Map<String, dynamic>> productMaps = await db.rawQuery(
        '''
        SELECT p.* FROM products p
        INNER JOIN sale_products sp ON p.productId = sp.productId
        WHERE sp.saleId = ?
      ''',
        [saleId],
      );
      List<Product> products = productMaps
          .map((m) => Product.fromMap(m))
          .toList();

      // Obtener servicios de esta venta
      List<Map<String, dynamic>> serviceMaps = await db.rawQuery(
        '''
        SELECT s.* FROM services s
        INNER JOIN sale_services ss ON s.serviceId = ss.serviceId
        WHERE ss.saleId = ?
      ''',
        [saleId],
      );
      List<Service> services = serviceMaps
          .map((m) => Service.fromMap(m))
          .toList();

      sales.add(Sale.fromMap(saleMap, products: products, services: services));
    }
    return sales;
  }

  Future<Sale?> getSaleById(int id) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'sales',
      where: 'saleId = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;

    var saleMap = maps.first;

    List<Map<String, dynamic>> productMaps = await db.rawQuery(
      '''
      SELECT p.* FROM products p
      INNER JOIN sale_products sp ON p.productId = sp.productId
      WHERE sp.saleId = ?
    ''',
      [id],
    );
    List<Product> products = productMaps
        .map((m) => Product.fromMap(m))
        .toList();

    List<Map<String, dynamic>> serviceMaps = await db.rawQuery(
      '''
      SELECT s.* FROM services s
      INNER JOIN sale_services ss ON s.serviceId = ss.serviceId
      WHERE ss.saleId = ?
    ''',
      [id],
    );
    List<Service> services = serviceMaps
        .map((m) => Service.fromMap(m))
        .toList();

    return Sale.fromMap(saleMap, products: products, services: services);
  }

  Future<int> deleteSale(int id) async {
    Database db = await database;
    return await db.transaction((txn) async {
      await txn.delete('sale_products', where: 'saleId = ?', whereArgs: [id]);
      await txn.delete('sale_services', where: 'saleId = ?', whereArgs: [id]);
      return await txn.delete('sales', where: 'saleId = ?', whereArgs: [id]);
    });
  }

  Future<double> getTotalSales() async {
    Database db = await database;
    var result = await db.rawQuery('SELECT SUM(total) as total FROM sales');
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<void> updateProductQuantity(int productId, int newQuantity) async {
    Database db = await database;
    await db.update(
      'products',
      {'quantity': newQuantity},
      where: 'productId = ?',
      whereArgs: [productId],
    );
  }
}
