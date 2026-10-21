import '../theme/app_theme.dart';

/// 减脂目标体重（kg）——来自《每日宏量计划-减脂82kg.md》
const goalWeightKg = 82.0;

/// 每日目标方案（数据来自计划文件，V1 内置两套）
class PlanScheme {
  const PlanScheme({
    required this.id,
    required this.label,
    required this.note,
    required this.kcal,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
    required this.water,
  });

  final String id; // 'm' / 'f'
  final String label; // 方案一 · 男
  final String note; // 假设条件说明
  final int kcal;
  final int protein;
  final int carbs;
  final int fat;
  final int fiber;
  final int water;

  static const male = PlanScheme(
    id: 'm',
    label: '方案一 · 男',
    note: '假设 175cm / 30 岁 / 每周训练 3-5 次 · TDEE ≈ 2742 大卡 · 缺口 15%',
    kcal: 2330,
    protein: 164,
    carbs: 273,
    fat: 65,
    fiber: 33,
    water: 2870,
  );

  static const female = PlanScheme(
    id: 'f',
    label: '方案二 · 女',
    note: '假设 165cm / 30 岁 / 每周训练 3-5 次 · TDEE ≈ 2387 大卡 · 缺口 15%',
    kcal: 2030,
    protein: 164,
    carbs: 216,
    fat: 56,
    fiber: 28,
    water: 2870,
  );

  static PlanScheme byId(String id) => id == 'f' ? female : male;
}

/// 手掌法：不用称重的每餐份量估算
class PalmPortion {
  const PalmPortion({
    required this.title,
    required this.detail,
    required this.circles,
    required this.circleSize,
    required this.color,
    required this.tint,
    this.pill = false,
  });

  final String title;
  final String detail;
  final int circles; // 示意圆圈个数
  final int circleSize; // 圆圈直径
  final Color color;
  final Color tint;
  final bool pill; // 拇指用胶囊形
}

const palmPortions = <PalmPortion>[
  PalmPortion(title: '蛋白质 · 1 掌心', detail: '肉 / 鱼 / 蛋 / 豆制品', circles: 1, circleSize: 26, color: AppColors.cProtein, tint: AppColors.tGreen),
  PalmPortion(title: '碳水 · 1 拳', detail: '米饭 / 面条 / 红薯 / 玉米', circles: 1, circleSize: 34, color: AppColors.cCarbs, tint: AppColors.tBlue),
  PalmPortion(title: '蔬菜 · 2 拳', detail: '绿叶菜优先', circles: 2, circleSize: 34, color: AppColors.yellow, tint: AppColors.tYellow),
  PalmPortion(title: '脂肪 · 1 拇指', detail: '炒菜油 / 坚果 / 酱', circles: 1, circleSize: 22, color: AppColors.cFat, tint: AppColors.tOrange, pill: true),
];

/// 蛋白质组合里的一种食物
class ComboItem {
  const ComboItem(this.name, this.portion, this.kcal, this.protein, this.carbs, this.fat);

  final String name;
  final String portion;
  final int kcal;
  final int protein;
  final int carbs;
  final int fat;
}

/// 每餐 30-40g 蛋白质组合（一键记录）
class ProteinCombo {
  const ProteinCombo({required this.title, required this.desc, required this.items});

  final String title;
  final String desc;
  final List<ComboItem> items;

  int get kcal => items.fold(0, (sum, e) => sum + e.kcal);
  int get protein => items.fold(0, (sum, e) => sum + e.protein);
}

const proteinCombos = <ProteinCombo>[
  ProteinCombo(
    title: '鸡蛋 + 鸡胸 + 牛奶',
    desc: '1 个鸡蛋 · 100g 鸡胸 · 250ml 牛奶',
    items: [
      ComboItem('鸡蛋', '1 个', 70, 6, 1, 5),
      ComboItem('鸡胸肉', '100 g', 130, 24, 0, 3),
      ComboItem('牛奶', '250 ml', 170, 8, 12, 10),
    ],
  ),
  ProteinCombo(
    title: '鱼虾 + 北豆腐',
    desc: '150g 鱼/虾 · 100g 北豆腐',
    items: [
      ComboItem('鱼/虾', '150 g', 150, 30, 0, 3),
      ComboItem('北豆腐', '100 g', 80, 8, 2, 5),
    ],
  ),
  ProteinCombo(
    title: '蛋白粉 + 鸡蛋 + 全麦面包',
    desc: '1 勺蛋白粉 · 2 个鸡蛋 · 1 片全麦面包',
    items: [
      ComboItem('乳清蛋白粉', '1 勺', 120, 24, 3, 1),
      ComboItem('鸡蛋', '2 个', 140, 12, 1, 10),
      ComboItem('全麦面包', '1 片', 90, 3, 17, 2),
    ],
  ),
];

/// 执行要点（只抓三条）
class ExecutionTip {
  const ExecutionTip(this.index, this.text);

  final int index;
  final String text;
}

const executionTips = <ExecutionTip>[
  ExecutionTip(1, '蛋白质优先吃够，一天分 4 餐、每餐 40g 左右最舒服。'),
  ExecutionTip(2, '主食不戒，练前练后那顿保证有碳水；戒掉含糖饮料和零食，比少吃一碗饭管用。'),
  ExecutionTip(3, '每周允许 1 次「不计算餐」，周末守住蛋白质、控制酒和酱料，防周末漂移。'),
];

/// 每天展示一条执行要点（按星期轮换）
ExecutionTip tipOfDay(DateTime d) => executionTips[d.weekday % executionTips.length];
