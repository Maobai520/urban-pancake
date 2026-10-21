import 'package:flutter/cupertino.dart';

import '../models/food_entry.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/ios_list.dart';
import '../widgets/sheet_field.dart';
import '../widgets/sheet_frame.dart';

/// 「添加食物」半屏弹层
class AddFoodSheet extends StatefulWidget {
  const AddFoodSheet({super.key, required this.meal, required this.onSave});

  final int meal; // 默认餐段
  final ValueChanged<FoodEntry> onSave;

  @override
  State<AddFoodSheet> createState() => _AddFoodSheetState();
}

class _AddFoodSheetState extends State<AddFoodSheet> {
  late int _meal = widget.meal;

  final _nameC = TextEditingController();
  final _portionC = TextEditingController();
  final _kcalC = TextEditingController();
  final _proteinC = TextEditingController();
  final _carbsC = TextEditingController();
  final _fatC = TextEditingController();

  @override
  void dispose() {
    _nameC.dispose();
    _portionC.dispose();
    _kcalC.dispose();
    _proteinC.dispose();
    _carbsC.dispose();
    _fatC.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameC.text.trim();
    if (name.isEmpty) {
      _showError('请填写食物名称');
      return;
    }
    final kcal = double.tryParse(_kcalC.text.trim());
    if (kcal == null || kcal < 0) {
      _showError('请填写正确的热量（千卡）');
      return;
    }
    final entry = FoodEntry(
      name: name,
      portion: _portionC.text.trim().isEmpty ? '1 份' : _portionC.text.trim(),
      meal: _meal,
      kcal: kcal,
      protein: double.tryParse(_proteinC.text.trim()) ?? 0,
      carbs: double.tryParse(_carbsC.text.trim()) ?? 0,
      fat: double.tryParse(_fatC.text.trim()) ?? 0,
      date: dateKeyOf(DateTime.now()),
      createdAt: DateTime.now(),
    );
    widget.onSave(entry);
    Navigator.pop(context);
  }

  void _showError(String message) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('还没填好'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('好'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SheetFrame(
      title: '添加食物',
      onCancel: () => Navigator.pop(context),
      onSave: _save,
      saveLabel: '保存',
      child: Column(
        children: [
          const SizedBox(height: 12),
          IosSegmented(
            labels: mealNames,
            index: _meal,
            onChanged: (i) => setState(() => _meal = i),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
            SheetField(label: '名称', hint: '如：清蒸鲈鱼', controller: _nameC),
            SheetField(label: '份量', hint: '如：150 g / 1 拳', controller: _portionC),
            Row(
              children: [
                Expanded(child: SheetField(label: '热量（千卡）', controller: _kcalC, numeric: true)),
                const SizedBox(width: 10),
                Expanded(child: SheetField(label: '蛋白质（g）', controller: _proteinC, numeric: true)),
              ],
            ),
            Row(
              children: [
                Expanded(child: SheetField(label: '碳水（g）', controller: _carbsC, numeric: true)),
                const SizedBox(width: 10),
                Expanded(child: SheetField(label: '脂肪（g）', controller: _fatC, numeric: true)),
              ],
            ),
                const SizedBox(height: 4),
                Text('不知道具体数值时，宏量可以只填蛋白质，其余填 0。', style: AppText.caption2),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
