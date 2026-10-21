import 'package:flutter/foundation.dart';

import '../data/repositories.dart';
import '../models/plan_scheme.dart';
import '../models/weight_point.dart';
import '../utils/format.dart';

/// 「我的」状态：体重趋势 / 连续打卡 / 每周复盘
class ProfileController extends ChangeNotifier {
  ProfileController(this._repo);

  final AppRepository _repo;

  List<WeightPoint> weights = const [];
  WeeklyReview? latestReview;
  int streakDays = 0;
  bool loading = true;

  double? get currentKg => weights.isEmpty ? null : weights.last.kg;
  double? get startKg => weights.isEmpty ? null : weights.first.kg;

  /// 减脂进度 0~1（从起始体重到目标 82kg）
  double get goalProgress {
    final start = startKg;
    final cur = currentKg;
    if (start == null || cur == null || start <= goalWeightKg) return 0;
    return ((start - cur) / (start - goalWeightKg)).clamp(0.0, 1.0);
  }

  /// 距离目标还差多少 kg
  double get remainKg {
    final cur = currentKg;
    if (cur == null) return 0;
    return (cur - goalWeightKg).clamp(0.0, double.infinity);
  }

  Future<void> load() async {
    loading = true;
    notifyListeners();
    weights = await _repo.weightHistory();
    latestReview = await _repo.latestReview();
    streakDays = _streakFrom(await _repo.distinctEntryDates());
    loading = false;
    notifyListeners();
  }

  Future<void> saveWeight(double kg) async {
    await _repo.upsertWeight(dateKeyOf(DateTime.now()), kg);
    await load();
  }

  Future<void> saveReview({
    double? weightKg,
    double? waistCm,
    int? trainingDone,
    int? trainingTotal,
  }) async {
    await _repo.saveReview(
      date: dateKeyOf(DateTime.now()),
      weightKg: weightKg,
      waistCm: waistCm,
      trainingDone: trainingDone,
      trainingTotal: trainingTotal,
    );
    await load();
  }

  /// 连续打卡天数：今天还没记录则从昨天算起（今天没记不算断签）
  int _streakFrom(List<String> datesDesc) {
    final set = datesDesc.toSet();
    var day = DateTime.now();
    if (!set.contains(dateKeyOf(day))) {
      day = day.subtract(const Duration(days: 1));
    }
    var streak = 0;
    while (set.contains(dateKeyOf(day))) {
      streak++;
      day = day.subtract(const Duration(days: 1));
    }
    return streak;
  }
}
