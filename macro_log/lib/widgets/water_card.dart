import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_theme.dart';
import '../utils/format.dart';

/// 饮水打卡卡片
class WaterCard extends StatelessWidget {
  const WaterCard({
    super.key,
    required this.ml,
    required this.target,
    required this.onAdd,
  });

  final int ml;
  final int target;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final progress = target <= 0 ? 0.0 : (ml / target).clamp(0.0, 1.0);
    final percent = (progress * 100).round();

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
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(color: AppColors.tTeal, borderRadius: BorderRadius.circular(7)),
                child: Center(
                  child: SvgPicture.asset('assets/icons/drop.svg', width: 16, height: 16),
                ),
              ),
              const SizedBox(width: 10),
              Text('饮水', style: AppText.subhead.copyWith(fontWeight: FontWeight.w700)),
              const Spacer(),
              Text(fmtInt(ml), style: AppText.subhead.copyWith(fontWeight: FontWeight.w700)),
              Text(' / ${fmtInt(target)} ml', style: AppText.footnote),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Stack(
              children: [
                Container(height: 8, color: AppColors.track),
                FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(height: 8, color: AppColors.cWater),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text('已完成 $percent%', style: AppText.caption),
              const Spacer(),
              GestureDetector(
                onTap: onAdd,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(color: AppColors.cWater, borderRadius: BorderRadius.circular(999)),
                  child: Text('＋ 250 ml',
                      style: AppText.caption.copyWith(color: AppColors.white, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
