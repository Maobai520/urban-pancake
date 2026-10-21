/// 一条体重记录
class WeightPoint {
  const WeightPoint({required this.date, required this.kg});

  final String date; // yyyy-MM-dd
  final double kg;
}

/// 每周复盘（晨起空腹体重 / 腰围 / 训练完成率）
class WeeklyReview {
  const WeeklyReview({
    required this.date,
    this.weightKg,
    this.waistCm,
    this.trainingDone,
    this.trainingTotal,
  });

  final String date;
  final double? weightKg;
  final double? waistCm;
  final int? trainingDone;
  final int? trainingTotal;
}
