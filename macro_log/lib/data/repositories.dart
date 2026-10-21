import 'package:sqflite/sqflite.dart';

import '../models/food_entry.dart';
import '../models/weight_point.dart';

/// 数据仓库：饮食 / 饮水 / 体重 / 每周复盘 / 设置（全部本地 SQLite）
class AppRepository {
  AppRepository(this._db);

  final Database _db;

  // ---------- 饮食记录 ----------

  /// 某一天的全部记录（按餐段、录入顺序）
  Future<List<FoodEntry>> entriesOf(String date) async {
    final rows = await _db.query(
      'food_entries',
      where: 'date = ?',
      whereArgs: [date],
      orderBy: 'meal ASC, created_at ASC',
    );
    return rows.map(FoodEntry.fromMap).toList();
  }

  Future<int> addEntry(FoodEntry entry) => _db.insert('food_entries', entry.toMap());

  Future<void> deleteEntry(int id) =>
      _db.delete('food_entries', where: 'id = ?', whereArgs: [id]);

  /// 有记录的日期（倒序），用于计算连续打卡
  Future<List<String>> distinctEntryDates() async {
    final rows = await _db.rawQuery(
      'SELECT DISTINCT date FROM food_entries ORDER BY date DESC',
    );
    return rows.map((r) => r['date'] as String).toList();
  }

  // ---------- 饮水 ----------

  Future<int> waterOf(String date) async {
    final rows = await _db.query('water_logs', where: 'date = ?', whereArgs: [date]);
    if (rows.isEmpty) return 0;
    return (rows.first['ml'] as num).toInt();
  }

  Future<void> setWater(String date, int ml) => _db.insert(
        'water_logs',
        {'date': date, 'ml': ml},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

  // ---------- 体重 ----------

  Future<void> upsertWeight(String date, double kg) => _db.insert(
        'weight_records',
        {'date': date, 'kg': kg},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

  /// 全部体重（按日期升序，供趋势图使用）
  Future<List<WeightPoint>> weightHistory() async {
    final rows = await _db.query('weight_records', orderBy: 'date ASC');
    return rows
        .map((r) => WeightPoint(date: r['date'] as String, kg: (r['kg'] as num).toDouble()))
        .toList();
  }

  // ---------- 每周复盘 ----------

  Future<void> saveReview({
    required String date,
    double? weightKg,
    double? waistCm,
    int? trainingDone,
    int? trainingTotal,
  }) =>
      _db.insert('weekly_reviews', {
        'date': date,
        'weight_kg': weightKg,
        'waist_cm': waistCm,
        'training_done': trainingDone,
        'training_total': trainingTotal,
      });

  Future<WeeklyReview?> latestReview() async {
    final rows = await _db.query('weekly_reviews', orderBy: 'date DESC, id DESC', limit: 1);
    if (rows.isEmpty) return null;
    final r = rows.first;
    return WeeklyReview(
      date: r['date'] as String,
      weightKg: (r['weight_kg'] as num?)?.toDouble(),
      waistCm: (r['waist_cm'] as num?)?.toDouble(),
      trainingDone: r['training_done'] as int?,
      trainingTotal: r['training_total'] as int?,
    );
  }

  // ---------- 设置 ----------

  Future<String?> setting(String key) async {
    final rows = await _db.query('settings', where: 'key = ?', whereArgs: [key], limit: 1);
    return rows.isEmpty ? null : rows.first['value'] as String;
  }

  Future<void> setSetting(String key, String value) => _db.insert(
        'settings',
        {'key': key, 'value': value},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
}
