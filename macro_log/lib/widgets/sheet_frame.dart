import 'package:flutter/cupertino.dart';

import '../theme/app_theme.dart';

/// 半屏弹层（Sheet）公共框架：拖动条 + 标题行 + 内容
class SheetFrame extends StatelessWidget {
  const SheetFrame({
    super.key,
    required this.title,
    required this.onCancel,
    required this.onSave,
    required this.saveLabel,
    required this.child,
  });

  final String title;
  final VoidCallback onCancel;
  final VoidCallback onSave;
  final String saveLabel;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.92),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 拖动条
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  width: 36,
                  height: 5,
                  decoration: BoxDecoration(color: AppColors.track, borderRadius: BorderRadius.circular(3)),
                ),
                // 标题行
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Row(
                    children: [
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        minSize: 32,
                        onPressed: onCancel,
                        child: Text('取消', style: AppText.callout.copyWith(color: AppColors.blue)),
                      ),
                      Expanded(
                        child: Text(title, textAlign: TextAlign.center, style: AppText.headline),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        minSize: 32,
                        onPressed: onSave,
                        child: Text(saveLabel,
                            style: AppText.callout.copyWith(color: AppColors.blue, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 0.5, thickness: 0.5, color: AppColors.separator),
                Flexible(child: SingleChildScrollView(child: child)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
