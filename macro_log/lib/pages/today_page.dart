import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../models/food_entry.dart';
import '../models/plan_scheme.dart';
import '../state/today_controller.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/calorie_ring.dart';
import '../widgets/ios_list.dart';
import '../widgets/macro_progress.dart';
import '../widgets/water_card.dart';
import 'record_page.dart';

/// 今天 · 首页：热量圆环 + 宏量进度 + 饮水打卡 + 今日餐食 + 每日提示
class TodayPage extends StatelessWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context) {
    final today = context.watch<TodayController>();

    return CupertinoPageScaffold(
      child: CustomScrollView(
        slivers: [
          const CupertinoSliverNavigationBar(largeTitle: Text('今天')),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: Text('${fmtDate(today.date)} · ${today.scheme.label}', style: AppText.footnote),
            ),
          ),
          SliverToBoxAdapter(child: _CalorieCard(today: today)),
          SliverToBoxAdapter(child: _MacroCard(today: today)),
          SliverToBoxAdapter(
            child: WaterCard(
              ml: today.waterMl,
              target: today.targetWater,
              onAdd: () => today.addWater(250),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(32, 2, 32, 7),
              child: Text('今日餐食', style: AppText.footnote),
            ),
          ),
          SliverToBoxAdapter(child: _MealsCard(today: today)),
          SliverToBoxAdapter(child: _TipCard(tip: tipOfDay(today.date))),
          const SliverToBoxAdapter(child: SizedBox(height: 28)),
        ],
      ),
    );
  }
}

/// 热量圆环卡片
class _CalorieCard extends StatelessWidget {
  const _CalorieCard({required this.today});

  final TodayController today;

  @override
  Widget build(BuildContext context) {
    final remain = today.remainKcal;
    final over = remain < 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [AppShadows.card],
      ),
      child: Row(
        children: [
          CalorieRing(
            progress: today.kcalProgress,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  over ? '+${fmtInt(-remain)}' : fmtInt(remain),
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.6,
                    color: AppColors.label,
                  ),
                ),
                const SizedBox(height: 4),
                Text(over ? '大卡超出' : '大卡剩余', style: AppText.caption),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              children: [
                _LegendLine(color: AppColors.cKcal, label: '已摄入', value: fmtInt(today.kcal)),
                const SizedBox(height: 12),
                _LegendLine(color: AppColors.gray, label: '目标', value: fmtInt(today.targetKcal)),
                const SizedBox(height: 12),
                _LegendLine(color: AppColors.cKcal, hollow: true, label: '剩余', value: fmtInt(remain)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendLine extends StatelessWidget {
  const _LegendLine({
    required this.color,
    required this.label,
    required this.value,
    this.hollow = false,
  });

  final Color color;
  final String label;
  final String value;
  final bool hollow;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            color: hollow ? AppColors.transparent : color,
            border: hollow ? Border.all(color: color, width: 2) : null,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: AppText.footnote),
        const Spacer(),
        Text(value, style: AppText.subhead.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

/// 三大宏量卡片
class _MacroCard extends StatelessWidget {
  const _MacroCard({required this.today});

  final TodayController today;

  @override
  Widget build(BuildContext context) {
    final fatOver = today.fat > today.targetFat;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 2),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [AppShadows.card],
      ),
      child: Column(
        children: [
          MacroProgress(
            name: '蛋白质',
            value: today.protein,
            target: today.targetProtein,
            color: AppColors.cProtein,
            tint: AppColors.tGreen,
            icon: SvgPicture.asset('assets/icons/egg.svg', width: 16, height: 16),
          ),
          MacroProgress(
            name: '碳水',
            value: today.carbs,
            target: today.targetCarbs,
            color: AppColors.cCarbs,
            tint: AppColors.tBlue,
            icon: SvgPicture.asset('assets/icons/wheat.svg', width: 16, height: 16),
          ),
          MacroProgress(
            name: '脂肪',
            value: today.fat,
            target: today.targetFat,
            color: AppColors.cFat,
            tint: AppColors.tOrange,
            icon: SvgPicture.asset('assets/icons/avocado.svg', width: 16, height: 16),
            note: fatOver ? '已超出 ${today.fat - today.targetFat} g，晚餐少油' : null,
          ),
        ],
      ),
    );
  }
}

/// 今日餐食卡片（点某餐 → 跳到记录页对应餐段）
class _MealsCard extends StatelessWidget {
  const _MealsCard({required this.today});

  final TodayController today;

  static const _tints = [AppColors.tYellow, AppColors.tOrange, AppColors.tIndigo, AppColors.tTeal];

  @override
  Widget build(BuildContext context) {
    return IosGroup(
      children: [
        for (var i = 0; i < mealNames.length; i++)
          IosRow(
            onTap: () {
              Navigator.of(context).push(
                CupertinoPageRoute(builder: (_) => RecordPage(initialMeal: i)),
              );
            },
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(color: _tints[i], borderRadius: BorderRadius.circular(7)),
                  child: Center(
                    child: SvgPicture.asset('assets/icons/${mealIcons[i]}.svg', width: 16, height: 16),
                  ),
                ),
                const SizedBox(width: 11),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(mealNames[i], style: AppText.subhead.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(
                      today.mealKcal(i) > 0 ? '${fmtInt(today.mealKcal(i))} 千卡 · 已记录' : '未记录',
                      style: AppText.caption,
                    ),
                  ],
                ),
                const Spacer(),
                if (today.mealKcal(i) > 0)
                  const Icon(CupertinoIcons.check_mark, size: 17, color: AppColors.cProtein)
                else
                  Text('—', style: AppText.subhead.copyWith(color: AppColors.label3)),
                const SizedBox(width: 6),
                const IosChevron(),
              ],
            ),
          ),
      ],
    );
  }
}

/// 今日提示卡片（执行要点每天轮换一条）
class _TipCard extends StatelessWidget {
  const _TipCard({required this.tip});

  final ExecutionTip tip;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [AppShadows.card],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(color: AppColors.tBlue, borderRadius: BorderRadius.circular(7)),
            child: Center(
              child: SvgPicture.asset('assets/icons/lightbulb.svg', width: 16, height: 16),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('今日提示', style: AppText.subhead.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(tip.text, style: AppText.footnote.copyWith(height: 1.6)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
