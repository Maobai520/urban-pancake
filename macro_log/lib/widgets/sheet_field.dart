import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';

/// 弹层表单字段：标签 + iOS 风格输入框
class SheetField extends StatelessWidget {
  const SheetField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.numeric = false,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final bool numeric;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppText.caption),
          const SizedBox(height: 5),
          CupertinoTextField(
            controller: controller,
            placeholder: hint,
            keyboardType:
                numeric ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
            style: AppText.subhead,
            placeholderStyle: AppText.caption,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(10)),
          ),
        ],
      ),
    );
  }
}
