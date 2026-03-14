# 任务规划表 - Task Planner

一个简洁的日程任务规划表格应用，用于记录每天的工作任务和标记状态。

## 功能特性

- ✅ 横向滚动表格，固定任务名称列
- ✅ 50行任务输入
- ✅ 自动显示工作日（跳过周末）
- ✅ 8种颜色标记（红、橙、黄、绿、蓝、紫、粉、灰）
- ✅ 点击单元格切换颜色状态
- ✅ 本地SQLite存储，无需联网
- ✅ 自动保存和加载
- ✅ 导出CSV分享
- ✅ Material Design 3 风格
- ✅ 支持横屏显示

## 技术栈

- **框架**: Flutter 3.x
- **语言**: Dart
- **数据库**: SQLite (sqflite)
- **UI**: Material Design 3

## 项目结构

```
task_planner/
├── lib/
│   ├── main.dart                 # 应用入口
│   ├── models/
│   │   └── task_cell.dart        # 数据模型
│   ├── database/
│   │   └── database_helper.dart  # 数据库操作
│   ├── screens/
│   │   └── home_screen.dart      # 主屏幕
│   └── widgets/
│       └── color_picker.dart     # 颜色选择器
├── android/                      # Android配置
├── pubspec.yaml                  # 依赖配置
└── README.md                     # 说明文档
```

## 安装与编译

### 前置要求

1. 安装 [Flutter SDK](https://docs.flutter.dev/get-started/install)
2. 配置 Android SDK（用于编译Android应用）
3. 运行 `flutter doctor` 确认环境正常

### 编译步骤

```bash
# 1. 进入项目目录
cd task_planner

# 2. 获取依赖
flutter pub get

# 3. 编译APK（debug版本）
flutter build apk --debug

# 4. 编译APK（release版本，推荐）
flutter build apk --release
```

编译完成后，APK文件位于：
```
build/app/outputs/flutter-apk/app-release.apk
```

### 安装到手机

**方法1: USB连接**
```bash
flutter install
```

**方法2: 手动安装**
将 `app-release.apk` 传输到手机，点击安装即可。

## 使用说明

1. **添加任务**: 在左侧"任务名称"列输入任务描述
2. **标记状态**: 点击右上角调色板图标选择颜色，然后点击日期单元格填充颜色
3. **切换颜色**: 再次点击已填充的单元格会清除颜色
4. **导出数据**: 点击右上角菜单 → 导出CSV
5. **清空数据**: 点击右上角菜单 → 清空数据

## 界面截图

```
┌─────────┬─────────┬─────────┬─────────┬─────────┐
│任务名称 │周一 3/17│周二 3/18│周三 3/19│周四 3/20│
├─────────┼─────────┼─────────┼─────────┼─────────┤
│项目A    │   🔴    │         │   🔵    │         │
├─────────┼─────────┼─────────┼─────────┼─────────┤
│项目B    │         │   🟢    │   🟢    │   🟢    │
├─────────┼─────────┼─────────┼─────────┼─────────┤
│会议     │   🟡    │   🟡    │         │         │
└─────────┴─────────┴─────────┴─────────┴─────────┘
```

## 扩展功能（可选）

如需添加以下功能，可进一步开发：

- [ ] 周末显示开关
- [ ] 自定义日期范围
- [ ] 多选批量操作
- [ ] 云端同步
- [ ] 任务提醒通知
- [ ] 数据备份还原

## 许可证

MIT License

---

**开发者**: OpenClaw AI Assistant  
**创建时间**: 2026-03-14
