import 'package:flutter/cupertino.dart';

/// 苹果风格设计规范（iOS Human Interface Guidelines · 浅色模式）
/// 颜色 / 字体 / 阴影集中在这里，全 App 统一调用
class AppColors {
  AppColors._();

  // 背景与文字
  static const bg = Color(0xFFF2F2F7); // 系统分组背景
  static const barBg = Color(0xF8FFFFFF); // 导航 / 标签栏底色（近似毛玻璃）
  static const card = Color(0xFFFFFFFF);
  static const white = Color(0xFFFFFFFF);
  static const transparent = Color(0x00000000);
  static const label = Color(0xFF000000);
  static const label2 = Color(0x993C3C43); // rgba(60,60,67,.6)
  static const label3 = Color(0x4D3C3C43); // rgba(60,60,67,.3)
  static const separator = Color(0x213C3C43); // rgba(60,60,67,.13) 分割线
  static const track = Color(0x1F787880); // rgba(120,120,128,.12) 进度条轨道
  static const gray = Color(0xFF8E8E93);
  static const dark = Color(0xFF1C1C1E);

  // iOS 系统色
  static const blue = Color(0xFF007AFF);
  static const green = Color(0xFF34C759);
  static const orange = Color(0xFFFF9500);
  static const pink = Color(0xFFFF2D55);
  static const purple = Color(0xFFAF52DE);
  static const teal = Color(0xFF30B0C7);
  static const yellow = Color(0xFFFFCC00);
  static const indigo = Color(0xFF5856D6);
  static const red = Color(0xFFFF3B30);

  // 宏量配色（与设计原型一致）
  static const cKcal = pink;
  static const cProtein = green;
  static const cCarbs = blue;
  static const cFat = orange;
  static const cFiber = purple;
  static const cWater = teal;

  // 图标浅色底（小方块背景）
  static const tGreen = Color(0xFFE4F8EA);
  static const tBlue = Color(0xFFE3F0FF);
  static const tOrange = Color(0xFFFFF3E0);
  static const tTeal = Color(0xFFE2F5F8);
  static const tPink = Color(0xFFFFE9EE);
  static const tPurple = Color(0xFFF1EBFA);
  static const tYellow = Color(0xFFFFF8DB);
  static const tIndigo = Color(0xFFECECF9);
  static const tGray = Color(0xFFEFEFF4);
}

/// 卡片阴影（很淡，接近 iOS 原生观感）
class AppShadows {
  AppShadows._();
  static const card = BoxShadow(color: Color(0x05000000), blurRadius: 6, offset: Offset(0, 1));
  static const seg = BoxShadow(color: Color(0x24000000), blurRadius: 3, offset: Offset(0, 1));
}

/// 字号规范（对齐 iOS 文本样式）
class AppText {
  AppText._();

  static const navLarge = TextStyle(fontSize: 34, fontWeight: FontWeight.w700, letterSpacing: -0.4, color: AppColors.label);
  static const navTitle = TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.label);
  static const title2 = TextStyle(fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: -0.2, color: AppColors.label);
  static const headline = TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.label);
  static const body = TextStyle(fontSize: 17, color: AppColors.label);
  static const callout = TextStyle(fontSize: 16, color: AppColors.label);
  static const subhead = TextStyle(fontSize: 15, color: AppColors.label);
  static const footnote = TextStyle(fontSize: 13, color: AppColors.label2);
  static const caption = TextStyle(fontSize: 12, color: AppColors.label2);
  static const caption2 = TextStyle(fontSize: 11, color: AppColors.label2);
}
