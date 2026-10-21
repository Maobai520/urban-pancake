import 'package:flutter/cupertino.dart';

import '../models/weight_point.dart';
import '../theme/app_theme.dart';
import '../widgets/sheet_field.dart';
import '../widgets/sheet_frame.dart';

/// 「每周复盘」半屏弹层：晨起空腹体重 / 腰围 / 训练完成率
class ReviewSheet extends StatefulWidget {
  const ReviewSheet({super.key, required this.initial, required this.onSave});

  final WeeklyReview? initial;
  final void Function(double? weightKg, double? waistCm, int? done, int? total) onSave;

  @override
  State<ReviewSheet> createState() => _ReviewSheetState();
}

class _ReviewSheetState extends State<ReviewSheet> {
  final _weightC = TextEditingController();
  final _waistC = TextEditingController();
  final _doneC = TextEditingController();
  final _totalC = TextEditingController();

  @override
  void initState() {
    super.initState();
    final r = widget.initial;
    if (r != null) {
      if (r.weightKg != null) _weightC.text = r.weightKg!.toStringAsFixed(1);
      if (r.waistCm != null) _waistC.text = r.waistCm!.toStringAsFixed(1);
      if (r.trainingDone != null) _doneC.text = '${r.trainingDone}';
      if (r.trainingTotal != null) _totalC.text = '${r.trainingTotal}';
    }
  }

  @override
  void dispose() {
    _weightC.dispose();
    _waistC.dispose();
    _doneC.dispose();
    _totalC.dispose();
    super.dispose();
  }

  void _save() {
    final weight = double.tryParse(_weightC.text.trim());
    final waist = double.tryParse(_waistC.text.trim());
    final done = int.tryParse(_doneC.text.trim());
    final total = int.tryParse(_totalC.text.trim());
    if (weight == null && waist == null && done == null) {
      _showError('至少填写一项：体重 / 腰围 / 训练次数');
      return;
    }
    widget.onSave(weight, waist, done, total);
    Navigator.pop(context);
  }

  void _showError(String message) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('还没填好'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(onPressed: () => Navigator.pop(ctx), child: const Text('好')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SheetFrame(
      title: '更新每周复盘',
      onCancel: () => Navigator.pop(context),
      onSave: _save,
      saveLabel: '保存',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 26),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: SheetField(label: '晨起空腹体重（kg）', controller: _weightC, numeric: true)),
                const SizedBox(width: 10),
                Expanded(child: SheetField(label: '腰围（cm）', controller: _waistC, numeric: true)),
              ],
            ),
            Row(
              children: [
                Expanded(child: SheetField(label: '训练完成（次）', controller: _doneC, numeric: true)),
                const SizedBox(width: 10),
                Expanded(child: SheetField(label: '训练计划（次）', controller: _totalC, numeric: true)),
              ],
            ),
            const SizedBox(height: 4),
            Text('体重掉太快（＞1%/周）加主食 30–50g；连续 2 周没变化，先查执行率和步数，再减 100–150 大卡。',
                style: AppText.caption2.copyWith(height: 1.6)),
          ],
        ),
      ),
    );
  }
}
