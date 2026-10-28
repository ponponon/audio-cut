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
- `workflow_dispatch` 仅用于手动签名构建和 artifact 检查；发布 GitHub Release 时，工作流会把 APK/AAB 附加到 Release，并自动把 APK 与最新版本清单发布到 R2。工作流不会自动上传 Google Play。

## 官网 R2 分发

官网 `/download` 只重定向到 `https://audio-cut-releases.quniv.cn`，APK 本体不应放在京东云 OpenResty 源站。每次 Release 会保存不可变的版本对象 `releases/<version>/android/arm64-v8a/audio-cut-<version>-arm64-v8a.apk`，并覆盖 `releases/latest/android/arm64-v8a/audio-cut-latest-arm64-v8a.apk`。latest 对象和清单的 R2 缓存头为 60 秒，版本对象与版本清单使用一年不可变缓存。`quniv.cn` 区域的 Cloudflare Cache Rule 还需对 stable APK 与 `/manifest/latest.json` 强制设置 60 秒 Browser TTL；只查看 R2 对象元数据不足以确认用户浏览器收到的缓存头。

### 首次配置

在 Cloudflare R2 为 `audio-cut-releases` 创建一个 API token：权限选 **Object Read & Write**，范围只选这个 bucket。不要选 Admin，也不要复用 Wrangler 的全账户 token。该 token 仅通过 S3 兼容 API 使用。

在 GitHub 仓库 `ponponon/audio-cut` 的 **Settings → Environments → r2-release** 中设置：

- Secret `R2_ACCESS_KEY_ID`：R2 token 的 Access Key ID。
- Secret `R2_SECRET_ACCESS_KEY`：R2 token 的 Secret Access Key。
- Variable `CLOUDFLARE_ACCOUNT_ID`：R2 Overview 中的 Account ID。

本项目已为 `r2-release` 环境配置上述 Account ID，并保存了 bucket 范围的上传密钥。该 Cloudflare token 有效期为一年；到期前创建新的同权限 token、替换两个 Secrets，再撤销旧 token。Android 签名密钥仍仅存在于 `android-release` 环境。

### 自动发布

创建并发布与 `pubspec.yaml` 版本一致的 GitHub Release（例如版本 `0.1.2+2003` 使用标签 `v0.1.2`）。工作流将签名 APK 上传到版本对象与 latest 对象，并同步 R2 的 `manifest/<version>.json`、`manifest/latest.json`。官网 `/download` 和 `/releases/latest.json` 分别重定向到 R2 的稳定 APK 和 latest 清单；以后无需登录 OpenResty 服务器更新下载 URL。

发布后检查官网 `/download` 最终落到 `audio-cut-releases.quniv.cn`，并核对 latest 清单中的 APK SHA-256 与签名证书 SHA-256。检查 stable 下载 Range 响应应为 `206`，并确认 `Cache-Control: public, max-age=60`；Cloudflare 缓存传播和手机运营商路由可能有短暂差异。

应用签名私钥可用于官网直装 APK 的更新校验，应长期保护。若后续在 Play App Signing 中另生成 upload key，应分别配置并更新 CI 流程，保持官网安装包和 Play 用户端签名关系正确。
