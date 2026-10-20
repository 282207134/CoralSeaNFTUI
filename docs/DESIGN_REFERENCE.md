# Pixso 设计来源与实现映射

来源文件：**CoralSea NFT UI KIT**；页面：**✒️UI**（`101:12`）。2026-10-20 通过已连接的 Pixso MCP 读取，未改动原设计文件。原页面包含 48 组流程画面及明暗变体，部分为同一页面的弹层、下拉或加载状态。

| 参考图 | Pixso 节点 | 内容 | Flutter 实现 |
| --- | --- | --- | --- |
| `design_reference/screen_0.png` | `142:477` | 首页 Light | HomeScreen |
| `design_reference/screen_1.png` | `186:2357` | 首页 Dark | 同一页面 + darkTheme |
| `design_reference/screen_2.png` | `199:1660` | 详情 | DetailScreen + CheckoutScreen |
| `design_reference/screen_3.png` | `284:1338` | 引导 | OnboardingScreen |
| `design_reference/screen_4.png` | `475:8472` | 个人主页 | ProfileScreen |
| `design_reference/screen_5.png` | `442:6450` | 创建作品 | CreateScreen |
| `design_reference/screen_6.png` | `440:4541` | 热门分类 | ExploreScreen |
| `design_reference/screen_7.png` | `472:4775` | 搜索 | SearchScreen |
| `design_reference/screen_8.png` | `527:8817` | 设置 | SettingsScreen |
| `design_reference/screen_9.png` | `532:8639` | 钱包 | WalletScreen |
| `design_reference/screen_10.png` | `286:1768` | 连接钱包 | ConnectWalletScreen |

## 素材

`assets/images/` 中的门廊、拱廊、四张艺术作品、四个头像、个人页封面、Logo 和引导页拼贴均从对应 Pixso 节点导出。图片以适合移动端显示的尺寸打包，全部可离线使用。字体来自 [Google Fonts Plus Jakarta Sans](https://github.com/google/fonts/tree/main/ofl/plusjakartasans)，授权保存在 `assets/fonts/OFL.txt`。

## 实现适配

- 保留原稿英文界面，Markdown 交付文档为中文。
- iOS 状态栏/底部手势指示条由设备系统提供，不把设计稿中的静态系统栏画入 Flutter。
- 长设计画布转为原生滚动布局，底部导航固定在屏幕下沿。
- 原稿中重复的明暗页、结算加载页、下拉选择状态合并为可交互组件及页面状态。
- 创建功能当前支持图片，使用真实相册选择或示例素材。视频、音频和 3D 模型上传未接入。
- 用户收藏/购买/创建列表由实际本地操作驱动，初始个人收藏为空。
- 未配置真实社区账号，设置页使用通知、主题、帮助和应用信息等可操作入口。

这些调整使界面可以运行、测试和继续开发；未将整页设计截图作为主界面使用。引导页上半部为原稿中的静态拼贴插画，其余页面均使用 Flutter 组件构建。
