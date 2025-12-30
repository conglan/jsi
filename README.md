# JSI Capacitor Android App

这是一个使用 Capacitor 创建的 Android 应用，用于加载部署在服务器上的前端项目。

## 功能特点

- 使用 Capacitor 框架创建原生 Android 应用
- 加载远程服务器上的 Web 应用
- 支持自动更新，无需重新发布应用
- 使用 GitHub Actions 自动构建 APK

## 配置说明

### 1. 配置服务器 URL

编辑 `capacitor.config.json` 文件，将 `server.url` 修改为你的服务器地址：

```json
{
  "server": {
    "url": "https://your-server-url.com",
    "cleartext": true,
    "allowNavigation": ["*"]
  }
}
```

### 2. 安装依赖

```bash
npm install
```

### 3. 同步 Android 项目

```bash
npx cap sync android
```

### 4. 本地构建

**Windows:**
```bash
cd android
.\gradlew.bat assembleRelease
```

**Linux/Mac:**
```bash
cd android
./gradlew assembleRelease
```

构建完成后，APK 文件位于 `android/app/build/outputs/apk/release/app-release.apk`

**注意**：如果本地构建遇到网络问题（如无法连接 dl.google.com），建议直接使用 GitHub Actions 进行构建，或配置网络代理。

## GitHub Actions 自动构建

项目已配置 GitHub Actions 工作流，会在以下情况自动构建：

- 推送到 `main` 或 `master` 分支
- 创建 Pull Request
- 手动触发（workflow_dispatch）

构建完成后，APK 会自动上传到 GitHub Releases。

## 项目结构

```
jsi/
├── .github/
│   └── workflows/
│       └── build-android.yml    # GitHub Actions 配置
├── android/                     # Android 项目
│   ├── app/
│   │   ├── src/
│   │   │   └── main/
│   │   │       ├── java/com/jsi/app/
│   │   │       │   └── MainActivity.java
│   │   │       ├── res/
│   │   │       │   ├── values/
│   │   │       │   │   ├── strings.xml
│   │   │       │   │   ├── colors.xml
│   │   │       │   │   └── styles.xml
│   │   │       │   └── xml/
│   │   │       │       ├── network_security_config.xml
│   │   │       │       └── file_paths.xml
│   │   │       └── AndroidManifest.xml
│   │   ├── build.gradle
│   │   └── proguard-rules.pro
│   ├── build.gradle
│   ├── settings.gradle
│   └── gradle.properties
├── www/                         # Web 资源目录
│   └── index.html
├── package.json
└── capacitor.config.json        # Capacitor 配置文件
```

## 注意事项

1. **HTTPS 证书**：如果服务器使用 HTTPS，确保证书有效。如果是自签名证书，需要在 `network_security_config.xml` 中配置信任。
2. **网络权限**：应用已配置网络权限和明文流量支持。
3. **版本管理**：每次更新服务器前端项目后，无需重新发布应用，用户打开应用即可看到最新内容。
4. **应用签名**：如需正式发布，需要配置签名密钥。在 `capacitor.config.json` 中配置 `keystorePath` 和 `keystoreAlias`。

## 开发命令

```bash
# 初始化 Capacitor
npm run init

# 添加 Android 平台
npm run add:android

# 同步资源到 Android
npm run sync

# 打开 Android Studio
npm run open:android
```

## 许可证

MIT
