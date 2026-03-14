import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/task_cell.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('task_planner.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE task_cells (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        rowIndex INTEGER NOT NULL,
        colIndex INTEGER NOT NULL,
        content TEXT DEFAULT '',
        color TEXT DEFAULT '',
        updatedAt TEXT NOT NULL,
        UNIQUE(rowIndex, colIndex)
      )
    ''');
  }

  // 保存或更新单元格
  Future<int> saveCell(TaskCell cell) async {
    final db = await instance.database;
    final map = cell.toMap();
    map.remove('id'); // 移除id，让数据库自动生成

    return await db.insert(
      'task_cells',
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // 获取所有单元格
  Future<List<TaskCell>> getAllCells() async {
    final db = await instance.database;
    final result = await db.query('task_cells');
    return result.map((map) => TaskCell.fromMap(map)).toList();
  }

  // 获取特定单元格
  Future<TaskCell?> getCell(int rowIndex, int colIndex) async {
    final db = await instance.database;
    final result = await db.query(
      'task_cells',
      where: 'rowIndex = ? AND colIndex = ?',
      whereArgs: [rowIndex, colIndex],
    );
    if (result.isEmpty) return null;
    return TaskCell.fromMap(result.first);
  }

  // 批量保存
  Future<void> saveAllCells(List<TaskCell> cells) async {
    final db = await instance.database;
    final batch = db.batch();
    for (var cell in cells) {
      final map = cell.toMap();
      map.remove('id');
      batch.insert(
        'task_cells',
        map,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  // 清空所有数据
  Future<int> clearAll() async {
    final db = await instance.database;
    return await db.delete('task_cells');
  }
}
