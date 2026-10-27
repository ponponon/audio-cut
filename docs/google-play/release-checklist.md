# Google Play 发布清单

更新日期：2026-10-27。发布规则会调整；正式提交当天再核对 Play Console 的最新提示。

## 仓库已准备

- [x] Android release 不再使用 debug 签名；缺少上传密钥时，release 打包会给出明确错误。
- [x] `compileSdk` 和 `targetSdk` 设为 36，满足当前新应用要求。
- [x] 提供生成本机上传密钥和 `key.properties` 的脚本。
- [x] 隐私政策网页、简体中文商店资料和 Data safety 草稿。
- [x] 应用内可打开完整隐私说明。
- [x] Google Play 512×512 图标、1024×500 feature graphic，以及 Android/iOS launcher icon。
- [ ] 至少两张真实应用截图：需从实际运行版本捕获，不能用概念稿冒充产品截图。
- [ ] 发布人选择并填写 Play Console 公开联系邮箱。
- [ ] GitHub Pages 启用后，从公开网络验证隐私政策 URL 正常访问。
- [ ] 使用 Play Console 生成并检查最终 `.aab`；当前环境没有启动 ADB daemon，且上传密钥尚未生成。

## 生成上传密钥并构建

在拥有 JDK 17、Flutter 3.47.x 和 Android SDK 36 的 Mac 上，从仓库根目录运行：

```sh
tooling/android/create-upload-key.sh
FLUTTER_SUPPRESS_ANALYTICS=true /private/tmp/audio_cut_flutter_sdk/flutter/bin/flutter build appbundle --release
```

产物路径：`build/app/outputs/bundle/release/app-release.aab`。脚本会在 `android/` 下创建 `upload-keystore.jks` 和 `key.properties`；两者已被 Git 忽略。把这两个文件一起放进加密备份或密码管理器，绝不能提交到 GitHub。Play App Signing 中让 Google 管理最终应用签名密钥，仓库中的密钥只作为上传密钥。

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
