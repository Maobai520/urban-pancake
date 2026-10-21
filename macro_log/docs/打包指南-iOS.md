# 宏量记 · iOS IPA 本地打包指南

> 需要：**macOS 电脑 + Xcode + 苹果开发者账号**。安卓 APK 可以直接安装；iOS 不一样，IPA 需要苹果签名才能装到手机上。
> 免费 Apple ID 也能打包（真机调试 / Ad Hoc，有效期 7 天）；上架 App Store 需要付费开发者账号（$99/年）。

## 一、环境准备（macOS）

1. 安装 **Xcode 15+**（App Store）。
2. 安装 **CocoaPods**（iOS 依赖管理）：

```bash
sudo gem install cocoapods
```

3. 安装 Flutter SDK 并检查：

```bash
flutter doctor
```

iOS 项需要 Xcode 全部打勾。

## 二、生成平台目录（一次性）

```bash
cd macro_log
flutter create . --org com.example --project-name macro_log
flutter pub get
```

会在 `ios/` 生成 Runner 工程。改 App 显示名称：Xcode 里改 `Runner → Info → Bundle display name`（或 `ios/Runner/Info.plist` 的 `CFBundleDisplayName`）。改 Bundle ID：Xcode → Runner → Signing & Capabilities → Bundle Identifier（如 `com.hongliang.macrolog`）。

## 三、真机调试（先验证 App 能跑）

```bash
flutter run            # 插上 iPhone，按提示信任开发者
```

首次运行 Xcode 可能要求输入 Apple ID 登录（Xcode → Settings → Accounts）。

## 四、打包 IPA

**方式 A：Xcode Archive（推荐，可同时上架 TestFlight / App Store）**

```bash
flutter build ios --release
open ios/Runner.xcworkspace      # 注意是 xcworkspace，不是 xcodeproj
```

1. Xcode 顶部设备选 **Any iOS Device**。
2. 菜单 **Product → Archive**。
3. 归档完成后自动打开 Organizer：
   - **Distribute App** → 选 `Ad Hoc` / `Development`（导出 .ipa 给测试机）
   - 选 `App Store Connect`（上传到 TestFlight / 上架）
   - 选 `Debug` 不选证书导出也可以得到 .ipa 文件
4. 按向导导出，得到 `宏量记.ipa`。

**方式 B：命令行导出 ipa**

```bash
flutter build ipa --release
```

产物默认在 `build/ios/ipa/`。需要已配置好签名（Xcode 里先选好 Team 并勾选 Automatically manage signing）。

## 五、安装到手机

| 场景 | 方法 |
| --- | --- |
| 自己调试 | 数据线 + Xcode 直接 Run；或 `flutter install` |
| 分发测试机 | 导出 .ipa 后用 **Apple Configurator 2** 或第三方工具（如 Sideloadly）安装；设备的 UDID 需加入描述文件 |
| 大规模测试 | 上传 TestFlight（Transporter 或 Xcode Organizer），受邀用户通过 TestFlight App 安装 |

## 六、高频报错排查

| 报错 | 原因 / 解决 |
| --- | --- |
| `CocoaPods not installed` | `sudo gem install cocoapods`，然后 `cd ios && pod install` |
| `Module 'xxx' not found` | `cd ios`，删 `Pods/`、`Podfile.lock`，再 `pod install` |
| `No profiles for 'xxx' were found` | Xcode → Runner → Signing & Capabilities → 勾选 Automatically manage signing，选你的 Team；或去开发者后台建描述文件 |
| `Provisioning profile 与证书不匹配` | 删 Xcode 里的旧证书/描述文件（Xcode → Settings → Accounts → Manage Certificates），重新登录 |
| `Code signing is required` | 免费账号也要选 Team；真机调试包依赖本地签名 |
| Archive 按钮灰着 | 设备选成了模拟器，改 **Any iOS Device** |
| 7 天后 App 打不开 | 免费证书有效期 7 天，重签重装；长期用需付费账号 |

## 七、说明

- iOS 侧没有「直接装 apk 文件」这种好事：**必须签名**。免费 Apple ID 签名 7 天过期，付费账号 Ad Hoc 1 年。
- 本指南只做**本地打包与测试分发**；App Store 上架（审核、隐私政策、截图等）不在本范围内。
- 上架 TestFlight 需在 App Store Connect 建 App 记录，用 Xcode 或 Transporter 上传构建版本。
