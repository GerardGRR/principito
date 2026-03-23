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
      version: 4, // Incrementado por isQuantifiable e isAvailable
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE products ADD COLUMN isActive INTEGER DEFAULT 1');
      await db.execute('ALTER TABLE services ADD COLUMN isActive INTEGER DEFAULT 1');
    }
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE products ADD COLUMN brand TEXT');
      await db.execute('ALTER TABLE products ADD COLUMN imagePath TEXT');
    }
    if (oldVersion < 4) {
      await db.execute('ALTER TABLE products ADD COLUMN isQuantifiable INTEGER DEFAULT 1');
      await db.execute('ALTER TABLE products ADD COLUMN isAvailable INTEGER DEFAULT 1');
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
        serviceId PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        price REAL NOT NULL,
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
    return await db.update('products', product.toMap(), where: 'productId = ?', whereArgs: [product.productId]);
  }

  Future<int> softDeleteProduct(int id) async {
    Database db = await database;
    return await db.update('products', {'isActive': 0}, where: 'productId = ?', whereArgs: [id]);
  }
}
