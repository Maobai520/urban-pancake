import 'package:flutter/foundation.dart';

import '../data/repositories.dart';
import '../models/plan_scheme.dart';

/// 计划方案状态：男 / 女目标值切换，选择结果本地持久化
class PlanController extends ChangeNotifier {
  PlanController(this._repo);

  final AppRepository _repo;

  PlanScheme scheme = PlanScheme.male;

  Future<void> load() async {
    final id = await _repo.setting('scheme');
    scheme = PlanScheme.byId(id ?? 'm');
    notifyListeners();
  }

  Future<void> select(PlanScheme next) async {
    if (next.id == scheme.id) return;
    scheme = next;
    notifyListeners();
    await _repo.setSetting('scheme', next.id);
  }

  bool get isMale => scheme.id == 'm';
}
