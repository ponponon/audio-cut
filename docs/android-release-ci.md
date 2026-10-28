# Android 云端签名构建

项目使用 GitHub Actions 在 Linux runner 构建 Android release，不依赖个人 Mac 上的 Flutter 或 Android SDK。签名构建由 `.github/workflows/android-release.yml` 执行。

## 密钥存储

在仓库 `ponponon/audio-cut` 的 **Settings → Environments** 创建 `android-release` 环境，并配置以下 Environment secrets：

- `ANDROID_RELEASE_KEYSTORE_BASE64`：`android/upload-keystore.jks` 的 Base64 单行文本。
- `ANDROID_RELEASE_STORE_PASSWORD`：`android/key.properties` 中的 keystore 密码。
- `ANDROID_RELEASE_KEY_PASSWORD`：签名条目密码。

签名别名固定为 `audio_cut_upload`。可用本地 `gh` 命令通过标准输入设置 Secrets，避免在命令参数、日志或仓库文件中出现密码：

```sh
base64 < android/upload-keystore.jks | tr -d '\n' | gh secret set ANDROID_RELEASE_KEYSTORE_BASE64 --env android-release --repo ponponon/audio-cut
sed -n 's/^storePassword=//p' android/key.properties | gh secret set ANDROID_RELEASE_STORE_PASSWORD --env android-release --repo ponponon/audio-cut
sed -n 's/^keyPassword=//p' android/key.properties | gh secret set ANDROID_RELEASE_KEY_PASSWORD --env android-release --repo ponponon/audio-cut
```

GitHub 接收后只显示 secret 名称，不能重新读取其值。不要用 `gh secret list` 或设置页面确认 secret 内容；只确认名称存在。GitHub Actions 会将 Keystore 临时写到 runner 上，签名构建后删除，不会将它作为 artifact 上传。保留现有本机加密备份，不能把 GitHub Secrets 当成唯一副本。

## 运行方式

- 在 GitHub 网页创建并发布 Release，标签必须匹配 `pubspec.yaml` 的版本名，例如版本 `0.1.2+2003` 对应标签 `v0.1.2`。工作流构建 arm64 APK 和 AAB，并把两者附加到该 Release。
- 从 **Actions → Android signed release → Run workflow** 手动运行时选择 `main`。它生成签名 APK/AAB 的 Actions artifact，不会创建或发布 GitHub Release。
- Pull Request 不会获得签名 Secrets；签名任务使用 `contents: read`，上传 Release 资产的独立任务才获得 `contents: write`。
- 工作流只构建并发布 GitHub Release 资产；不会自动上传 Google Play 或 R2。

## 官网 R2 分发

官网 `/download` 只重定向到 `https://audio-cut-releases.quniv.cn`，APK 本体不应放在京东云 OpenResty 源站。当前版本对象位于 `audio-cut-releases/releases/0.1.2/android/arm64-v8a/audio-cut-0.1.2-arm64-v8a.apk`。

发布新版本时，将已签名 APK 上传到 `audio-cut-releases/releases/<version>/android/arm64-v8a/`，并设置 `Content-Type: application/vnd.android.package-archive`、`Content-Disposition: attachment`、`Cache-Control: public, max-age=31536000, immutable`。同步更新 R2 的 `manifest/<version>.json`、`manifest/latest.json`、网站的 `website/releases/latest.json` 和 OpenResty `/download` 重定向。最后沿官网 `/download` 检查 302 的目标域名、APK SHA-256，以及最终 GET 的 `Server: cloudflare` 和 `CF-Cache-Status: HIT`。

应用签名私钥可用于官网直装 APK 的更新校验，应长期保护。若后续在 Play App Signing 中另生成 upload key，应分别配置并更新 CI 流程，保持官网安装包和 Play 用户端签名关系正确。
