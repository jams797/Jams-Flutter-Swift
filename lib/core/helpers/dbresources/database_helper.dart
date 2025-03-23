import 'package:jams_flutter_swift/core/helpers/models/qr_data_model.dart';
import 'package:jams_flutter_swift/core/helpers/statics/var_statics.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'qr_scanner.db');
    return await openDatabase(
      path,
      version: VarStatics.tablesDataBase_version_qrcodes,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${VarStatics.tablesDataBase_model_qrcodes}(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        code TEXT NOT NULL
      )
    ''');
  }

  /// Funcion para obtener todos los codigos creados
  Future<List<QrDBModel>> getAllQrCodes() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      VarStatics.tablesDataBase_model_qrcodes,
      orderBy: 'id DESC',
    );

    return List.generate(maps.length, (i) {
      return QrDBModel.fromMap(maps[i]);
    });
  }

  Future<int> insertQrCode(QrDBModel dataModel) async {
    Database db = await database;
    return await db.insert(VarStatics.tablesDataBase_model_qrcodes, dataModel.toMap());
  }

  Future<void> deleteQrCode(int id) async {
    Database db = await database;
    await db.delete(
      VarStatics.tablesDataBase_model_qrcodes,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}