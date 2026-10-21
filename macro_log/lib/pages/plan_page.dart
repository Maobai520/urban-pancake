import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../models/plan_scheme.dart';
import '../state/plan_controller.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/ios_list.dart';

/// 计划页：每日目标 + 手掌法 + 执行要点（男 / 女方案切换）
class PlanPage extends StatelessWidget {
  const PlanPage({super.key});

  @override
  Widget build(BuildContext context) {
    final plan = context.watch<PlanController>();

    return CupertinoPageScaffold(
      child: CustomScrollView(
        slivers: [
          const CupertinoSliverNavigationBar(largeTitle: Text('计划')),
          SliverToBoxAdapter(
            child: IosSegmented(
              labels: const ['方案一 · 男', '方案二 · 女'],
              index: plan.isMale ? 0 : 1,
              onChanged: (i) => plan.select(i == 0 ? PlanScheme.male : PlanScheme.female),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(32, 2, 32, 10),
              child: Text(plan.scheme.note, style: AppText.caption2),
            ),
          ),
          SliverToBoxAdapter(child: _TargetsCard(scheme: plan.scheme)),
          const SliverToBoxAdapter(child: _PalmCard()),
          const SliverToBoxAdapter(child: _TipsCard()),
          const SliverToBoxAdapter(child: SizedBox(height: 28)),
        ],
      ),
    );
  }
}

/// 今日目标（6 个指标格）
class _TargetsCard extends StatelessWidget {
  const _TargetsCard({required this.scheme});

  final PlanScheme scheme;

  @override
  Widget build(BuildContext context) {
    final tiles = <Widget>[
      _TargetTile(icon: 'flame', tint: AppColors.tPink, value: fmtInt(scheme.kcal), unit: '千卡', label: '每日目标热量'),
      _TargetTile(icon: 'egg', tint: AppColors.tGreen, value: '${scheme.protein}', unit: 'g', label: '蛋白质 2.0g/kg'),
      _TargetTile(icon: 'wheat', tint: AppColors.tBlue, value: '${scheme.carbs}', unit: 'g', label: '碳水化合物'),
      _TargetTile(icon: 'avocado', tint: AppColors.tOrange, value: '${scheme.fat}', unit: 'g', label: '脂肪'),
      _TargetTile(icon: 'leaf', tint: AppColors.tPurple, value: '${scheme.fiber}', unit: 'g', label: '膳食纤维'),
      _TargetTile(icon: 'drop', tint: AppColors.tTeal, value: fmtInt(scheme.water), unit: 'ml', label: '饮水'),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [AppShadows.card],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: tiles[0]),
              const SizedBox(width: 10),
              Expanded(child: tiles[1]),
              const SizedBox(width: 10),
              Expanded(child: tiles[2]),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: tiles[3]),
              const SizedBox(width: 10),
              Expanded(child: tiles[4]),
              const SizedBox(width: 10),
              Expanded(child: tiles[5]),
            ],
          ),
        ],
      ),
    );
  }
}

class _TargetTile extends StatelessWidget {
  const _TargetTile({
    required this.icon,
    required this.tint,
    required this.value,
    required this.unit,
    required this.label,
  });

  final String icon;
  final Color tint;
  final String value;
  final String unit;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 12, 10, 11),
      decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(color: tint, borderRadius: BorderRadius.circular(7)),
            child: Center(child: SvgPicture.asset('assets/icons/$icon.svg', width: 16, height: 16)),
          ),
          const SizedBox(height: 9),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(value, style: AppText.title2.copyWith(fontSize: 19), maxLines: 1),
              ),
              const SizedBox(width: 2),
              Text(unit, style: AppText.caption2),
            ],
          ),
          const SizedBox(height: 3),
          Text(label, style: AppText.caption2, maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

/// 手掌法：不用称重的每餐份量估算
class _PalmCard extends StatelessWidget {
  const _PalmCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 2),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [AppShadows.card],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text('不用称重的手掌法', style: AppText.subhead.copyWith(fontWeight: FontWeight.w700)),
              const Spacer(),
              Text('每餐用手估算', style: AppText.caption2),
            ],
          ),
          const SizedBox(height: 4),
          for (final p in palmPortions)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  SizedBox(
                    width: 74,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (var i = 0; i < p.circles; i++)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2.5),
                            child: Container(
                              width: p.pill ? 22 : p.circleSize.toDouble(),
                              height: p.pill ? 30 : p.circleSize.toDouble(),
                              decoration: BoxDecoration(
                                color: p.tint,
                                border: Border.all(color: p.color, width: 2),
                                shape: p.pill ? BoxShape.rectangle : BoxShape.circle,
                                borderRadius: p.pill ? BorderRadius.circular(11) : null,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.title,
                            style: AppText.footnote.copyWith(color: AppColors.label, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text(p.detail, style: AppText.caption2),
                      ],
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

/// 执行要点 · 只抓三条
class _TipsCard extends StatelessWidget {
  const _TipsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [AppShadows.card],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text('执行要点 · 只抓三条', style: AppText.subhead.copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 6),
          for (final tip in executionTips)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(color: AppColors.tBlue, shape: BoxShape.circle),
                    child: Center(
                      child: Text('${tip.index}',
                          style: AppText.caption.copyWith(color: AppColors.blue, fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(tip.text,
                        style: AppText.footnote.copyWith(color: AppColors.label, height: 1.55)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
