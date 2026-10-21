# 宏量记 MacroLog

每日宏量 · 减脂计划 App —— 把你的《每日宏量计划》变成每天可打卡的仪表盘。

**风格**：苹果设计规范（iOS Human Interface Guidelines）：大标题导航、分组卡片、系统配色、底部标签栏、半屏弹层。
**技术**：Flutter 跨端（一套代码同时打包 Android APK / iOS IPA）+ 本地 SQLite（无需联网、无需登录）。

## 功能（V1）

| 页面 | 功能 |
| --- | --- |
| 今天 | 热量圆环（剩余大卡）、蛋白质/碳水/脂肪进度条、饮水打卡（+250ml）、今日餐食状态、每日执行提示 |
| 记录 | 按早餐/午餐/晚餐/加餐记录食物（增/删）、「每餐 30–40g 蛋白质组合」一键记录、底部实时合计 |
| 计划 | 每日目标值（热量/蛋白/碳水/脂肪/纤维/饮水）、不用称重的手掌法、执行要点三条、男/女方案切换 |
| 我的 | 体重趋势图 + 82kg 目标进度、连续打卡、每周复盘（体重/腰围/训练完成率）、默认方案切换 |

数据全部来自计划文件《每日宏量计划-减脂82kg.md》：
- 方案一 · 男：2,330 千卡 / 蛋白 164g / 碳水 273g / 脂肪 65g / 纤维 33g / 饮水 2,870ml
- 方案二 · 女：2,030 千卡 / 蛋白 164g / 碳水 216g / 脂肪 56g / 纤维 28g / 饮水 2,870ml

## 目录结构

```
macro_log/
├── pubspec.yaml                     # 依赖配置（sqflite / provider / flutter_svg）
├── lib/
│   ├── main.dart                    # 入口：开数据库 + 注入全局状态
│   ├── app.dart                     # CupertinoApp 主题 + 底部标签栏
│   ├── theme/
│   │   └── app_theme.dart           # 颜色 / 字号 / 阴影（设计规范集中地）
│   ├── models/
│   │   ├── food_entry.dart          # 饮食记录 + 餐段定义
│   │   ├── plan_scheme.dart         # 方案数据 / 手掌法 / 蛋白质组合 / 执行要点
│   │   └── weight_point.dart        # 体重记录 + 每周复盘
│   ├── data/
│   │   ├── db_helper.dart           # SQLite 建库建表
│   │   └── repositories.dart        # 数据仓库（增删查改）
│   ├── state/
│   │   ├── plan_controller.dart     # 男/女方案状态（本地持久化）
│   │   ├── today_controller.dart    # 今日记录/合计/饮水
│   │   └── profile_controller.dart  # 体重/打卡/复盘
│   ├── widgets/
│   │   ├── calorie_ring.dart        # 热量圆环（CustomPaint）
│   │   ├── macro_progress.dart      # 宏量进度条
│   │   ├── water_card.dart          # 饮水打卡卡
│   │   ├── ios_list.dart            # iOS 分组列表 / 分段控件
│   │   ├── sheet_frame.dart         # 半屏弹层公共框架
│   │   ├── sheet_field.dart         # 弹层表单输入框
│   │   ├── add_food_sheet.dart      # 添加食物
│   │   ├── record_weight_sheet.dart # 记录体重
│   │   └── review_sheet.dart        # 每周复盘
│   └── pages/
│       ├── today_page.dart          # 今天（首页）
│       ├── record_page.dart         # 记录
│       ├── plan_page.dart           # 计划
│       └── profile_page.dart        # 我的
├── assets/icons/                    # 15 个 SVG 图标（宏量/餐段/复盘）
└── docs/
    ├── 打包指南-Android.md           # APK 打包 + 签名
    └── 打包指南-iOS.md               # IPA 打包 + TestFlight
```

分层说明：`pages/` 只负责界面；`state/` 管业务逻辑与状态；`data/` 管本地存储；改数据不用动页面。

## 快速开始

```bash
# 1. 安装 Flutter SDK（≥ 3.22）：https://docs.flutter.dev/get-started/install
# 2. 生成本项目缺失的平台目录（android/ ios/），不会覆盖 lib/ 与 pubspec.yaml
cd macro_log
flutter create . --org com.example --project-name macro_log

# 3. 装依赖并运行
flutter pub get
flutter run          # 连接真机或模拟器
```

> `flutter create .` 会生成 `android/` 与 `ios/` 平台工程和默认的 `test/widget_test.dart`（示例测试，可删除）。

## 打包

- Android APK：见 [docs/打包指南-Android.md](docs/打包指南-Android.md)
- iOS IPA：见 [docs/打包指南-iOS.md](docs/打包指南-iOS.md)（需要 macOS + 苹果开发者证书）

## 版本规划

- **V1（本版）**：纯本地、4 页面、核心记录闭环
- **V2**：自定义食物库与收藏、条码扫描、周/月趋势图表、训练记录、餐间提醒通知
- **V3**：云同步多设备、Apple Health 同步、手表端、按身高年龄性别自动校准目标
