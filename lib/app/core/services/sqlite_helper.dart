import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'file_data.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE files(id INTEGER PRIMARY KEY AUTOINCREMENT, filePath TEXT, textInput TEXT)',
        );
      },
    );
  }

  Future<void> insertFileData(String filePath, String textInput) async {
    final db = await database;
    await db.insert(
      'files',
      {'filePath': filePath, 'textInput': textInput},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getFileData() async {
    final db = await database;
    return await db.query('files');
  }
}
