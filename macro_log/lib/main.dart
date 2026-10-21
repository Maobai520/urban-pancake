import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'data/db_helper.dart';
import 'data/repositories.dart';
import 'state/plan_controller.dart';
import 'state/profile_controller.dart';
import 'state/today_controller.dart';

/// 入口：先打开本地数据库，再注入三个全局状态
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 本地 SQLite（无需联网、无需登录，断网可用）
  final db = await AppDatabase.open();
  final repos = AppRepository(db);

  runApp(
    MultiProvider(
      providers: [
        // 计划方案（男 / 女目标值，选择结果本地持久化）
        ChangeNotifierProvider(create: (_) => PlanController(repos)..load()),
        // 今日数据（饮食记录 / 宏量合计 / 饮水）
        ChangeNotifierProvider(
          create: (ctx) => TodayController(repos, ctx.read<PlanController>())..load(),
        ),
        // 我的（体重趋势 / 连续打卡 / 每周复盘）
        ChangeNotifierProvider(create: (_) => ProfileController(repos)..load()),
      ],
      child: const MacroLogApp(),
    ),
  );
}
