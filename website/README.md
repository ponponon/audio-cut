# 本地音剪官网

`https://audio-cut.quniv.cn` 使用纯静态 HTML 与 CSS，由 OpenResty 提供。页面不依赖第三方字体、脚本、统计或广告服务。APK 文件由 Cloudflare R2 `audio-cut-releases` 桶提供，通过 `https://audio-cut-releases.quniv.cn` 下载；网站源站只返回重定向，不传输 APK 文件。官网 `/download` 指向 R2 中可覆盖更新的 latest APK 对象，`/releases/latest.json` 指向 R2 最新清单，后续版本由 GitHub Actions 更新。

## 发布内容

- `index.html`：产品介绍、真实应用截图、格式列表、下载和官网 APK 安装说明。
- `privacy-policy.html`：与应用当前数据处理行为一致的隐私政策。
- `assets/screenshots/`：实际运行的 Android 应用截图，供官网展示。
- `downloads/`：用长期 release 签名密钥签署的 arm64-v8a APK 本地发布副本；正式公开文件保存在 R2 对象 `releases/<version>/android/arm64-v8a/`，稳定下载别名为 `releases/latest/android/arm64-v8a/audio-cut-latest-arm64-v8a.apk`，不提交 Git。
- `LICENSE` 与 `THIRD_PARTY_NOTICES.md`：源代码许可和随包第三方组件说明。

官网安装包和直接分发到应用商店的 APK 必须继续使用同一签名密钥。不要将签名 keystore、`key.properties` 或密码放进这个目录。
