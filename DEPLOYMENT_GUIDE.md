# JSI Capacitor Android 应用部署指南

本文档详细说明如何使用本项目创建一个加载远程 Web 应用的 Android 应用，以及后续的生成和维护步骤。

## 目录

1. [项目概述](#项目概述)
2. [项目结构详解](#项目结构详解)
3. [环境准备](#环境准备)
4. [配置步骤](#配置步骤)
5. [构建步骤](#构建步骤)
6. [部署步骤](#部署步骤)
7. [维护和更新](#维护和更新)
8. [常见问题解答](#常见问题解答)

---

## 项目概述

本项目使用 Capacitor 框架创建了一个 Android 应用，该应用通过 WebView 加载部署在远程服务器上的 Web 前端项目。这种架构的优势是：

- **无需频繁更新应用**：只需更新服务器上的前端代码，用户打开应用即可看到最新内容
- **跨平台支持**：可以轻松扩展到 iOS 平台
- **原生功能集成**：可以通过 Capacitor 插件访问设备原生功能
- **自动构建**：使用 GitHub Actions 自动化构建和发布流程

---

## 项目结构详解

```
jsi/
│
├── .github/
│   └── workflows/
│       └── build-android.yml          # GitHub Actions 自动构建工作流
│                                       - 定义了构建触发条件
│                                       - 配置了构建环境
│                                       - 自动上传 APK 到 Releases
│
├── android/                            # Android 原生项目
│   │
│   ├── app/                            # 应用主模块
│   │   │
│   │   ├── src/
│   │   │   └── main/
│   │   │       │
│   │   │       ├── java/com/jsi/app/
│   │   │       │   └── MainActivity.java
│   │   │       │                       # 主 Activity
│   │   │       │                       - 配置 WebView 设置
│   │   │       │                       - 处理 URL 拦截
│   │   │       │                       - 启用 JavaScript、DOM 存储
│   │   │       │
│   │   │       ├── res/                # 资源文件
│   │   │       │   ├── values/
│   │   │       │   │   ├── strings.xml # 应用名称等字符串资源
│   │   │       │   │   ├── colors.xml  # 应用主题颜色
│   │   │       │   │   └── styles.xml  # 应用样式
│   │   │       │   │
│   │   │       │   └── xml/
│   │   │       │       ├── network_security_config.xml
│   │   │       │       │               # 网络安全配置
│   │   │       │       │               - 允许 HTTP/HTTPS
│   │   │       │       │               - 信任系统证书
│   │   │       │       │
│   │   │       │       └── file_paths.xml
│   │   │       │                       # 文件访问路径配置
│   │   │       │
│   │   │       └── AndroidManifest.xml
│   │   │                           # Android 清单文件
│   │   │                           - 声明应用权限
│   │   │                           - 配置 Activity
│   │   │                           - 启用明文流量
│   │   │
│   │   ├── build.gradle              # 应用模块构建配置
│   │   │                           - 依赖管理
│   │   │                           - 编译选项
│   │   │
│   │   ├── proguard-rules.pro       # ProGuard 混淆规则
│   │   │                           - 保护 Capacitor 类
│   │   │
│   │   └── capacitor.build.gradle    # Capacitor 插件配置
│   │
│   ├── capacitor-cordova-android-plugins/  # Cordova 插件集成
│   │
│   ├── gradle/
│   │   └── wrapper/
│   │       └── gradle-wrapper.properties  # Gradle Wrapper 配置
│   │                                       - Gradle 版本
│   │                                       - 下载超时设置
│   │
│   ├── build.gradle                  # 项目级构建配置
│   │                               - 仓库配置
│   │                               - 全局依赖
│   │
│   ├── settings.gradle              # 项目设置
│   │                               - 包含的模块
│   │                               - 仓库配置
│   │
│   ├── gradle.properties            # Gradle 属性
│   │                               - JVM 参数
│   │                               - AndroidX 配置
│   │
│   ├── gradlew.bat                  # Windows Gradle Wrapper 脚本
│   │
│   └── gradlew                      # Linux/Mac Gradle Wrapper 脚本
│
├── www/                             # Web 资源目录
│   └── index.html                   # 本地备用页面
│                                   - 当远程 URL 加载失败时显示
│
├── node_modules/                    # Node.js 依赖（自动生成）
│
├── package.json                     # Node.js 项目配置
│                                   - 项目依赖
│                                   - 脚本命令
│
├── capacitor.config.json            # Capacitor 配置文件
│                                   - 应用 ID
│                                   - 应用名称
│                                   - 服务器 URL 配置
│                                   - Android 构建选项
│
├── .gitignore                       # Git 忽略文件
│                                   - node_modules
│                                   - 构建产物
│
└── README.md                        # 项目说明文档
```

---

## 环境准备

### 1. 必需软件

#### Node.js
- 版本：18.x 或更高
- 下载地址：https://nodejs.org/

#### Git
- 用于版本控制和 GitHub 集成
- 下载地址：https://git-scm.com/

#### Java JDK
- 版本：17
- 下载地址：https://adoptium.net/temurin/releases/

#### Android SDK（仅本地构建需要）
- 通过 Android Studio 安装
- 下载地址：https://developer.android.com/studio

### 2. 可选软件

#### Android Studio
- 用于本地开发和调试
- 包含 Android SDK、模拟器等工具

#### Gradle
- 本地构建需要（Gradle Wrapper 会自动下载）

---

## 配置步骤

### 步骤 1：克隆项目

```bash
git clone <你的仓库地址>
cd jsi
```

### 步骤 2：配置服务器 URL

编辑 `capacitor.config.json` 文件：

```json
{
  "appId": "com.jsi.app",
  "appName": "思榕移动端",
  "webDir": "www",
  "server": {
    "url": "https://your-server-url.com",  // 修改为你的服务器地址
    "cleartext": true,
    "allowNavigation": ["*"]
  },
  "android": {
    "buildOptions": {
      "keystorePath": "release.keystore",
      "keystoreAlias": "android"
    }
  }
}
```

**配置说明：**

- `appId`：应用包名，格式为 `com.company.appname`
- `appName`：应用显示名称
- `webDir`：本地 Web 资源目录
- `server.url`：远程服务器地址（必须配置）
- `server.cleartext`：是否允许 HTTP（非 HTTPS）连接
- `server.allowNavigation`：允许导航的 URL 模式
- `android.buildOptions`：Android 构建选项（用于签名配置）

### 步骤 3：安装依赖

```bash
npm install
```

这将安装以下依赖：

- `@capacitor/android` - Android 核心
- `@capacitor/core` - Capacitor 核心
- `@capacitor/app` - 应用信息插件
- `@capacitor/haptics` - 触觉反馈插件
- `@capacitor/keyboard` - 键盘插件
- `@capacitor/status-bar` - 状态栏插件

### 步骤 4：同步 Capacitor 到 Android

```bash
npx cap sync android
```

此命令会：

1. 复制 `www` 目录到 Android 项目的 `assets` 目录
2. 复制 `capacitor.config.json` 到 Android 项目
3. 更新 Android 插件配置
4. 生成必要的原生代码

### 步骤 5：（可选）配置应用签名

如果要发布到应用商店，需要配置签名密钥。

#### 生成签名密钥

```bash
keytool -genkey -v -keystore release.keystore -alias android -keyalg RSA -keysize 2048 -validity 10000
```

#### 更新 capacitor.config.json

```json
{
  "android": {
    "buildOptions": {
      "keystorePath": "release.keystore",
      "keystoreAlias": "android",
      "keystorePassword": "your-password",
      "keystoreAliasPassword": "your-password"
    }
  }
}
```

**注意**：不要将密钥文件提交到 Git，添加到 `.gitignore`

---

## 构建步骤

### 方式一：使用 GitHub Actions 自动构建（推荐）

#### 优势

- 无需本地配置 Android 环境
- 自动化流程，减少人为错误
- 自动发布到 GitHub Releases
- 支持版本管理

#### 步骤

1. **推送代码到 GitHub**

```bash
git add .
git commit -m "Initial commit"
git push origin main
```

2. **触发构建**

GitHub Actions 会在以下情况自动触发构建：

- 推送到 `main` 或 `master` 分支
- 创建 Pull Request
- 手动触发（在 GitHub Actions 页面点击 "Run workflow"）

3. **查看构建状态**

- 进入 GitHub 仓库
- 点击 "Actions" 标签
- 查看工作流运行状态

4. **下载 APK**

- 构建成功后，进入 "Releases" 页面
- 找到对应的 Release 版本
- 下载 `app-release.apk` 文件

#### GitHub Actions 工作流说明

工作流文件位于 `.github/workflows/build-android.yml`，主要步骤：

1. **检出代码**：获取仓库代码
2. **设置 Node.js**：安装 Node.js 环境
3. **安装依赖**：运行 `npm ci`
4. **设置 JDK**：安装 Java 17
5. **设置 Android SDK**：安装 Android 构建工具
6. **构建 APK**：运行 `./gradlew assembleRelease`
7. **上传 APK**：上传构建产物
8. **创建 Release**：创建 GitHub Release 并附加 APK

### 方式二：本地构建

#### Windows

```bash
cd android
.\gradlew.bat assembleRelease
```

#### Linux/Mac

```bash
cd android
./gradlew assembleRelease
```

#### 构建产物

APK 文件位置：`android/app/build/outputs/apk/release/app-release.apk`

#### 常见问题

**问题 1：Gradle 下载失败**

```
解决方案：
1. 检查网络连接
2. 配置代理（如果需要）
3. 增加超时时间（修改 gradle-wrapper.properties）
```

**问题 2：无法连接 dl.google.com**

```
解决方案：
1. 使用 GitHub Actions 构建（推荐）
2. 配置网络代理
3. 使用国内镜像源
```

**问题 3：Java 版本不匹配**

```
解决方案：
1. 确认安装了 JDK 17
2. 设置 JAVA_HOME 环境变量
3. 检查 PATH 中是否包含 Java bin 目录
```

---

## 部署步骤

### 步骤 1：测试 APK

1. 将 APK 传输到 Android 设备
2. 在设备上安装 APK
3. 打开应用，验证是否能正确加载远程 URL

### 步骤 2：发布到应用商店（可选）

#### Google Play Store

1. **创建开发者账号**

   - 访问 https://play.google.com/console
   - 注册开发者账号（需要支付 25 美元）

2. **创建应用**

   - 登录 Google Play Console
   - 点击 "创建应用"
   - 填写应用信息

3. **上传 APK**

   - 进入应用设置
   - 选择 "发布管理"
   - 创建新的发布版本
   - 上传 APK 文件

4. **填写商店信息**

   - 应用描述
   - 截图
   - 图标
   - 分类
   - 内容评级

5. **提交审核**

   - 确认所有信息
   - 提交审核
   - 等待审核通过（通常 1-3 天）

#### 其他应用商店

- 华为应用市场
- 小米应用商店
- OPPO 软件商店
- vivo 应用商店
- 腾讯应用宝

每个商店的发布流程略有不同，请参考各自的开发者文档。

---

## 维护和更新

### 更新服务器前端代码

由于应用加载的是远程 URL，更新前端代码非常简单：

1. **更新服务器上的前端代码**
2. **用户重新打开应用即可看到最新内容**

无需重新构建或发布应用！

### 更新应用本身

如果需要更新应用本身（如添加新功能、修复 bug）：

1. **修改代码**
2. **提交到 Git**
3. **推送到 GitHub**
4. **等待 GitHub Actions 自动构建**
5. **发布新版本**

### 版本管理

#### 修改版本号

编辑 `android/app/build.gradle`：

```gradle
defaultConfig {
    applicationId "com.jsi.app"
    minSdkVersion 24
    targetSdkVersion 34
    versionCode 2        // 增加版本号
    versionName "1.1.0"  // 更新版本名称
}
```

#### 版本号规则

- `versionCode`：整数，每次发布必须递增
- `versionName`：字符串，格式为 `主版本.次版本.修订号`

示例：
- `1.0.0` → `1.0.1`（修复 bug）
- `1.0.0` → `1.1.0`（添加新功能）
- `1.0.0` → `2.0.0`（重大更新）

---

## 常见问题解答

### Q1：应用无法加载远程 URL

**可能原因：**

1. URL 配置错误
2. 网络连接问题
3. HTTPS 证书问题

**解决方案：**

1. 检查 `capacitor.config.json` 中的 `server.url` 是否正确
2. 确认设备可以访问该 URL
3. 如果使用自签名证书，需要在 `network_security_config.xml` 中配置信任

### Q2：应用显示空白页面

**可能原因：**

1. 远程服务器返回错误
2. JavaScript 错误
3. 网络安全策略阻止

**解决方案：**

1. 在浏览器中测试 URL 是否正常
2. 检查浏览器控制台是否有错误
3. 确认 `network_security_config.xml` 配置正确

### Q3：GitHub Actions 构建失败

**可能原因：**

1. 代码错误
2. 依赖问题
3. 配置错误

**解决方案：**

1. 查看 Actions 日志，定位错误
2. 本地测试构建（如果可能）
3. 检查 `package.json` 和 `capacitor.config.json` 配置

### Q4：如何添加 Capacitor 插件

**步骤：**

1. 安装插件

```bash
npm install @capacitor/camera
```

2. 同步到 Android

```bash
npx cap sync android
```

3. 在代码中使用

```javascript
import { Camera } from '@capacitor/camera';
```

### Q5：如何自定义应用图标和启动画面

**方法一：使用 Capacitor Assets**

```bash
npm install @capacitor/assets --save-dev
npx cap assets
```

**方法二：手动替换**

1. 替换 `android/app/src/main/res/mipmap-*` 目录下的图标文件
2. 替换启动画面资源

### Q6：如何调试应用

**使用 Chrome DevTools：**

1. 在 Android 设备上启用 USB 调试
2. 连接设备到电脑
3. 在 Chrome 浏览器中打开 `chrome://inspect`
4. 找到你的应用并点击 "inspect"

**查看日志：**

```bash
adb logcat
```

### Q7：如何支持 iOS 平台

**步骤：**

1. 添加 iOS 平台

```bash
npx cap add ios
```

2. 同步

```bash
npx cap sync ios
```

3. 打开 Xcode

```bash
npx cap open ios
```

4. 在 Xcode 中构建和发布

### Q8：如何配置应用权限

**编辑 AndroidManifest.xml：**

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
```

**在代码中请求权限：**

```javascript
import { Camera } from '@capacitor/camera';

const result = await Camera.requestPermissions();
```

---

## 附录

### A. 有用的命令

```bash
# 安装依赖
npm install

# 同步到 Android
npx cap sync android

# 打开 Android Studio
npx cap open android

# 本地构建（Windows）
cd android
.\gradlew.bat assembleRelease

# 本地构建（Linux/Mac）
cd android
./gradlew assembleRelease

# 清理构建
cd android
.\gradlew.bat clean

# 查看设备
adb devices

# 安装 APK
adb install app-release.apk

# 卸载应用
adb uninstall com.jsi.app

# 查看日志
adb logcat
```

### B. 配置文件速查

| 文件 | 用途 |
|------|------|
| `package.json` | Node.js 依赖和脚本 |
| `capacitor.config.json` | Capacitor 配置 |
| `android/app/build.gradle` | 应用模块构建配置 |
| `android/build.gradle` | 项目级构建配置 |
| `android/gradle.properties` | Gradle 属性 |
| `android/app/src/main/AndroidManifest.xml` | Android 清单文件 |
| `.github/workflows/build-android.yml` | GitHub Actions 工作流 |

### C. 参考资源

- [Capacitor 官方文档](https://capacitorjs.com/docs)
- [Android 开发者文档](https://developer.android.com/docs)
- [GitHub Actions 文档](https://docs.github.com/en/actions)
- [Gradle 文档](https://docs.gradle.org/)

---

## 联系支持

如有问题，请：

1. 查看本文档的常见问题解答部分
2. 查阅 Capacitor 官方文档
3. 在 GitHub 上提交 Issue

---

**最后更新：2025-12-30**
