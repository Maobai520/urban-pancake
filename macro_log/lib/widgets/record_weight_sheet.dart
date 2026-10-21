import 'package:flutter/cupertino.dart';

import '../theme/app_theme.dart';
import '../widgets/sheet_field.dart';
import '../widgets/sheet_frame.dart';

/// 「记录体重」半屏弹层
class RecordWeightSheet extends StatefulWidget {
  const RecordWeightSheet({super.key, required this.onSave});

  final ValueChanged<double> onSave;

  @override
  State<RecordWeightSheet> createState() => _RecordWeightSheetState();
}

class _RecordWeightSheetState extends State<RecordWeightSheet> {
  final _kgC = TextEditingController();

  @override
  void dispose() {
    _kgC.dispose();
    super.dispose();
  }

  void _save() {
    final kg = double.tryParse(_kgC.text.trim());
    if (kg == null || kg <= 0) {
      _showError('请填写正确的体重（kg）');
      return;
    }
    widget.onSave(kg);
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
      title: '记录体重',
      onCancel: () => Navigator.pop(context),
      onSave: _save,
      saveLabel: '保存',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 26),
        child: Column(
          children: [
            SheetField(label: '体重（kg）', hint: '如：84.6', controller: _kgC, numeric: true),
            const SizedBox(height: 4),
            Text('建议晨起空腹称重，每天同一时间称更有可比性。', style: AppText.caption2),
          ],
        ),
      ),
    );
  }
}
