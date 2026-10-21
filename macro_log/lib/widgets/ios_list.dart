import 'package:flutter/cupertino.dart';

import '../theme/app_theme.dart';

/// iOS 分组列表容器（白色圆角卡片 + 0.5px 分割线）
class IosGroup extends StatelessWidget {
  const IosGroup({super.key, required this.children, this.margin = const EdgeInsets.symmetric(horizontal: 16)});

  final List<Widget> children;
  final EdgeInsets margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0)
              const Divider(height: 0.5, thickness: 0.5, color: AppColors.separator, indent: 14),
            children[i],
          ],
        ],
      ),
    );
  }
}

/// iOS 列表行（可点击）
class IosRow extends StatelessWidget {
  const IosRow({super.key, required this.child, this.onTap, this.padding});

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      child: child,
    );
    if (onTap == null) return content;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: content,
    );
  }
}

/// iOS 分段控件（选中项白底 + 轻投影，带过渡动画）
class IosSegmented extends StatelessWidget {
  const IosSegmented({
    super.key,
    required this.labels,
    required this.index,
    required this.onChanged,
  });

  final List<String> labels;
  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(color: AppColors.track, borderRadius: BorderRadius.circular(9)),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: i == index ? AppColors.card : AppColors.transparent,
                    borderRadius: BorderRadius.circular(7),
                    boxShadow: i == index ? const [AppShadows.seg] : null,
                  ),
                  child: Text(
                    labels[i],
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: i == index ? AppColors.label : AppColors.label2,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// 右侧箭头（iOS 列表标准）
class IosChevron extends StatelessWidget {
  const IosChevron({super.key});

  @override
  Widget build(BuildContext context) {
    return const Icon(CupertinoIcons.chevron_right, size: 15, color: AppColors.label3);
  }
}
