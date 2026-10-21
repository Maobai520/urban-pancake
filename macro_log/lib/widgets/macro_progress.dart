import 'package:flutter/cupertino.dart';

import '../theme/app_theme.dart';
import '../utils/format.dart';

/// 宏量进度条：图标 + 名称 + 数值 + 进度 + 剩余提示
class MacroProgress extends StatelessWidget {
  const MacroProgress({
    super.key,
    required this.name,
    required this.value,
    required this.target,
    required this.color,
    required this.tint,
    required this.icon,
    this.note,
  });

  final String name;
  final int value;
  final int target;
  final Color color;
  final Color tint;
  final Widget icon;
  final String? note; // 自定义提示（如“已超出，晚餐少油”）

  @override
  Widget build(BuildContext context) {
    final remain = target - value;
    final progress = target <= 0 ? 0.0 : (value / target).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(color: tint, borderRadius: BorderRadius.circular(7)),
                child: Center(child: icon),
              ),
              const SizedBox(width: 8),
              Text(name, style: AppText.subhead.copyWith(fontWeight: FontWeight.w600)),
              const Spacer(),
              Text(fmtInt(value), style: AppText.subhead.copyWith(fontWeight: FontWeight.w600)),
              Text(' / $target g', style: AppText.footnote),
            ],
          ),
          const SizedBox(height: 7),
          _ProgressBar(progress: progress, color: color),
          const SizedBox(height: 5),
          Text(
            note ?? (remain >= 0 ? '还剩 $remain g' : '已超出 ${-remain} g'),
            style: AppText.caption2,
          ),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Stack(
        children: [
          Container(height: 8, color: AppColors.track),
          FractionallySizedBox(
            widthFactor: progress.clamp(0.0, 1.0),
            child: Container(height: 8, color: color),
          ),
        ],
      ),
    );
  }
}
