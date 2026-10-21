import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../models/plan_scheme.dart';
import '../models/weight_point.dart';
import '../state/plan_controller.dart';
import '../state/profile_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/ios_list.dart';
import '../widgets/record_weight_sheet.dart';
import '../widgets/review_sheet.dart';

/// 我的页：体重趋势与 82kg 进度 / 连续打卡 / 每周复盘 / 设置
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileController>();
    final plan = context.watch<PlanController>();

    return CupertinoPageScaffold(
      child: CustomScrollView(
        slivers: [
          const CupertinoSliverNavigationBar(largeTitle: Text('我的')),
          SliverToBoxAdapter(child: _WeightCard(profile: profile)),
          SliverToBoxAdapter(child: _ReviewCard(profile: profile)),
          SliverToBoxAdapter(
            child: IosGroup(
              children: [
                IosRow(
                  child: _SetRow(
                    glyph: '身',
                    tint: AppColors.tGray,
                    title: '身体数据',
                    subtitle: '用于校准每日目标',
                    value: '175cm · 30岁 · 男',
                  ),
                ),
                IosRow(
                  onTap: () => _pickScheme(context, plan),
                  child: _SetRow(
                    glyph: '案',
                    tint: AppColors.tBlue,
                    title: '默认方案',
                    subtitle: '打开 App 默认展示',
                    value: plan.scheme.label,
                  ),
                ),
                IosRow(
                  child: _SetRow(
                    glyph: '铃',
                    tint: AppColors.tOrange,
                    title: '提醒',
                    subtitle: '餐间打卡提醒',
                    value: 'V2 上线',
                  ),
                ),
                IosRow(
                  child: _SetRow(
                    glyph: '位',
                    tint: AppColors.tTeal,
                    title: '单位',
                    subtitle: '重量与容量',
                    value: '公制',
                  ),
                ),
              ],
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 28)),
        ],
      ),
    );
  }

  /// 切换默认方案（底部操作表）
  Future<void> _pickScheme(BuildContext context, PlanController plan) async {
    await showCupertinoActionSheet(
      context: context,
      actions: [
        CupertinoActionSheetAction(
          onPressed: () {
            plan.select(PlanScheme.male);
            Navigator.pop(context);
          },
          child: const Text('方案一 · 男'),
        ),
        CupertinoActionSheetAction(
          onPressed: () {
            plan.select(PlanScheme.female);
            Navigator.pop(context);
          },
          child: const Text('方案二 · 女'),
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        onPressed: () => Navigator.pop(context),
        child: const Text('取消'),
      ),
    );
  }
}

/// 体重卡片：当前体重 + 趋势图 + 82kg 进度 + 连续打卡
class _WeightCard extends StatelessWidget {
  const _WeightCard({required this.profile});

  final ProfileController profile;

  @override
  Widget build(BuildContext context) {
    final cur = profile.currentKg;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [AppShadows.card],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(cur == null ? '—' : cur.toStringAsFixed(1),
                      style: AppText.navLarge.copyWith(fontSize: 34)),
                  const SizedBox(height: 5),
                  Text('当前体重 · 晨起空腹', style: AppText.caption),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(color: AppColors.tGreen, borderRadius: BorderRadius.circular(10)),
                child: Column(
                  children: [
                    Text('目标', style: AppText.caption2),
                    Text('82 kg',
                        style: AppText.subhead.copyWith(color: const Color(0xFF1F9D45), fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(height: 62, child: _Sparkline(points: profile.weights)),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Stack(
              children: [
                Container(height: 8, color: AppColors.track),
                FractionallySizedBox(
                  widthFactor: profile.goalProgress,
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.green, Color(0xFF63DD8B)],
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text('还需减 ${profile.remainKg.toStringAsFixed(1)} kg', style: AppText.caption),
              const Spacer(),
              Row(
                children: [
                  SvgPicture.asset('assets/icons/flame.svg', width: 12, height: 12),
                  const SizedBox(width: 5),
                  Text('连续打卡 ${profile.streakDays} 天',
                      style: AppText.caption.copyWith(color: AppColors.orange, fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () {
              showCupertinoModalPopup(
                context: context,
                builder: (_) => RecordWeightSheet(
                  onSave: (kg) => context.read<ProfileController>().saveWeight(kg),
                ),
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(color: AppColors.blue, borderRadius: BorderRadius.circular(12)),
              child: Center(
                child: Text('记录体重',
                    style: AppText.subhead.copyWith(color: AppColors.white, fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 体重趋势迷你图
class _Sparkline extends StatelessWidget {
  const _Sparkline({required this.points});

  final List<WeightPoint> points;

  @override
  Widget build(BuildContext context) {
    if (points.length < 2) {
      return Center(child: Text('记录体重后显示趋势', style: AppText.caption));
    }
    return CustomPaint(
      painter: _SparkPainter(
        values: points.map((e) => e.kg).toList(),
        goal: goalWeightKg,
      ),
      size: Size.infinite,
    );
  }
}

class _SparkPainter extends CustomPainter {
  _SparkPainter({required this.values, required this.goal});

  final List<double> values;
  final double goal;

  @override
  void paint(Canvas canvas, Size size) {
    final all = [...values, goal];
    var minV = all.reduce((a, b) => a < b ? a : b);
    var maxV = all.reduce((a, b) => a > b ? a : b);
    if (maxV - minV < 0.5) maxV = minV + 0.5;

    const pad = 7.0;
    double yOf(double v) => pad + (maxV - v) / (maxV - minV) * (size.height - pad * 2);
    double xOf(int i) => i / (values.length - 1) * size.width;

    // 目标参考线
    final goalY = yOf(goal);
    canvas.drawLine(
      Offset(0, goalY),
      Offset(size.width, goalY),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = AppColors.label3,
    );

    // 趋势线
    final line = Path();
    for (var i = 0; i < values.length; i++) {
      final x = xOf(i);
      final y = yOf(values[i]);
      i == 0 ? line.moveTo(x, y) : line.lineTo(x, y);
    }
    canvas.drawPath(
      line,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = AppColors.cProtein,
    );

    // 最新点
    final last = Offset(xOf(values.length - 1), yOf(values.last));
    canvas.drawCircle(last, 4.5, Paint()..color = AppColors.white);
    canvas.drawCircle(
      last,
      4.5,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..color = AppColors.cProtein,
    );
  }

  @override
  bool shouldRepaint(_SparkPainter old) => !listEquals(old.values, values) || old.goal != goal;
}

/// 每周复盘卡片
class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.profile});

  final ProfileController profile;

  @override
  Widget build(BuildContext context) {
    final r = profile.latestReview;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [AppShadows.card],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text('每周复盘', style: AppText.subhead.copyWith(fontWeight: FontWeight.w700)),
              const Spacer(),
              Text('每周固定一天', style: AppText.caption2),
            ],
          ),
          const SizedBox(height: 4),
          _ReviewRow(
            icon: 'scale',
            tint: AppColors.tPink,
            title: '晨起空腹体重',
            value: r?.weightKg != null ? '${r!.weightKg!.toStringAsFixed(1)} kg' : '待记录',
          ),
          _ReviewRow(
            icon: 'ruler',
            tint: AppColors.tIndigo,
            title: '腰围',
            value: r?.waistCm != null ? '${r!.waistCm!.toStringAsFixed(1)} cm' : '待测量',
          ),
          _ReviewRow(
            icon: 'dumbbell',
            tint: AppColors.tGreen,
            title: '训练完成率',
            value: r?.trainingDone != null && r?.trainingTotal != null
                ? '${r!.trainingDone} / ${r!.trainingTotal} 次'
                : '待记录',
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              '体重掉太快（＞1%/周）加主食 30–50g；连续 2 周没变化，先查执行率和步数，再减 100–150 大卡。',
              style: AppText.caption2.copyWith(height: 1.6),
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              showCupertinoModalPopup(
                context: context,
                builder: (_) => ReviewSheet(
                  initial: profile.latestReview,
                  onSave: (weight, waist, done, total) => context
                      .read<ProfileController>()
                      .saveReview(weightKg: weight, waistCm: waist, trainingDone: done, trainingTotal: total),
                ),
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 11),
              decoration: BoxDecoration(color: AppColors.tBlue, borderRadius: BorderRadius.circular(12)),
              child: Center(
                child: Text('更新每周复盘',
                    style: AppText.subhead.copyWith(color: AppColors.blue, fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({
    required this.icon,
    required this.tint,
    required this.title,
    required this.value,
  });

  final String icon;
  final Color tint;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(color: tint, borderRadius: BorderRadius.circular(7)),
            child: Center(child: SvgPicture.asset('assets/icons/$icon.svg', width: 16, height: 16)),
          ),
          const SizedBox(width: 11),
          Text(title, style: AppText.footnote.copyWith(color: AppColors.label, fontWeight: FontWeight.w600)),
          const Spacer(),
          Text(value, style: AppText.footnote),
        ],
      ),
    );
  }
}

/// 设置行（文字图标 + 标题 + 副标题 + 右侧值）
class _SetRow extends StatelessWidget {
  const _SetRow({
    required this.glyph,
    required this.tint,
    required this.title,
    required this.subtitle,
    required this.value,
  });

  final String glyph;
  final Color tint;
  final String title;
  final String subtitle;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(color: tint, borderRadius: BorderRadius.circular(7)),
          child: Center(
            child: Text(glyph,
                style: AppText.caption.copyWith(color: AppColors.label, fontWeight: FontWeight.w700)),
          ),
        ),
        const SizedBox(width: 11),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppText.subhead.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(subtitle, style: AppText.caption2),
          ],
        ),
        const Spacer(),
        Text(value, style: AppText.footnote),
        const SizedBox(width: 4),
        const IosChevron(),
      ],
    );
  }
}
