# 后续修改操作指南

本文档详细说明如何对 Capacitor Android 应用进行后续的修改、更新和维护。

## 目录

1. [快速修改流程](#快速修改流程)
2. [常见修改场景](#常见修改场景)
3. [版本管理](#版本管理)
4. [测试和验证](#测试和验证)
5. [故障排查](#故障排查)

---

## 快速修改流程

### 标准修改流程

```bash
# 1. 修改代码或配置文件
# 2. 查看修改内容
git status

# 3. 添加修改的文件
git add .

# 4. 提交更改
git commit -m "描述你的修改"

# 5. 推送到 GitHub
git push origin main

# 6. 等待 GitHub Actions 自动构建（约 5-10 分钟）
# 7. 在 GitHub Releases 页面下载新的 APK
```

### 查看构建状态

```bash
# 访问 Actions 页面
# https://github.com/conglan/jsi/actions
```

---

## 常见修改场景

### 场景 1：修改服务器 URL

#### 何时需要

- 更换服务器地址
- 切换测试/生产环境
- 域名变更

#### 操作步骤

1. **编辑配置文件**

   编辑 `capacitor.config.json`：

   ```json
   {
     "appId": "com.jsi.app",
     "appName": "JSI App",
     "webDir": "www",
     "server": {
       "url": "http://new-server-url.com",  // 修改这里
       "cleartext": true,
       "allowNavigation": ["*"]
     }
   }
   ```

2. **同步到 Android**

   ```bash
   npx cap sync android
   ```

3. **提交并推送**

   ```bash
   git add capacitor.config.json android/app/src/main/assets/capacitor.config.json
   git commit -m "Update server URL to new-server-url.com"
   git push origin main
   ```

4. **等待构建完成**

   - 访问 https://github.com/conglan/jsi/actions
   - 等待构建完成（约 5-10 分钟）
   - 下载新的 APK 测试

#### 注意事项

- URL 必须以 `http://` 或 `https://` 开头
- 如果使用 HTTPS，确保证书有效
- 如果使用 HTTP，确保 `cleartext` 设置为 `true`

---

### 场景 2：修改应用名称

#### 何时需要

- 更改应用显示名称
- 添加品牌标识
- 本地化应用名称

#### 操作步骤

1. **修改 Capacitor 配置**

   编辑 `capacitor.config.json`：

   ```json
   {
     "appName": "My New App Name"  // 修改这里
   }
   ```

2. **修改 Android 字符串资源**

   编辑 `android/app/src/main/res/values/strings.xml`：

   ```xml
   <resources>
       <string name="app_name">My New App Name</string>
   </resources>
   ```

3. **同步并提交**

   ```bash
   npx cap sync android
   git add .
   git commit -m "Update app name to My New App Name"
   git push origin main
   ```

4. **等待构建完成**

---

### 场景 3：修改应用图标

#### 何时需要

- 更换品牌图标
- 更新应用设计
- 节日主题图标

#### 操作步骤

##### 方法一：使用在线工具（推荐）

1. **准备图标**

   - 准备一个 1024x1024 像素的 PNG 图标
   - 确保背景透明（推荐）

2. **使用图标生成工具**

   访问：https://icon.kitchen/ 或 https://appicon.co/

   - 上传你的图标
   - 下载生成的图标包

3. **替换图标文件**

   解压下载的图标包，将以下文件复制到对应位置：

   ```
   android/app/src/main/res/
   ├── mipmap-hdpi/
   │   └── ic_launcher.png
   ├── mipmap-mdpi/
   │   └── ic_launcher.png
   ├── mipmap-xhdpi/
   │   ├── ic_launcher.png
   │   └── ic_launcher_round.png
   ├── mipmap-xxhdpi/
   │   ├── ic_launcher.png
   │   └── ic_launcher_round.png
   ├── mipmap-xxxhdpi/
   │   ├── ic_launcher.png
   │   └── ic_launcher_round.png
   └── mipmap-anydpi-v26/
       ├── ic_launcher.xml
       └── ic_launcher_round.xml
   ```

4. **提交并推送**

   ```bash
   git add android/app/src/main/res/mipmap-*
   git commit -m "Update app icon"
   git push origin main
   ```

##### 方法二：使用 Capacitor Assets

1. **安装工具**

   ```bash
   npm install @capacitor/assets --save-dev
   ```

2. **准备图标**

   - 创建 `resources/` 目录
   - 放置 `icon.png`（1024x1024）

3. **生成图标**

   ```bash
   npx cap assets android
   ```

4. **提交并推送**

   ```bash
   git add .
   git commit -m "Update app icon using Capacitor Assets"
   git push origin main
   ```

---

### 场景 4：修改应用包名

#### 何时需要

- 更改应用标识符
- 公司品牌变更
- 避免包名冲突

#### 操作步骤

⚠️ **警告**：修改包名会导致应用被视为全新应用，用户需要重新安装。

1. **修改 Capacitor 配置**

   编辑 `capacitor.config.json`：

   ```json
   {
     "appId": "com.newcompany.newapp"
   }
   ```

2. **修改 Android 配置**

   编辑 `android/app/build.gradle`：

   ```gradle
   defaultConfig {
       applicationId "com.newcompany.newapp"
   }
   ```

3. **重命名包目录**

   ```bash
   # 重命名目录
   mv android/app/src/main/java/com/jsi/app android/app/src/main/java/com/newcompany/newapp
   ```

4. **修改包名声明**

   编辑 `android/app/src/main/java/com/newcompany/newapp/MainActivity.java`：

   ```java
   package com.newcompany.newapp;
   ```

5. **修改 AndroidManifest.xml**

   编辑 `android/app/src/main/AndroidManifest.xml`：

   ```xml
   <manifest xmlns:android="http://schemas.android.com/apk/res/android"
       package="com.newcompany.newapp">
   ```

6. **同步并提交**

   ```bash
   npx cap sync android
   git add .
   git commit -m "Change package name to com.newcompany.newapp"
   git push origin main
   ```

---

### 场景 5：添加 Capacitor 插件

#### 何时需要

- 访问设备功能（相机、位置、文件等）
- 增强应用功能
- 集成第三方服务

#### 操作步骤

1. **安装插件**

   ```bash
   # 示例：安装相机插件
   npm install @capacitor/camera
   ```

2. **同步到 Android**

   ```bash
   npx cap sync android
   ```

3. **在代码中使用**

   创建或编辑 `www/js/app.js`：

   ```javascript
   import { Camera } from '@capacitor/camera';

   async function takePicture() {
       const image = await Camera.getPhoto({
           quality: 90,
           allowEditing: false,
           resultType: 'base64'
       });
       // 处理图片
   }
   ```

4. **配置权限（如需要）**

   编辑 `android/app/src/main/AndroidManifest.xml`：

   ```xml
   <uses-permission android:name="android.permission.CAMERA" />
   ```

5. **提交并推送**

   ```bash
   git add .
   git commit -m "Add Camera plugin"
   git push origin main
   ```

#### 常用插件

```bash
# 相机
npm install @capacitor/camera

# 地理位置
npm install @capacitor/geolocation

# 文件系统
npm install @capacitor/filesystem

# 网络
npm install @capacitor/network

# 设备信息
npm install @capacitor/device

# 本地通知
npm install @capacitor/local-notifications

# 分享
npm install @capacitor/share

# 浏览器
npm install @capacitor/browser

# 剪贴板
npm install @capacitor/clipboard
```

---

### 场景 6：修改应用版本号

#### 何时需要

- 发布新版本
- 修复 bug
- 添加新功能

#### 操作步骤

1. **修改版本号**

   编辑 `android/app/build.gradle`：

   ```gradle
   defaultConfig {
       applicationId "com.jsi.app"
       minSdkVersion 24
       targetSdkVersion 34
       versionCode 2        // 递增（必须）
       versionName "1.1.0"  // 更新版本名称
   }
   ```

2. **提交并推送**

   ```bash
   git add android/app/build.gradle
   git commit -m "Bump version to 1.1.0"
   git push origin main
   ```

#### 版本号规则

- `versionCode`：整数，每次发布必须递增
- `versionName`：字符串，格式：`主版本.次版本.修订号`

示例：
- `1.0.0` → `1.0.1`（修复 bug）
- `1.0.0` → `1.1.0`（添加新功能）
- `1.0.0` → `2.0.0`（重大更新）

---

### 场景 7：修改应用主题颜色

#### 何时需要

- 更新品牌颜色
- 改变应用外观
- 适配深色模式

#### 操作步骤

1. **修改颜色资源**

   编辑 `android/app/src/main/res/values/colors.xml`：

   ```xml
   <?xml version="1.0" encoding="utf-8"?>
   <resources>
       <color name="colorPrimary">#FF6200</color>
       <color name="colorPrimaryDark">#CC5000</color>
       <color name="colorAccent">#FF6200</color>
   </resources>
   ```

2. **提交并推送**

   ```bash
   git add android/app/src/main/res/values/colors.xml
   git commit -m "Update app theme colors"
   git push origin main
   ```

---

### 场景 8：配置应用签名（发布到应用商店）

#### 何时需要

- 发布到 Google Play Store
- 发布到其他应用商店
- 正式发布应用

#### 操作步骤

1. **生成签名密钥**

   ```bash
   keytool -genkey -v -keystore release.keystore -alias android -keyalg RSA -keysize 2048 -validity 10000
   ```

   按提示输入：
   - 密钥库密码
   - 密钥密码
   - 姓名、组织、城市等信息

2. **更新 Capacitor 配置**

   编辑 `capacitor.config.json`：

   ```json
   {
     "android": {
       "buildOptions": {
         "keystorePath": "release.keystore",
         "keystoreAlias": "android",
         "keystorePassword": "your-keystore-password",
         "keystoreAliasPassword": "your-alias-password"
       }
     }
   }
   ```

3. **将密钥文件添加到项目**

   ```bash
   cp /path/to/release.keystore .
   ```

4. **添加到 .gitignore**

   ⚠️ **重要**：不要将密钥文件提交到 Git！

   编辑 `.gitignore`：

   ```
   *.keystore
   *.jks
   ```

5. **在 GitHub Actions 中配置密钥**

   - 在 GitHub 仓库中添加 Secrets
   - 添加以下 Secrets：
     - `KEYSTORE_FILE`：上传 keystore 文件
     - `KEYSTORE_PASSWORD`：密钥库密码
     - `KEY_ALIAS`：密钥别名
     - `KEY_PASSWORD`：密钥密码

6. **更新 GitHub Actions 工作流**

   编辑 `.github/workflows/build-android.yml`：

   ```yaml
   - name: Build Android APK
     run: |
       cd android
       echo ${{ secrets.KEYSTORE_FILE }} | base64 -d > release.keystore
       ./gradlew assembleRelease --stacktrace
   ```

7. **提交并推送**

   ```bash
   git add capacitor.config.json .github/workflows/build-android.yml
   git commit -m "Configure app signing"
   git push origin main
   ```

---

### 场景 9：添加启动画面

#### 操作步骤

##### 方法一：使用在线工具

1. **准备启动画面图片**

   - 尺寸：2732x2732 像素
   - 格式：PNG
   - 内容：居中显示 Logo，周围留白

2. **使用工具生成**

   访问：https://icon.kitchen/

   - 上传图片
   - 选择 "Splash Screen"
   - 下载生成的文件

3. **复制文件**

   将生成的文件复制到：
   ```
   android/app/src/main/res/drawable-*/
   ```

##### 方法二：使用 Capacitor Assets

```bash
# 1. 准备启动画面图片
# 尺寸：2732x2732 像素
# 文件名：splash.png

# 2. 放置到 resources/ 目录

# 3. 生成启动画面
npx cap assets android

# 4. 提交
git add .
git commit -m "Add splash screen"
git push origin main
```

---

### 场景 10：修改网络配置

#### 何时需要

- 添加自签名证书信任
- 配置代理
- 限制网络访问

#### 操作步骤

1. **编辑网络安全配置**

   编辑 `android/app/src/main/res/xml/network_security_config.xml`：

   ```xml
   <?xml version="1.0" encoding="utf-8"?>
   <network-security-config>
       <!-- 允许明文流量 -->
       <base-config cleartextTrafficPermitted="true">
           <trust-anchors>
               <certificates src="system" />
               <certificates src="user" />
           </trust-anchors>
       </base-config>

       <!-- 信任特定域名的自签名证书 -->
       <domain-config>
           <domain includeSubdomains="true">example.com</domain>
           <trust-anchors>
               <certificates src="@raw/my_certificate" />
           </trust-anchors>
       </domain-config>
   </network-security-config>
   ```

2. **添加证书文件（如需要）**

   将证书文件放到：
   ```
   android/app/src/main/res/raw/my_certificate.crt
   ```

3. **提交并推送**

   ```bash
   git add android/app/src/main/res/xml/network_security_config.xml
   git commit -m "Update network security config"
   git push origin main
   ```

---

## 版本管理

### Git 工作流程

#### 查看修改

```bash
# 查看修改状态
git status

# 查看具体修改内容
git diff

# 查看已暂存的修改
git diff --staged
```

#### 撤销修改

```bash
# 撤销工作区的修改
git checkout -- <file>

# 撤销暂存区的修改
git reset HEAD <file>

# 撤销最近的提交
git reset --soft HEAD~1

# 撤销最近的提交并丢弃修改
git reset --hard HEAD~1
```

#### 查看历史

```bash
# 查看提交历史
git log

# 查看图形化历史
git log --graph --oneline --all

# 查看特定文件的修改历史
git log --follow <file>
```

### 分支管理

#### 创建分支

```bash
# 创建新分支
git branch feature/new-feature

# 切换到新分支
git checkout feature/new-feature

# 或一步完成
git checkout -b feature/new-feature
```

#### 合并分支

```bash
# 切换到 main 分支
git checkout main

# 合并功能分支
git merge feature/new-feature

# 推送到远程
git push origin main
```

#### 删除分支

```bash
# 删除本地分支
git branch -d feature/new-feature

# 删除远程分支
git push origin --delete feature/new-feature
```

---

## 测试和验证

### 本地测试

#### 安装 APK 到设备

```bash
# 连接设备
adb devices

# 安装 APK
adb install android/app/build/outputs/apk/release/app-release.apk

# 启动应用
adb shell am start -n com.jsi.app/.MainActivity

# 查看日志
adb logcat | grep "com.jsi.app"
```

#### 调试应用

1. **启用 USB 调试**

   - 在设备上启用开发者选项
   - 启用 USB 调试

2. **使用 Chrome DevTools**

   - 在 Chrome 浏览器中打开 `chrome://inspect`
   - 找到你的应用并点击 "inspect"

3. **查看日志**

   ```bash
   adb logcat
   ```

### 测试清单

- [ ] 应用能正常启动
- [ ] 能正确加载远程 URL
- [ ] 网络请求正常
- [ ] JavaScript 功能正常
- [ ] 应用图标和名称正确
- [ ] 通知权限正常（如使用）
- [ ] 相机/位置等功能正常（如使用）
- [ ] 应用在不同屏幕尺寸上正常显示
- [ ] 应用在横屏/竖屏模式下正常

---

## 故障排查

### 问题 1：应用无法启动

#### 可能原因

- APK 损坏
- 设备不兼容
- 权限问题

#### 解决方案

```bash
# 1. 重新安装
adb uninstall com.jsi.app
adb install android/app/build/outputs/apk/release/app-release.apk

# 2. 查看日志
adb logcat | grep "AndroidRuntime"

# 3. 检查设备兼容性
adb shell getprop ro.build.version.sdk
```

### 问题 2：无法加载远程 URL

#### 可能原因

- URL 配置错误
- 网络连接问题
- HTTPS 证书问题

#### 解决方案

1. **检查配置**

   ```bash
   # 查看 capacitor.config.json
   cat capacitor.config.json
   ```

2. **测试网络连接**

   ```bash
   # 在设备浏览器中测试 URL
   ```

3. **查看日志**

   ```bash
   adb logcat | grep "WebView"
   ```

### 问题 3：GitHub Actions 构建失败

#### 可能原因

- 代码错误
- 依赖问题
- 配置错误

#### 解决方案

1. **查看 Actions 日志**

   - 访问 https://github.com/conglan/jsi/actions
   - 点击失败的工作流
   - 查看详细日志

2. **本地测试**

   ```bash
   # 本地构建测试
   cd android
   ./gradlew assembleRelease
   ```

3. **检查依赖**

   ```bash
   # 重新安装依赖
   npm install
   npx cap sync android
   ```

### 问题 4：应用崩溃

#### 可能原因

- 代码错误
- 内存不足
- 权限问题

#### 解决方案

```bash
# 1. 查看崩溃日志
adb logcat | grep "FATAL EXCEPTION"

# 2. 查看详细日志
adb logcat -v time > crash.log

# 3. 分析日志
grep -A 50 "FATAL" crash.log
```

### 问题 5：插件不工作

#### 可能原因

- 插件未正确安装
- 权限未配置
- 代码错误

#### 解决方案

1. **检查插件安装**

   ```bash
   npm list | grep @capacitor
   ```

2. **重新同步**

   ```bash
   npx cap sync android
   ```

3. **检查权限**

   ```bash
   # 查看 AndroidManifest.xml
   cat android/app/src/main/AndroidManifest.xml
   ```

---

## 快速参考

### 常用命令

```bash
# 安装依赖
npm install

# 同步到 Android
npx cap sync android

# 本地构建（Windows）
cd android
.\gradlew.bat assembleRelease

# 本地构建（Linux/Mac）
cd android
./gradlew assembleRelease

# 安装到设备
adb install android/app/build/outputs/apk/release/app-release.apk

# 查看日志
adb logcat

# Git 操作
git status
git add .
git commit -m "message"
git push origin main
```

### 配置文件位置

| 配置项 | 文件路径 |
|--------|---------|
| 应用配置 | `capacitor.config.json` |
| 应用名称 | `android/app/src/main/res/values/strings.xml` |
| 应用图标 | `android/app/src/main/res/mipmap-*/` |
| 应用颜色 | `android/app/src/main/res/values/colors.xml` |
| 版本号 | `android/app/build.gradle` |
| 网络配置 | `android/app/src/main/res/xml/network_security_config.xml` |
| 权限配置 | `android/app/src/main/AndroidManifest.xml` |
| GitHub Actions | `.github/workflows/build-android.yml` |

### 常用 URL

- GitHub 仓库：https://github.com/conglan/jsi
- Actions 页面：https://github.com/conglan/jsi/actions
- Releases 页面：https://github.com/conglan/jsi/releases
- Capacitor 文档：https://capacitorjs.com/docs

---

## 总结

### 修改流程总结

```
1. 修改代码或配置
   ↓
2. 测试修改（本地）
   ↓
3. 提交到 Git
   ↓
4. 推送到 GitHub
   ↓
5. 等待自动构建
   ↓
6. 下载新 APK
   ↓
7. 测试新版本
```

### 最佳实践

1. **每次修改前先备份**
   ```bash
   git branch backup-$(date +%Y%m%d)
   ```

2. **小步提交，频繁推送**
   ```bash
   git add .
   git commit -m "Small change"
   git push origin main
   ```

3. **写清晰的提交信息**
   ```bash
   git commit -m "Update server URL to production"
   ```

4. **测试后再推送**
   ```bash
   # 本地测试
   npx cap sync android
   cd android
   ./gradlew assembleRelease
   ```

5. **查看构建日志**
   - 每次推送后查看 Actions 页面
   - 及时发现和解决问题

---

**最后更新：2025-12-30**
