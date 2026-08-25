# Prinia

[English](README.md)

一款面向学生的本地优先效率应用。Prinia 将记账、番茄钟和课表整合进一个纯离线的 Android 应用，并支持基于蓝牙的设备间数据同步。

## 功能

### 记账本
- 收支记录，内置 7 个支出分类，支持自定义标签
- 月度统计：结余卡片、每日支出柱状图（0-300 坐标系）、分类占比饼图
- 点击柱状图可查看单日金额；饼图跟随柱状图选中日期联动
- 自定义标签：图标支持关键词搜索，未命中时返回猫猫头
- 删除带确认，采用软删除

### 番茄钟
- 专注/休息时长可自定义（重启后保留）
- 专注-休息循环计时，完成时震动加提示音
- 专注期间切出应用：自动暂停并推送通知提醒返回
- 统计页：近 7 天折线图与按日分组的历史记录

### 课表
- 24 小时时间轴周视图，带"当前时间"指示线
- 上课时间与时长按 15 分钟步进
- 支持一周多天建课、自定义卡片颜色、周次范围、卡片字号调节
- 长按快速移动课程（带冲突检测，冲突方向置灰）
- 自定义提醒：截止日当天 8:00 本地通知

### 多设备同步（安卓对安卓）
- 蓝牙 RFCOMM 传输：无需网络、无需热点，校园网隔离环境可用
- CRDT（按行 LWW）合并：任意设备上的修改自动收敛
- 增量传输 + 按对端游标记录；首次会话为全量同步
- 对端应用运行时，本地编辑防抖后自动推送
- 可勾选参与同步的已配对设备

### 通用
- 饭点记账提醒：每日两个可自定义时刻的本地通知
- 8 套内置配色主题 + 自定义配色板编辑器（12 个语义色、HSV 取色器、hex 输入）
- 自适应布局：手机底部导航，平板侧边导航栏
- 高刷新率支持（设备支持时最高 120 fps）
- 数据全部存储于本地 SQLite（Drift）；每行携带 `uuid`、`updated_at`、`device_id`、`is_deleted` 字段以支持 CRDT 合并

## 平台

- Android（手机与平板），支持 Flutter 3.47 的 API 级别
- **Windows：暂不支持、未经测试。** 仓库中包含 Windows runner 文件，CI 也可以构建，但不提供任何测试与支持

## 构建

环境要求：

- Flutter 3.47.1 (stable)
- Android SDK：platform 36、build-tools 34+、NDK 28.2、CMake 3.22.1
- JDK 17

```bash
flutter pub get
flutter build apk --release --split-per-abi
```

产物位于 `build/app/outputs/flutter-apk/`。安装与设备 ABI 匹配的包（通常为 `app-arm64-v8a-release.apk`）。

推送 `v*` 标签时，GitHub Actions 会自动构建并发布 Release。

## 目录结构

```
lib/
  app/            应用外壳与自适应导航
  core/
    theme/        基于 oklch 的主题引擎、8 套预设、自定义配色板
    db/           Drift 表结构、DAO、provider
    icons/        精选图标目录与关键词搜索
    notifications/ 本地通知服务
    sync/         CRDT 同步：协议、引擎、蓝牙传输
  features/
    ledger/       记账本
    pomodoro/     番茄钟
    timetable/    课表
    settings/     主题、同步、提醒、数据管理
  shared/         共享组件
```

## 许可证

本项目基于 [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0) 开源。
