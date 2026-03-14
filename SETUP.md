# 如何编译和安装

## 方案一：本地编译（推荐）

### 步骤1: 安装Flutter

**Windows:**
1. 下载: https://docs.flutter.dev/get-started/install/windows
2. 解压到 `C:\flutter`
3. 添加 `C:\flutter\bin` 到系统PATH

**Mac:**
```bash
brew install flutter
```

**Linux:**
```bash
sudo snap install flutter --classic
```

### 步骤2: 配置Android SDK

1. 安装 Android Studio: https://developer.android.com/studio
2. 打开 Android Studio → More Actions → SDK Manager
3. 安装 Android SDK 34

### 步骤3: 编译项目

```bash
# 1. 下载项目文件到本地
# 2. 解压后进入目录
cd task_planner

# 3. 获取依赖
flutter pub get

# 4. 编译APK
flutter build apk --release
```

编译后的APK在：`build/app/outputs/flutter-apk/app-release.apk`

### 步骤4: 安装到手机

**方法A: USB连接**
```bash
flutter install
```

**方法B: 直接传输**
- 将APK传到手机（微信/QQ/邮件）
- 点击安装
- 允许未知来源应用安装

---

## 方案二：在线编译（无需安装Flutter）

使用 GitHub Actions 自动编译：

### 步骤1: 上传到GitHub

1. 创建新仓库: https://github.com/new
2. 上传项目文件
3. 创建 `.github/workflows/build.yml`:

```yaml
name: Build APK

on:
  push:
    branches: [ main ]
  workflow_dispatch:

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
      - run: flutter pub get
      - run: flutter build apk --release
      - uses: actions/upload-artifact@v3
        with:
          name: app-release
          path: build/app/outputs/flutter-apk/app-release.apk
```

### 步骤2: 下载APK

1. 进入仓库 → Actions
2. 点击最新的构建
3. 下载 Artifacts 中的 APK

---

## 方案三：使用Flutter在线编辑器

1. 访问: https://zapp.run
2. 创建新Flutter项目
3. 复制代码文件
4. 下载APK

---

## 常见问题

**Q: 编译报错 "Android SDK not found"**
A: 安装 Android Studio 并打开SDK Manager安装SDK

**Q: 手机安装提示"未知来源"**
A: 设置 → 安全 → 允许安装未知来源应用

**Q: 如何更新应用**
A: 重新编译安装即可，数据会保留

---

需要帮助？在QQ中联系我。
