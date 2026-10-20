# CoralSea NFT Marketplace

基于 Pixso **CoralSea NFT UI KIT** 实现的 Flutter App。保留设计稿的作品素材、黄色主题、明暗模式和主要页面布局，提供可操作的本地模拟数据。

## 已实现

- 引导、模拟钱包连接/跳过、合法 Ethereum 地址校验。
- 首页新作品、卖家排行、热门合集、分类、价格排序与搜索。
- 作品详情、图片缩放、收藏、概览/报价/上架/活动标签。
- 模拟购买、报价、成功反馈及个人收藏和历史更新。
- 创建作品：示例图/相册、名称、描述、定价、竞价、合集、分类、版税、属性和替代文本。
- 个人中心、钱包、演示余额操作、通知、FAQ、主题切换。
- 收藏、创建作品、钱包状态、活动和设置在重启后保留。

运行时第三方依赖仅 `shared_preferences` 与 `image_picker`。所有展示图片和字体本地打包。

## 运行

本机验证使用 Flutter 3.35.7 / Dart 3.9.2。建议使用相同版本或兼容的新版本；Android 需要 Android SDK 和 JDK，iOS 需要 macOS 与 Xcode。

```sh
flutter --no-version-check pub get
flutter --no-version-check devices
flutter --no-version-check run -d <设备ID>
```

Android 模拟器可用 `flutter emulators` 查看并通过 `flutter emulators --launch <模拟器ID>` 启动。Web 可运行 `flutter --no-version-check run -d chrome`。

```sh
flutter --no-version-check analyze
flutter --no-version-check test
flutter --no-version-check build apk --debug
flutter --no-version-check build apk --release --split-per-abi
flutter --no-version-check build web --release
```

`--no-version-check` 仅跳过 Flutter 自身的版本更新检查。当前机器配置了自定义输出目录 `build_temp`，构建产物以实际命令输出路径为准。

同一工程的构建和测试命令应顺序执行。此 Flutter 版本在运行集成测试后生成 Release 时，应保留构建命令默认的依赖准备步骤，避免使用 `--no-pub` 跳过原生插件注册文件的更新。参见 [Flutter SDK 已知问题](https://github.com/flutter/flutter/issues/169336)。

已生成的 Android 安装包位于 `build/app/outputs/flutter-apk/`。普通 Android 手机优先安装 `app-arm64-v8a-release.apk`（约 20.7 MB）；模拟器使用 `app-x86_64-release.apk`。当前使用调试证书签名，仅供本地试用。

## 模拟器端到端测试及截图

```sh
flutter --no-version-check drive --driver=test_driver/integration_test.dart --target=integration_test/app_flow_test.dart -d <Android设备ID>
```

测试会清空**本 App 的本地演示数据**，按顺序验证引导、购买、收藏展示、暗色主题、搜索和创建作品，并保存截图至 `docs/screenshots/`。日常运行不会清空数据。

## 文档

- [项目结构与架构说明](docs/ARCHITECTURE.md)
- [Pixso 设计映射与适配说明](docs/DESIGN_REFERENCE.md)
- [验证记录](docs/VERIFICATION.md)

当前为本地交互演示。购买、报价、铸造、钱包充值/转账/兑换均为模拟，不会发送真实交易；图片上传当前支持照片，不包含视频、音频和 3D 模型。iOS 工程已生成，需在 macOS 上另行编译和验证。正式发布需接入后端、钱包及链上服务，并配置发布签名。
