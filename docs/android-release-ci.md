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
- 从 **Actions → Android signed release → Run workflow** 手动运行时选择 `main`，不填写发布标签即可只生成签名 APK/AAB artifact。若要恢复发布到一个已存在的 Release，可填写与 `pubspec.yaml` 版本一致的 `publish_release_tag`；默认从该标签构建、附加 APK/AAB 并发布 R2。标签必须已存在，且位于 `main` 历史中。
- 如果已有 Release 因依赖锁文件等元数据问题无法构建，可同时启用 `build_from_main`，从当前 `main` 恢复该 Release。工作流会验证 `pubspec.yaml`、`lib/`、`android/`、`ios/` 和 `assets/` 与标签代码相同；只有这些应用源码未变化时才允许继续。用相同 Flutter 版本和 CI 使用的 `pub.dev` 更新锁文件后，再运行此恢复方式；它不会改写已有远程标签。
- Pull Request 不会获得签名 Secrets；签名任务使用 `contents: read`，上传 Release 资产的独立任务才获得 `contents: write`。
- `android-release` 环境必须允许 `main` 分支和 `v*` 标签部署；只设置 `v*` 分支规则不会放行 GitHub Release 标签。工作流会把 APK/AAB 附加到 Release，并自动把 APK 与最新版本清单发布到 R2。工作流不会自动上传 Google Play。

## 官网 R2 分发

官网 `/download` 只重定向到 `https://audio-cut-releases.quniv.cn`，APK 本体不应放在京东云 OpenResty 源站。每次 Release 会保存不可变的版本对象 `releases/<version>/android/arm64-v8a/audio-cut-<version>-arm64-v8a.apk`，并覆盖 `releases/latest/android/arm64-v8a/audio-cut-latest-arm64-v8a.apk`。latest 对象和清单的 R2 缓存头为 60 秒，版本对象与版本清单使用一年不可变缓存。`quniv.cn` 区域的 Cloudflare Cache Rule 还需对 stable APK 与 `/manifest/latest.json` 强制设置 60 秒 Browser TTL；只查看 R2 对象元数据不足以确认用户浏览器收到的缓存头。

官网直装 arm64 APK 压缩原生 `.so` 以减小下载体积；App Bundle 生成的设备 APK 不受 `useLegacyPackaging` 影响。发布后分别核对 APK 下载大小、签名、安装占用及设备行为，不能把下载体积当作安装占用。

### 凭据配置

在 GitHub 仓库 `ponponon/audio-cut` 的 **Settings → Environments → r2-release** 中设置：

- Secret `R2_ACCESS_KEY_ID`：复用本机已有的同名环境变量。
- Secret `R2_SECRET_ACCESS_KEY`：复用本机已有的同名环境变量。
- Variable `CLOUDFLARE_ACCOUNT_ID`：复用本机已有的同名环境变量。

本项目的 `r2-release` GitHub Actions 环境已复用这些现有值。上传任务使用 AWS CLI 访问 R2 的 S3 兼容 API，因此需要 `R2_ACCESS_KEY_ID`、`R2_SECRET_ACCESS_KEY` 和 Account ID；`CLOUDFLARE_API_TOKEN` 用于 Wrangler/Cloudflare API 操作，不由当前上传任务读取。设置 Secret 时不得把值打印到日志、写入文件或提交到 Git。复用前先确认凭据能访问目标桶，并尽量采用满足任务所需的最小权限。Android 签名密钥仍仅存在于 `android-release` 环境。

### 自动发布

创建并发布与 `pubspec.yaml` 版本一致的 GitHub Release（例如版本 `0.1.2+2003` 使用标签 `v0.1.2`）。工作流将签名 APK 上传到版本对象与 latest 对象，并同步 R2 的 `manifest/<version>.json`、`manifest/latest.json`。官网 `/download` 和 `/releases/latest.json` 分别重定向到 R2 的稳定 APK 和 latest 清单；以后无需登录 OpenResty 服务器更新下载 URL。

发布后检查官网 `/download` 最终落到 `audio-cut-releases.quniv.cn`，并核对 latest 清单中的 APK SHA-256 与签名证书 SHA-256。检查 stable 下载 Range 响应应为 `206`，并确认 `Cache-Control: public, max-age=60`；Cloudflare 缓存传播和手机运营商路由可能有短暂差异。

应用签名私钥可用于官网直装 APK 的更新校验，应长期保护。若后续在 Play App Signing 中另生成 upload key，应分别配置并更新 CI 流程，保持官网安装包和 Play 用户端签名关系正确。
