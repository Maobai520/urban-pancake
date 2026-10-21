import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../models/food_entry.dart';
import '../models/plan_scheme.dart';
import '../state/today_controller.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/add_food_sheet.dart';
import '../widgets/ios_list.dart';

/// 记录页：按餐段记录饮食 + 蛋白质组合一键记录 + 底部实时合计
class RecordPage extends StatefulWidget {
  const RecordPage({super.key, this.initialMeal = 0});

  final int initialMeal;

  @override
  State<RecordPage> createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  late int _meal = widget.initialMeal;

  @override
  Widget build(BuildContext context) {
    final today = context.watch<TodayController>();
    final items = today.entriesOfMeal(_meal);

    return CupertinoPageScaffold(
      child: CustomScrollView(
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle: const Text('记录'),
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              minSize: 32,
              onPressed: _openAddSheet,
              child: Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(color: AppColors.blue, shape: BoxShape.circle),
                child: const Icon(CupertinoIcons.add, size: 18, color: AppColors.white),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: IosSegmented(
              labels: mealNames,
              index: _meal,
              onChanged: (i) => setState(() => _meal = i),
            ),
          ),
          if (items.isEmpty)
            SliverToBoxAdapter(child: _EmptyMeal(mealName: mealNames[_meal]))
          else
            SliverToBoxAdapter(
              child: IosGroup(
                children: [
                  for (final e in items)
                    _FoodRow(
                      entry: e,
                      onDelete: () => _confirmDelete(e),
                    ),
                  IosRow(
                    onTap: _openAddSheet,
                    child: Row(
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          decoration: const BoxDecoration(color: AppColors.blue, shape: BoxShape.circle),
                          child: const Icon(CupertinoIcons.add, size: 13, color: AppColors.white),
                        ),
                        const SizedBox(width: 10),
                        Text('添加食物',
                            style: AppText.subhead.copyWith(color: AppColors.blue, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          SliverToBoxAdapter(child: _CombosCard(meal: _meal)),
          SliverToBoxAdapter(child: _TotalBar(today: today)),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  void _openAddSheet() {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => AddFoodSheet(
        meal: _meal,
        onSave: (entry) => context.read<TodayController>().addFood(entry),
      ),
    );
  }

  Future<void> _confirmDelete(FoodEntry e) async {
    final ok = await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('删除记录'),
        content: Text('确定删除「${e.name}」吗？'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (ok == true && e.id != null) {
      await context.read<TodayController>().deleteFood(e.id!);
    }
  }
}

/// 一条食物记录
class _FoodRow extends StatelessWidget {
  const _FoodRow({required this.entry, required this.onDelete});

  final FoodEntry entry;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return IosRow(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(entry.name, style: AppText.subhead.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(width: 6),
                    Text(entry.portion, style: AppText.caption2),
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const _Dot(color: AppColors.cProtein),
                    Text(' 蛋 ${entry.protein.round()}', style: AppText.caption2),
                    const SizedBox(width: 8),
                    const _Dot(color: AppColors.cCarbs),
                    Text(' 碳 ${entry.carbs.round()}', style: AppText.caption2),
                    const SizedBox(width: 8),
                    const _Dot(color: AppColors.cFat),
                    Text(' 脂 ${entry.fat.round()}', style: AppText.caption2),
                  ],
                ),
              ],
            ),
          ),
          Text(fmtInt(entry.kcal.round()), style: AppText.subhead.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(width: 4),
          CupertinoButton(
            padding: EdgeInsets.zero,
            minSize: 28,
            onPressed: onDelete,
            child: const Icon(CupertinoIcons.trash, size: 17, color: AppColors.label3),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) =>
      Container(width: 5, height: 5, decoration: BoxDecoration(color: color, shape: BoxShape.circle));
}

/// 蛋白质组合一键记录
class _CombosCard extends StatelessWidget {
  const _CombosCard({required this.meal});

  final int meal;

  @override
  Widget build(BuildContext context) {
    final today = context.read<TodayController>();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [AppShadows.card],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text('每餐 30–40g 蛋白质组合', style: AppText.subhead.copyWith(fontWeight: FontWeight.w700)),
              const Spacer(),
              Text('一键记录', style: AppText.caption2),
            ],
          ),
          const SizedBox(height: 4),
          for (final combo in proteinCombos)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 9),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(combo.title,
                            style: AppText.footnote.copyWith(color: AppColors.label, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text(combo.desc, style: AppText.caption2),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => today.addCombo(combo, meal),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(color: AppColors.tBlue, borderRadius: BorderRadius.circular(999)),
                      child: Text('记录',
                          style: AppText.caption.copyWith(color: AppColors.blue, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// 底部今日合计条
class _TotalBar extends StatelessWidget {
  const _TotalBar({required this.today});

  final TodayController today;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 2, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(color: AppColors.dark, borderRadius: BorderRadius.circular(14)),
      child: Column(
        children: [
          Row(
            children: [
              Text('今日合计', style: AppText.caption.copyWith(color: const Color(0x99FFFFFF))),
              const SizedBox(width: 6),
              Text(fmtInt(today.kcal), style: AppText.headline.copyWith(color: AppColors.white)),
              Text(' / ${fmtInt(today.targetKcal)} 千卡',
                  style: AppText.caption.copyWith(color: const Color(0x99FFFFFF))),
              const Spacer(),
              Text('蛋白 ${today.protein}/${today.targetProtein} g',
                  style: AppText.caption.copyWith(color: const Color(0x99FFFFFF))),
            ],
          ),
          const SizedBox(height: 9),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: Stack(
              children: [
                Container(height: 6, color: const Color(0x2EFFFFFF)),
                FractionallySizedBox(
                  widthFactor: today.kcalProgress,
                  child: Container(height: 6, color: AppColors.cKcal),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 空餐段引导
class _EmptyMeal extends StatelessWidget {
  const _EmptyMeal({required this.mealName});

  final String mealName;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 44, horizontal: 24),
        decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(10)),
        child: Column(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: const BoxDecoration(color: AppColors.track, shape: BoxShape.circle),
              child: const Icon(CupertinoIcons.add, size: 24, color: AppColors.label3),
            ),
            const SizedBox(height: 14),
            Text('$mealName还没有记录', style: AppText.subhead.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 5),
            Text('点右上角 ＋ 记录今天的$mealName', style: AppText.caption),
          ],
        ),
      ),
    );
  }
}
