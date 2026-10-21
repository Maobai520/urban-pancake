/// 一条饮食记录
class FoodEntry {
  const FoodEntry({
    this.id,
    required this.name,
    required this.portion,
    required this.meal,
    required this.kcal,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.date,
    required this.createdAt,
  });

  final int? id;
  final String name; // 食物名
  final String portion; // 份量，如 150 g / 1 拳
  final int meal; // 0 早餐 1 午餐 2 晚餐 3 加餐
  final double kcal;
  final double protein;
  final double carbs;
  final double fat;
  final String date; // yyyy-MM-dd
  final DateTime createdAt;

  Map<String, Object?> toMap() => {
        'id': id,
        'name': name,
        'portion': portion,
        'meal': meal,
        'kcal': kcal,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
        'date': date,
        'created_at': createdAt.millisecondsSinceEpoch,
      };

  factory FoodEntry.fromMap(Map<String, Object?> map) => FoodEntry(
        id: map['id'] as int?,
        name: map['name'] as String,
        portion: map['portion'] as String,
        meal: map['meal'] as int,
        kcal: (map['kcal'] as num).toDouble(),
        protein: (map['protein'] as num).toDouble(),
        carbs: (map['carbs'] as num).toDouble(),
        fat: (map['fat'] as num).toDouble(),
        date: map['date'] as String,
        createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      );
}

/// 餐段名称与对应图标（assets/icons 下的文件名）
const mealNames = ['早餐', '午餐', '晚餐', '加餐'];
const mealIcons = ['sunrise', 'sun', 'moon', 'apple'];
