import 'package:flutter/cupertino.dart';

import 'pages/plan_page.dart';
import 'pages/profile_page.dart';
import 'pages/record_page.dart';
import 'pages/today_page.dart';
import 'theme/app_theme.dart';

/// 应用根组件：Cupertino（iOS）风格主题
class MacroLogApp extends StatelessWidget {
  const MacroLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: '宏量记',
      debugShowCheckedModeBanner: false,
      theme: CupertinoThemeData(
        primaryColor: AppColors.blue,
        scaffoldBackgroundColor: AppColors.bg,
        barBackgroundColor: AppColors.barBg,
        textTheme: CupertinoTextThemeData(
          primaryColor: AppColors.label,
          textStyle: AppText.body,
          navLargeTitleTextStyle: AppText.navLarge,
          navTitleTextStyle: AppText.navTitle,
        ),
      ),
      home: const MainTab(),
    );
  }
}

/// 底部四个标签栏：今天 / 记录 / 计划 / 我的
class MainTab extends StatelessWidget {
  const MainTab({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        backgroundColor: AppColors.barBg,
        activeColor: AppColors.blue,
        inactiveColor: AppColors.label3,
        items: const [
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.home), label: '今天'),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.plus_circled), label: '记录'),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.book), label: '计划'),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.person), label: '我的'),
        ],
      ),
      tabBuilder: (context, index) {
        return CupertinoTabView(
          builder: (context) {
            switch (index) {
              case 1:
                return const RecordPage();
              case 2:
                return const PlanPage();
              case 3:
                return const ProfilePage();
              default:
                return const TodayPage();
            }
          },
        );
      },
    );
  }
}
