# 本地音剪官网

`https://audio-cut.quniv.cn` 使用纯静态 HTML 与 CSS，直接由 OpenResty 提供。页面不依赖第三方字体、脚本、统计或广告服务。

## 发布内容

- `index.html`：产品介绍、真实应用截图、格式列表、下载和官网 APK 安装说明。
- `privacy-policy.html`：与应用当前数据处理行为一致的隐私政策。
- `assets/screenshots/`：实际运行的 Android 应用截图，供官网展示。
- `downloads/`：用长期 release 签名密钥签署的 arm64-v8a APK；APK 文件本身保存在发布存储，不提交 Git。
- `LICENSE` 与 `THIRD_PARTY_NOTICES.md`：源代码许可和随包第三方组件说明。

官网安装包和直接分发到应用商店的 APK 必须继续使用同一签名密钥。不要将签名 keystore、`key.properties` 或密码放进这个目录。
