# 宏量记 · Android APK 本地打包指南

> 适用：Windows / macOS / Linux。目标：产出可直接安装的 `app-release.apk`，以及可用于应用商店的 `.aab`。

## 一、环境准备

1. **Flutter SDK ≥ 3.22**：https://docs.flutter.dev/get-started/install
   装完把 `flutter/bin` 加进 PATH。
2. **Android Studio**：装 Android SDK、Platform-Tools、Command-line Tools。
3. 检查环境：

```bash
flutter doctor
```

要求 Android toolchain 与 Connected device 两项打勾（设备可在装好驱动后插真机）。

4. 首次使用接受许可：

```bash
flutter doctor --android-licenses
```

## 二、生成平台目录（一次性）

本项目已带 `lib/`、`pubspec.yaml`、`assets/`，但 `android/` 目录需要 Flutter 生成：

```bash
cd macro_log
flutter create . --org com.example --project-name macro_log
flutter pub get
```

> `--org com.example` 决定默认包名 `com.example.macro_log`，可改成你自己的（如 `com.hongliang.macrolog`）。
> 想改应用显示名称：编辑 `android/app/src/main/AndroidManifest.xml` 里的 `android:label`。

## 三、调试运行（可选）

```bash
flutter run                # 自动选设备
flutter run -d <设备ID>    # 指定设备（flutter devices 查看）
```

## 四、打包 Release APK

```bash
flutter build apk --release
```

产物位置：

```
build/app/outputs/flutter-apk/app-release.apk
```

安装到手机：

```bash
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

或把 apk 拷到手机，点击安装（需在系统里允许「安装未知来源应用」）。

> 默认打出来的是「单 ABI」合包，体积略大；想按架构分包（更小）：
> `flutter build apk --release --split-per-abi`

## 五、签名（上架 / 正式分发必做）

调试包用的是调试签名，正式分发请用自己的密钥。

**1）生成密钥库（keystore）**

```bash
keytool -genkey -v -keystore %USERPROFILE%\macro_log.jks ^
  -storetype PKCS12 -keyalg RSA -keysize 2048 -validity 10000 -alias macro_log
```

macOS / Linux 把路径换成 `~/macro_log.jks`。按提示设密码、填姓名/公司等信息，**密码自己保存好，丢了无法找回**。

**2）新建 `android/key.properties`**（不要提交到 Git）：

```properties
storePassword=你的密钥库密码
keyPassword=你的密钥密码
keyAlias=macro_log
storeFile=C:/Users/你的用户名/macro_log.jks
```

**3）改 `android/app/build.gradle`**，在 `android {` 之前加：

```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}
```

在 `android {` 内加签名配置：

```gradle
signingConfigs {
    release {
        keyAlias keystoreProperties['keyAlias']
        keyPassword keystoreProperties['keyPassword']
        storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
        storePassword keystoreProperties['storePassword']
    }
}
buildTypes {
    release {
        signingConfig signingConfigs.release
    }
}
```

**4）重新打包**

```bash
flutter build apk --release
```

**5）应用商店用 AAB**（Google Play 只收 aab）：

```bash
flutter build appbundle --release
```

产物：`build/app/outputs/bundle/release/app-release.aab`

## 六、高频报错排查

| 报错 | 原因 / 解决 |
| --- | --- |
| `cmdline-tools not found` | Android Studio → SDK Manager → SDK Tools → 勾选 **Android SDK Command-line Tools** |
| `Android license not accepted` | 运行 `flutter doctor --android-licenses` 全部选 y |
| `SDK location not found` | 新建 `android/local.properties`，写 `sdk.dir=C\:\\Users\\你\\AppData\\Local\\Android\\Sdk` |
| `Gradle build failed` / `Could not resolve` | 检查网络与代理；先 `flutter clean` 再 `flutter pub get` 重编 |
| 签名 `keystore password was incorrect` | 检查 `key.properties` 密码；`storeFile` 用正斜杠绝对路径 |
| 装 APK 时「解析包错误」 | 手机架构不匹配（如只在 armeabi 设备装 x86 包）；用 `--split-per-abi` 或合包重装 |
| 改包名后 `android` 目录报错 | 全局搜索替换旧包名 `com.example.macro_log`，或重新 `flutter create . --org 新包名` |

## 七、说明

- 本指南只做**本地打包**；应用商店上架（资质、隐私政策、审核）不在本范围内。
- 免费 debug 包也能装，但签名是调试用的，别用于正式分发。
