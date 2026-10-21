import 'package:flutter/foundation.dart';

import '../data/repositories.dart';
import '../models/food_entry.dart';
import '../models/plan_scheme.dart';
import '../utils/format.dart';
import 'plan_controller.dart';

/// 今日数据状态：当天的饮食记录、宏量合计、饮水
class TodayController extends ChangeNotifier {
  TodayController(this._repo, this._plan);

  final AppRepository _repo;
  final PlanController _plan;

  DateTime date = DateTime.now();
  List<FoodEntry> entries = const [];
  int waterMl = 0;
  bool loading = true;

  String get dateKey => dateKeyOf(date);

  /// 当前方案（男 / 女切换后目标值联动）
  PlanScheme get scheme => _plan.scheme;

  // ---------- 今日合计 ----------
  int get kcal => entries.fold(0, (sum, e) => sum + e.kcal.round());
  int get protein => entries.fold(0, (sum, e) => sum + e.protein.round());
  int get carbs => entries.fold(0, (sum, e) => sum + e.carbs.round());
  int get fat => entries.fold(0, (sum, e) => sum + e.fat.round());

  // ---------- 目标值 ----------
  int get targetKcal => scheme.kcal;
  int get targetProtein => scheme.protein;
  int get targetCarbs => scheme.carbs;
  int get targetFat => scheme.fat;
  int get targetWater => scheme.water;

  /// 剩余热量（超出目标时为负数）
  int get remainKcal => targetKcal - kcal;
  double get kcalProgress => targetKcal <= 0 ? 0 : (kcal / targetKcal).clamp(0.0, 1.0);

  // ---------- 按餐段 ----------
  List<FoodEntry> entriesOfMeal(int meal) => entries.where((e) => e.meal == meal).toList();

  int mealKcal(int meal) => entriesOfMeal(meal).fold(0, (sum, e) => sum + e.kcal.round());

  // ---------- 数据操作 ----------
  Future<void> load() async {
    loading = true;
    notifyListeners();
    entries = await _repo.entriesOf(dateKey);
    waterMl = await _repo.waterOf(dateKey);
    loading = false;
    notifyListeners();
  }

  Future<void> addFood(FoodEntry entry) async {
    await _repo.addEntry(entry);
    await load();
  }

  /// 蛋白质组合一键记录（一次写入多条）
  Future<void> addCombo(ProteinCombo combo, int meal) async {
    final now = DateTime.now();
    for (final item in combo.items) {
      await _repo.addEntry(FoodEntry(
        name: item.name,
        portion: item.portion,
        meal: meal,
        kcal: item.kcal.toDouble(),
        protein: item.protein.toDouble(),
        carbs: item.carbs.toDouble(),
        fat: item.fat.toDouble(),
        date: dateKey,
        createdAt: now,
      ));
    }
    await load();
  }

  Future<void> deleteFood(int id) async {
    await _repo.deleteEntry(id);
    await load();
  }

  /// 饮水打卡（上限 3 倍目标，防止误触）
  Future<void> addWater(int ml) async {
    waterMl = (waterMl + ml).clamp(0, targetWater * 3);
    notifyListeners();
    await _repo.setWater(dateKey, waterMl);
  }
}
