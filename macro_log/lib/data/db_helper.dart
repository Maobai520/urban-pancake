import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// 本地数据库（sqflite）——所有数据存本机，无需联网与登录
class AppDatabase {
  AppDatabase._();

  static Database? _db;

  /// 打开（或创建）数据库；重复调用返回同一实例
  static Future<Database> open() async {
    if (_db != null) return _db!;

    final dbPath = await getDatabasesPath();
    _db = await openDatabase(
      p.join(dbPath, 'macro_log.db'),
      version: 1,
      onCreate: (db, version) async {
        // 饮食记录
        await db.execute('''
          CREATE TABLE food_entries(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            portion TEXT,
            meal INTEGER NOT NULL,
            kcal REAL NOT NULL,
            protein REAL NOT NULL,
            carbs REAL NOT NULL,
            fat REAL NOT NULL,
            date TEXT NOT NULL,
            created_at INTEGER NOT NULL
          )''');

        // 每日饮水
        await db.execute('''
          CREATE TABLE water_logs(
            date TEXT PRIMARY KEY,
            ml INTEGER NOT NULL
          )''');

        // 体重记录（同一天再次记录会覆盖）
        await db.execute('''
          CREATE TABLE weight_records(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT UNIQUE NOT NULL,
            kg REAL NOT NULL
          )''');

        // 每周复盘
        await db.execute('''
          CREATE TABLE weekly_reviews(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT NOT NULL,
            weight_kg REAL,
            waist_cm REAL,
            training_done INTEGER,
            training_total INTEGER
          )''');

        // 设置（如默认方案）
        await db.execute('''
          CREATE TABLE settings(
            key TEXT PRIMARY KEY,
            value TEXT NOT NULL
          )''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // V2 版本升级时在此做数据迁移
      },
    );
    return _db!;
  }
}
