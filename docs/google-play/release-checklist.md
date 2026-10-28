# Google Play 发布清单

更新日期：2026-10-28。发布规则会调整；正式提交当天再核对 Play Console 的最新提示。

## 仓库已准备

- [x] Android release 不再使用 debug 签名；缺少上传密钥时，release 打包会给出明确错误。
- [x] `compileSdk` 和 `targetSdk` 设为 36，满足当前新应用要求。
- [x] 提供生成本机上传密钥和 `key.properties` 的脚本。
- [x] 隐私政策网页、简体中文商店资料和 Data safety 草稿。
- [x] 应用内可打开完整隐私说明。
- [x] Google Play 512×512 图标、1024×500 feature graphic，以及 Android/iOS launcher icon。
- [x] 至少两张真实应用截图：需从实际运行版本捕获，不能用概念稿冒充产品截图。
- [x] 截图由一加手机上的实际应用捕获；Play Console 版位于 `docs/google-play/screenshots/`，原比例展示版位于 `website/assets/screenshots/`。
- [x] Android 仅支持 arm64-v8a；发布前检查 AAB/APK 的原生库架构。
- [x] 官网及隐私政策通过 HTTPS 公开访问：`https://audio-cut.quniv.cn` 与 `https://audio-cut.quniv.cn/privacy-policy.html`。
- [x] 生成正式签名密钥；本机保留忽略 Git 的密钥文件和加密备份，GitHub Actions 使用环境级 Secrets 签名。
- [ ] 发布人选择并填写 Play Console 公开联系邮箱。
- [x] Google Play 开发者身份验证已完成；其他账号和发布待办以 Play Console 为准。
- [ ] 通过 GitHub Actions 生成并检查最终 `.aab`；正式上传前完成 Play Console 其他待办。

## 生成上传密钥并构建

在拥有 JDK 17、Flutter 3.47.x 和 Android SDK 36 的 Mac 上，从仓库根目录运行：

```sh
tooling/android/create-upload-key.sh
FLUTTER_SUPPRESS_ANALYTICS=true /private/tmp/audio_cut_flutter_sdk/flutter/bin/flutter build appbundle --release
```

APK 产物路径：`build/app/outputs/flutter-apk/app-release.apk`（需确认仅包含 arm64 原生库）。项目通过 `defaultConfig.ndk.abiFilters` 固定只打包 `arm64-v8a`，不能再传 `--split-per-abi`：

```sh
FLUTTER_SUPPRESS_ANALYTICS=true /private/tmp/audio_cut_flutter_sdk/flutter/bin/flutter build apk --release --target-platform android-arm64
```

网站/OEM 渠道的直装 APK 使用应用签名密钥。脚本会在 `android/` 下创建 `upload-keystore.jks` 和 `key.properties`；两者已被 Git 忽略。密钥和密码保留加密备份；绝不能提交到 Git 仓库或上传到 R2。经用户授权后，CI 可将它们存入 GitHub Actions 的环境级 Secrets。

## GitHub Actions 云端签名

`.github/workflows/android-release.yml` 在 GitHub Release 发布后使用 GitHub 托管的 Linux runner 构建签名 APK 和 AAB；也可从 GitHub Actions 页面手动运行 `workflow_dispatch`，手动运行只生成可下载的 Actions artifact。手动运行时选择 `main` 分支。Release 标签必须与 `pubspec.yaml` 的版本名一致，例如 `v0.1.2`。

签名私钥使用 GitHub Actions 环境 `android-release` 的 Secrets，不能设为仓库普通文件或提交进 Git：

- `ANDROID_RELEASE_KEYSTORE_BASE64`：`upload-keystore.jks` 的单行 Base64。
- `ANDROID_RELEASE_STORE_PASSWORD`：keystore 密码。
- `ANDROID_RELEASE_KEY_PASSWORD`：签名条目密码。

工作流只在发布事件或 `main` 分支的手动运行中读取这些 Secrets；外部 fork 的 Pull Request 不会触发签名任务。签名任务只有 `contents: read` 权限；独立的发布任务不接触签名密钥，只将构建产物附加到已发布的 GitHub Release。正式 Release 发布后，`publish_r2` 会使用单独的 `r2-release` 环境 Secrets 将 APK 和版本清单上传到 R2；它不会上传 Google Play。GitHub Secrets 是云端签名凭据，不是备份；本机加密备份仍须保留。

本应用计划同时通过官网和安卓应用商店分发，因此应在 Play App Signing 设置时选择提供自己的应用签名密钥，使 Google Play 与官网/OEM 安装包使用同一个应用签名证书。Google 也允许让其生成并保管应用签名密钥；若采用该选项，官网和其他商店必须使用 Play Console 导出的 Play 签名通用 APK，否则相同包名的不同签名无法原位升级。当前仓库生成的本地密钥既可用作自有应用签名密钥，也可直接用作上传密钥；若后续选择分离 upload key，应同步调整 Gradle 签名配置。

如果 Flutter SDK 位置改变，用 `flutter` 命令替换上述绝对路径即可。不要把上传密钥或密码传给别人，也不要在终端日志或截图中暴露 `key.properties` 内容。

## 首次 Play Console 建档

1. 创建应用并保持包名 `cn.quniv.audio_cut`。新应用名必须在 Play 上唯一；发布后不要随意更改包名。
2. 上传签名后的 Android App Bundle（`.aab`），加入 Play App Signing。
3. 填写 `store-listing-zh-CN.md` 中的名称、简介、完整说明、类别和联系信息。
4. 上传 512×512 图标、1024×500 feature graphic 和至少两张真实截图。截图使用 JPEG 或 24 位 PNG；单张短边至少 320px、长边不超过 3840px，最长边不能超过短边两倍。
5. 在 Privacy policy 栏填入公开可访问的 `privacy-policy.html` URL；Google Play 要求所有应用都提供线上隐私政策，并在应用内提供隐私政策链接或文本。
6. 完成 Data safety（按 `data-safety-draft.md` 再核对）、广告声明、目标受众、内容分级和应用访问声明。没有广告、账号和登录门槛。
7. 完成开发者身份验证及包名注册提示。2026 年 9 月起的开发者验证政策可能自动注册新 Play 应用包名；以账号后台显示状态为准。
8. 若 Play Console 个人开发者账号创建于 2023-11-13 之后，正式发布前需要至少 12 名测试者连续加入封闭测试 14 天，并在满足条件后申请生产权限。

## 当前已知发布门槛

- 2026-08-31 起，新应用和更新需要 target Android 16 / API 36 或更高；本项目配置为 API 36。
- 新应用使用 Android App Bundle 并启用 Play App Signing；上传的 AAB 仍须用本地上传密钥签名。
- 隐私政策 URL 必须在线、公开可读、不可编辑、非 PDF 且不按地域屏蔽。这个仓库已准备 `docs/` 静态页面；GitHub Pages 尚需在仓库设置里启用 `main / docs`，并验证页面上线。
- Play Console 中的测试、目标受众、内容分级、数据安全和公开联系邮箱需要账号持有人操作；这些设置不属于可提交到仓库的文件。
