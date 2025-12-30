# 无需 Android Studio 本地构建指南

本文档介绍如何在不安装 Android Studio 的情况下，使用命令行工具构建 Android 应用。

## 目录

1. [方案概述](#方案概述)
2. [环境准备](#环境准备)
3. [安装步骤](#安装步骤)
4. [配置步骤](#配置步骤)
5. [构建步骤](#构建步骤)
6. [常见问题](#常见问题)

---

## 方案概述

### 为什么可以无需 Android Studio？

Android Studio 只是一个 IDE（集成开发环境），它包含了：

- Android SDK（必需）
- 模拟器（可选）
- Gradle（通过 Wrapper 自动下载）
- 其他开发工具（可选）

实际上，构建 Android 应用只需要：

- ✅ Java JDK
- ✅ Android SDK
- ✅ Gradle（通过 Wrapper 自动下载）

### 优势

- **节省空间**：Android Studio 占用约 2-3GB，SDK 命令行工具只需约 500MB
- **安装更快**：无需下载大型 IDE
- **适合 CI/CD**：命令行环境更适合自动化构建
- **资源占用少**：不运行 IDE，节省系统资源

### 劣势

- ❌ 无法使用可视化界面设计布局
- ❌ 无法使用内置模拟器
- ❌ 调试体验较差
- ❌ 代码提示和补全功能有限

---

## 环境准备

### 必需软件

1. **Java JDK 17**
   - 下载地址：https://adoptium.net/temurin/releases/
   - 选择版本：Temurin 17 (LTS)
   - 操作系统：Windows x64
   - 文件类型：MSI Installer

2. **Android SDK 命令行工具**
   - 下载地址：https://developer.android.com/studio#command-tools
   - 选择版本：Command line tools only
   - 文件名：`commandlinetools-win-xxxx_latest.zip`

### 可选软件

- **Android 模拟器**：如需测试应用
- **ADB 工具**：已包含在 SDK 中

---

## 安装步骤

### 步骤 1：安装 Java JDK

1. 下载 JDK 17 安装包
2. 运行安装程序
3. 按照向导完成安装
4. 记住安装路径（默认：`C:\Program Files\Eclipse Adoptium\jdk-17.0.16.101-hotspot\`）

### 步骤 2：安装 Android SDK 命令行工具

#### 方法一：手动安装

1. **下载命令行工具**

   访问：https://developer.android.com/studio#command-tools

   下载：`commandlinetools-win-xxxx_latest.zip`

2. **创建 SDK 目录**

   ```powershell
   # 创建 SDK 根目录
   mkdir C:\Android\sdk
   
   # 创建命令行工具目录
   mkdir C:\Android\sdk\cmdline-tools\latest
   ```

3. **解压文件**

   将下载的 ZIP 文件解压到：
   ```
   C:\Android\sdk\cmdline-tools\latest\
   ```

   解压后的目录结构应该是：
   ```
   C:\Android\sdk\cmdline-tools\latest\
   ├── bin\
   ├── lib\
   ├── NOTICE.txt
   └── source.properties
   ```

#### 方法二：使用 PowerShell 自动安装

```powershell
# 下载命令行工具
$downloadUrl = "https://dl.google.com/android/repository/commandlinetools-win-11076708_latest.zip"
$downloadPath = "$env:TEMP\commandlinetools-win.zip"
Invoke-WebRequest -Uri $downloadUrl -OutFile $downloadPath

# 创建目录
$sdkPath = "C:\Android\sdk"
$cmdlinePath = "$sdkPath\cmdline-tools\latest"
New-Item -ItemType Directory -Force -Path $cmdlinePath | Out-Null

# 解压文件
Expand-Archive -Path $downloadPath -DestinationPath $cmdlinePath -Force

# 清理临时文件
Remove-Item $downloadPath -Force

Write-Host "Android SDK 命令行工具已安装到: $sdkPath"
```

### 步骤 3：使用 SDK Manager 安装必要组件

#### 3.1 设置环境变量

```powershell
# 临时设置（当前会话有效）
$env:ANDROID_HOME = "C:\Android\sdk"
$env:ANDROID_SDK_ROOT = "C:\Android\sdk"
$env:Path += ";$env:ANDROID_HOME\cmdline-tools\latest\bin;$env:ANDROID_HOME\platform-tools"
```

#### 3.2 接受许可证

```powershell
sdkmanager --licenses
```

输入 `y` 接受所有许可证。

#### 3.3 安装必要组件

```powershell
# 安装平台工具
sdkmanager "platform-tools"

# 安装构建工具 34.0.0
sdkmanager "build-tools;34.0.0"

# 安装 Android 14 平台
sdkmanager "platforms;android-34"

# 安装 Android 13 平台
sdkmanager "platforms;android-33"

# 安装 NDK（可选）
sdkmanager "ndk;25.2.9519653"
```

#### 3.4 验证安装

```powershell
# 查看已安装的包
sdkmanager --list_installed

# 验证 adb
adb version
```

---

## 配置步骤

### 步骤 1：永久设置环境变量

#### 方法一：使用系统设置

1. 打开"控制面板" → "系统" → "高级系统设置"
2. 点击"环境变量"
3. 在"用户变量"或"系统变量"中添加：

   **变量名**：`ANDROID_HOME`
   **变量值**：`C:\Android\sdk`

   **变量名**：`ANDROID_SDK_ROOT`
   **变量值**：`C:\Android\sdk`

4. 编辑 `Path` 变量，添加：

   ```
   %ANDROID_HOME%\cmdline-tools\latest\bin
   %ANDROID_HOME%\platform-tools
   %ANDROID_HOME%\build-tools\34.0.0
   ```

5. 点击"确定"保存所有更改

#### 方法二：使用 PowerShell（推荐）

```powershell
# 设置用户环境变量
[Environment]::SetEnvironmentVariable("ANDROID_HOME", "C:\Android\sdk", "User")
[Environment]::SetEnvironmentVariable("ANDROID_SDK_ROOT", "C:\Android\sdk", "User")

# 获取当前 Path
$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")

# 添加新路径
$newPath = $currentPath + ";C:\Android\sdk\cmdline-tools\latest\bin;C:\Android\sdk\platform-tools"
[Environment]::SetEnvironmentVariable("Path", $newPath, "User")

Write-Host "环境变量已设置，请重启终端或重新登录以生效"
```

### 步骤 2：验证环境变量

```powershell
# 重新打开终端后验证
echo $env:ANDROID_HOME
echo $env:ANDROID_SDK_ROOT

# 验证命令
sdkmanager --version
adb version
```

### 步骤 3：配置 Gradle（可选）

虽然 Gradle Wrapper 会自动下载，但也可以手动安装：

```powershell
# 使用 Chocolatey 安装（如果已安装）
choco install gradle

# 或使用 Scoop 安装（如果已安装）
scoop install gradle
```

---

## 构建步骤

### 步骤 1：准备项目

```powershell
# 进入项目目录
cd E:\GitHub\jsi

# 安装 Node.js 依赖
npm install

# 同步 Capacitor 到 Android
npx cap sync android
```

### 步骤 2：构建 APK

```powershell
# 进入 Android 目录
cd android

# 使用 Gradle Wrapper 构建（推荐）
.\gradlew.bat assembleRelease

# 或使用 Debug 版本
.\gradlew.bat assembleDebug
```

### 步骤 3：查找 APK 文件

构建成功后，APK 文件位于：

```
android\app\build\outputs\apk\release\app-release.apk
```

或

```
android\app\build\outputs\apk\debug\app-debug.apk
```

### 步骤 4：安装到设备

#### 使用 ADB 安装

```powershell
# 连接设备（通过 USB 或 Wi-Fi）
adb devices

# 安装 APK
adb install android\app\build\outputs\apk\release\app-release.apk

# 卸载应用
adb uninstall com.jsi.app
```

#### 直接安装

将 APK 文件传输到 Android 设备，使用文件管理器打开并安装。

---

## 常见问题

### Q1：找不到 sdkmanager 命令

**原因**：环境变量未正确配置

**解决方案**：

1. 检查环境变量是否设置
2. 确认路径是否正确
3. 重启终端或重新登录
4. 运行以下命令验证：

```powershell
$env:Path -split ';' | Select-String "android"
```

### Q2：sdkmanager 无法下载组件

**原因**：网络连接问题或需要代理

**解决方案**：

#### 使用代理

```powershell
# 设置代理
$env:HTTP_PROXY = "http://proxy.example.com:8080"
$env:HTTPS_PROXY = "http://proxy.example.com:8080"

# 或在 sdkmanager 命令中指定
sdkmanager --proxy=http --proxy_host=proxy.example.com --proxy_port=8080 "platform-tools"
```

#### 使用国内镜像

编辑 `C:\Android\sdk\cmdline-tools\latest\bin\sdkmanager.bat`，添加：

```bat
set REPO_OS_OVERRIDE=windows
set ANDROID_SDK_ROOT=C:\Android\sdk
```

### Q3：Gradle 构建失败

**错误信息**：
```
Could not resolve com.android.tools.build:gradle:8.2.2
```

**解决方案**：

1. 检查网络连接
2. 配置 Gradle 镜像（编辑 `android/build.gradle`）：

```gradle
buildscript {
    repositories {
        maven { url 'https://maven.aliyun.com/repository/google' }
        maven { url 'https://maven.aliyun.com/repository/public' }
        maven { url 'https://maven.aliyun.com/repository/gradle-plugin' }
        google()
        mavenCentral()
    }
}
```

3. 增加超时时间（编辑 `android/gradle/wrapper/gradle-wrapper.properties`）：

```properties
networkTimeout=120000
```

### Q4：Java 版本不匹配

**错误信息**：
```
Unsupported class file major version 61
```

**原因**：Java 版本过高或过低

**解决方案**：

1. 确认 Java 版本：

```powershell
java -version
```

2. 应该显示 Java 17（61 对应 Java 17）

3. 如果版本不对，安装正确的 JDK 版本

### Q5：找不到 ANDROID_HOME

**解决方案**：

```powershell
# 临时设置
$env:ANDROID_HOME = "C:\Android\sdk"
$env:ANDROID_SDK_ROOT = "C:\Android\sdk"

# 永久设置
[Environment]::SetEnvironmentVariable("ANDROID_HOME", "C:\Android\sdk", "User")
[Environment]::SetEnvironmentVariable("ANDROID_SDK_ROOT", "C:\Android\sdk", "User")
```

### Q6：构建时提示找不到 Android SDK

**错误信息**：
```
SDK location not found. Define location with an ANDROID_HOME environment variable
```

**解决方案**：

1. 确认环境变量已设置
2. 检查 SDK 目录是否存在
3. 在 `android/local.properties` 中指定 SDK 路径：

```properties
sdk.dir=C\:\\Android\\sdk
```

### Q7：Gradle Wrapper 下载失败

**解决方案**：

1. 手动下载 Gradle：

```powershell
# 下载 Gradle 8.5
$downloadUrl = "https://services.gradle.org/distributions/gradle-8.5-bin.zip"
$downloadPath = "$env:USERPROFILE\.gradle\wrapper\dists\gradle-8.5-bin\gradle-8.5-bin.zip"
New-Item -ItemType Directory -Force -Path (Split-Path $downloadPath) | Out-Null
Invoke-WebRequest -Uri $downloadUrl -OutFile $downloadPath

# 解压
$extractPath = Split-Path $downloadPath
Expand-Archive -Path $downloadPath -DestinationPath $extractPath -Force
```

2. 或使用国内镜像：

编辑 `android/gradle/wrapper/gradle-wrapper.properties`：

```properties
distributionUrl=https\://mirrors.cloud.tencent.com/gradle/gradle-8.5-bin.zip
```

---

## 完整安装脚本

以下是一键安装脚本，可以自动化整个安装过程：

```powershell
# Android SDK 命令行工具一键安装脚本

# 设置变量
$sdkPath = "C:\Android\sdk"
$cmdlinePath = "$sdkPath\cmdline-tools\latest"
$downloadUrl = "https://dl.google.com/android/repository/commandlinetools-win-11076708_latest.zip"
$downloadPath = "$env:TEMP\commandlinetools-win.zip"

Write-Host "开始安装 Android SDK 命令行工具..." -ForegroundColor Green

# 1. 创建目录
Write-Host "创建目录..." -ForegroundColor Yellow
New-Item -ItemType Directory -Force -Path $cmdlinePath | Out-Null

# 2. 下载命令行工具
Write-Host "下载命令行工具..." -ForegroundColor Yellow
Invoke-WebRequest -Uri $downloadUrl -OutFile $downloadPath

# 3. 解压文件
Write-Host "解压文件..." -ForegroundColor Yellow
Expand-Archive -Path $downloadPath -DestinationPath $cmdlinePath -Force

# 4. 清理临时文件
Write-Host "清理临时文件..." -ForegroundColor Yellow
Remove-Item $downloadPath -Force

# 5. 设置环境变量
Write-Host "设置环境变量..." -ForegroundColor Yellow
[Environment]::SetEnvironmentVariable("ANDROID_HOME", $sdkPath, "User")
[Environment]::SetEnvironmentVariable("ANDROID_SDK_ROOT", $sdkPath, "User")

$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
$newPath = $currentPath + ";$sdkPath\cmdline-tools\latest\bin;$sdkPath\platform-tools"
[Environment]::SetEnvironmentVariable("Path", $newPath, "User")

# 6. 刷新环境变量
$env:ANDROID_HOME = $sdkPath
$env:ANDROID_SDK_ROOT = $sdkPath
$env:Path += ";$sdkPath\cmdline-tools\latest\bin;$sdkPath\platform-tools"

# 7. 接受许可证
Write-Host "接受许可证..." -ForegroundColor Yellow
sdkmanager --licenses

# 8. 安装必要组件
Write-Host "安装 Android SDK 组件..." -ForegroundColor Yellow
sdkmanager "platform-tools"
sdkmanager "build-tools;34.0.0"
sdkmanager "platforms;android-34"
sdkmanager "platforms;android-33"

# 9. 验证安装
Write-Host "`n验证安装..." -ForegroundColor Green
Write-Host "ANDROID_HOME: $env:ANDROID_HOME"
Write-Host "sdkmanager 版本:"
sdkmanager --version
Write-Host "adb 版本:"
adb version

Write-Host "`n安装完成！" -ForegroundColor Green
Write-Host "请重启终端或重新登录以使环境变量生效" -ForegroundColor Yellow
```

保存为 `install-android-sdk.ps1`，然后运行：

```powershell
powershell -ExecutionPolicy Bypass -File install-android-sdk.ps1
```

---

## 总结

### 无需 Android Studio 构建的完整流程

```powershell
# 1. 安装 Java JDK 17（手动安装）

# 2. 安装 Android SDK 命令行工具
# 运行上面的安装脚本或手动安装

# 3. 重启终端

# 4. 验证环境
java -version
sdkmanager --version
adb version

# 5. 进入项目目录
cd E:\GitHub\jsi

# 6. 安装依赖
npm install

# 7. 同步 Capacitor
npx cap sync android

# 8. 构建 APK
cd android
.\gradlew.bat assembleRelease

# 9. 查找 APK
# 位于：android\app\build\outputs\apk\release\app-release.apk
```

### 对比总结

| 项目 | 需要 Android Studio | 不需要 Android Studio |
|------|-------------------|---------------------|
| 磁盘空间 | ~2-3 GB | ~500 MB |
| 安装时间 | 10-20 分钟 | 5-10 分钟 |
| 构建速度 | 相同 | 相同 |
| 开发体验 | 好 | 一般 |
| 调试功能 | 强大 | 有限 |
| CI/CD | 不适合 | 非常适合 |

### 推荐方案

- **日常开发**：使用 Android Studio（更好的开发体验）
- **CI/CD**：使用命令行工具（节省资源）
- **快速测试**：使用 GitHub Actions（无需本地环境）

---

**最后更新：2025-12-30**
