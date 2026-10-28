# 失败经验

记录开发中确认的问题、修正方式和避免复发的方法。

## 用户反馈

- 首版 UI 使用近黑背景、薄荷绿大按钮、多层大圆角卡片和口号式大标题，用户明确反馈观感很差。重做前先确认具体参考；本项目按用户指定的 iOS「语音备忘录」方向，使用系统浅/深色和更清晰的波形层级。之后用户又认为珊瑚红太刺激，已替换为森林绿。不要用堆卡片和装饰性大标题代替明确的编辑流程。
- 用户要求支持系统大字号并保证对比度。Flutter 文本默认跟随系统缩放，但固定高度容易造成裁切；按钮应使用最小高度，时间控件应在较大字号下改为纵向布局，并在模拟器中实际检查。
- 用户认为语音备忘录的珊瑚红显得吓人。主色改为低调的微信绿系森林绿，并保证按钮前景色在浅色和深色主题中都有足够对比；避免把整页染成高饱和绿色。
- 用户希望简单支持液态玻璃。Flutter 内置 `BackdropFilter` 只能提供模糊与半透明的视觉近似；只在底部导出栏做一处有边界的玻璃表面，避免额外插件、全屏模糊和不必要的合成开销。
- 多语言最初只跟随系统语言，没有应用内入口，导致用户无法直接切换界面语言。提供多语言时应同时提供清楚的应用语言设置入口，并在本机保存用户选择；保留“跟随系统”选项。
- 导出格式弹层曾用不可滚动的 `Column` 展示多个格式；在内容超过屏幕高度（包括系统大字号）时，底部的 OGG/Opus 会被裁掉。弹层内容应限制最大高度并放入 `SingleChildScrollView`，确保所有格式都能滚动访问；不要只依赖可拖动的手柄。
- 用户反馈应用图标深绿底太重。选择品牌绿时应搭配浅色背景，按用户指定的 `#07C160` 保持主色准确，并从同一母版生成 Android、iOS 与商店图标，避免平台素材配色不一致。
- 用户已明确认可浅薄荷底、`#07C160` 波形的当前 logo，并要求以后不要改动。该图标应作为锁定品牌资产；没有用户明确改图要求时，不要因其他设计调整而改造或重生成它。

## 已确认约束

- 原版 FFmpegKit 已停止维护，不能把原包作为新项目的依赖。当前候选是近期维护的 `ffmpeg_kit_flutter_new_audio`；升级依赖时要重新核验 Android/iOS 支持、编解码器清单和许可证。
- 文件扩展名不能证明实际编码格式。导入后必须用媒体探测结果判断是否能解码，错误提示应说明格式或文件问题，而不能只按后缀放行。
- MP3 等有损格式重新编码会损失质量；导出时应说明转码行为。后续无损裁切要单独设计和验证。
- `file_picker` 13 的 `saveFile` 需要先提供完整 `Uint8List`，不适合大音频直接导出；先写入应用私有临时文件，再交给系统分享面板，避免把整份音频读进内存。
- Flutter SDK 需要匹配开发机 CPU 架构。Apple Silicon 必须下载 ARM64 包；误用 x64 Dart 会在本机初始化/分析时崩溃。

## 发布准备经验

- Flutter 模板可能让 Android release 沿用 debug 签名；正式包必须明确使用上传密钥，并将私钥及密码排除在 Git 之外。
- Play 对隐私政策和 Data safety 的要求也适用于不收集数据的应用。隐私政策既要有公开网页，也要在应用内提供链接或文本；Play Console 声明必须基于最终 release 包和全部依赖。
- 商店素材不能沿用 Flutter 模板的默认图标。截图必须来自真实运行的应用，不能用营销图或概念图代替。
- Flutter 3.35 之后会默认把 armeabi-v7a、arm64-v8a 和 x86_64 加入 Android ABI 过滤器。只支持 arm64 时，`defaultConfig.ndk.abiFilters` 必须先 `clear()` 再添加 `arm64-v8a`；只用 `+=` 会保留 Flutter 自动加入的其他架构。自定义 `ndk.abiFilters` 时也不要同时传 `--split-per-abi`。

## 2026-10-28：小米安装报解析错误时先校验手机实际下载文件

- 现象：REDMI K90 Pro Max（Android 17）较早下载的官网 APK 安装时提示“解析软件包时出现问题。(33) / packageInfo is null”。
- 原因：较早保存在手机上的 APK 虽然大小仍为 39,798,089 字节，但 SHA-256 为 `b2fa5ede4a1deb362840ad38304b90510e187ae8a2bec077084dfb76e0dc5660`，与正式 APK 不同；APK v2 摘要和 ZIP CRC 均校验失败。后来在 Redmi Chrome 中从官网直接重新下载的 APK 与正式包 SHA-256 均为 `62889942d6c40d34898585f7f579d8735c1a7d87e0da36900296d49f48ff128`，签名和 ZIP 校验通过。较早文件为何损坏尚未确定。
- 处理：在目标手机的 Chrome 中直接从官网重新下载，并核对该手机实际下载件的 SHA-256、签名和 ZIP 完整性；用户随后确认安装成功。
- 经验：用户要求验证官网/应用商店下载时，必须在目标手机浏览器或商店真实下载；不能用 Mac 上的 APK 经 ADB 传输来替代。文件大小相同不能证明 APK 完整。需要区分“下载来源”和“打开安装器的方式”，不能把 Mac→ADB 的测试说成官网直下。

## 2026-10-28：官网直下测试与 APK 分发源站混淆

- 补正：较早保存在 Redmi 上的 APK 哈希错误、签名摘要和 ZIP CRC 校验失败；随后在 Redmi Chrome 中从官网直接重新下载的 APK 与正式包 SHA-256 均为 `62889942d6c40d34898585f7f579d8735c1a7d87e0da36900296d49f48ff128`，签名和 ZIP 校验通过，用户确认现在可正常安装。较早文件的损坏原因尚未确定。
- 错误：用户要求验证官网实际下载时，曾把 Mac 本地 APK 通过 ADB 传到手机，测试路径不符合要求。之后必须在目标手机浏览器/商店直接下载；若只用 ADB 打开安装器，明确说明 ADB 只启动了安装动作，不能把它冒充成下载验证。
- 错误：APK 虽已存在 `audio-cut-releases` R2 桶，官网 `/download` 仍从 OpenResty 小带宽源站发送 APK，造成约 5 MB/s 的速度上限；且 R2 对象初始 `Cache-Control` 为 `private, max-age=0, no-cache`。对象在 R2 里不等于下载流量走 R2，发布前必须沿官网按钮检查最终跳转域名、Cloudflare 缓存响应头和对象 SHA-256。

## 2026-10-28：R2 对象缓存头不等于浏览器实际缓存时长

- 现象：stable APK 在 R2 中设置了 `Cache-Control: public, max-age=60`，但经过 Cloudflare 自定义域名的响应仍返回 `max-age=14400`。
- 原因：`quniv.cn` 区域原有 Browser Cache TTL 会覆盖源站下发给浏览器的缓存时长。单看 R2 元数据无法确认最终用户收到的缓存策略。
- 处理：为 `audio-cut-releases.quniv.cn` 上的 stable APK 和 `/manifest/latest.json` 新增 Cloudflare Cache Rule，强制 Browser TTL 为 1 分钟；边缘缓存继续尊重 R2 对象缓存头。通过官网 `/download` 发起 Range 请求，确认最终响应为 `206` 且 `Cache-Control: public, max-age=60`。
- 经验：凡是经 CDN 分发会覆盖更新的稳定 URL，都要沿真实公开入口验证最终响应头，不能只检查对象存储元数据；版本化不可变对象与 stable alias 应采用不同缓存策略。

## 2026-10-28：先复用现有 Cloudflare 凭据，再决定是否新建

- 错误：配置 R2 GitHub Actions 时没有先检查用户已提供的 `CLOUDFLARE_ACCOUNT_ID`、`CLOUDFLARE_API_TOKEN`、`R2_ACCESS_KEY_ID` 和 `R2_SECRET_ACCESS_KEY`，因此额外创建了一枚 R2 token。
- 处理：通过不输出凭据值的方式确认本机已有 R2 S3 凭据，并用只读检查和临时对象写入/删除验证目标桶权限；把现有 `R2_ACCESS_KEY_ID`、`R2_SECRET_ACCESS_KEY` 更新到 GitHub `r2-release` Secrets 后，撤销本次多创建的 token。
- 经验：创建云端凭据前先检查已有环境变量和 GitHub Secret 名称；区分 Wrangler 使用的 Cloudflare API token 与 S3 兼容 API 使用的 R2 Access Key/Secret。只有现有凭据缺失或权限不匹配时才创建新凭据，并且不要输出、提交任何凭据值。

## 2026-10-28：官网直装 APK 要单独检查原生库压缩策略

- 错误：分析 39.8 MB APK 时只看到 `.so` 在 ZIP 中未压缩，误以为进一步压缩空间有限，漏掉了 Android Gradle Plugin 的 `useLegacyPackaging`。
- 处理：对现有 APK 的 13 个 arm64 `.so` 做 DEFLATE 6 模拟后，估算整个 APK 可从约 39.8 MB 降至约 19.4 MB。实际构建的 0.1.3 APK 为 19,337,565 字节，比 0.1.2 少 20,460,524 字节（约 51.4%）。该选项会在安装时解压原生库，下载变小但设备安装占用增加；直接 APK 与 App Bundle 生成包的行为需分开检查。
- 经验：讨论 APK 体积时要区分下载体积、安装占用和安装耗时，并核对 `useLegacyPackaging`、App Bundle 与 16 KB 页面大小要求；不要只凭 ZIP 当前压缩状态推断没有低风险优化。

## 2026-10-29：GitHub Release 标签发布需要匹配环境规则和 CLI 仓库上下文

- 现象：手动签名构建通过，但发布标签触发的 build 因 `android-release` 环境只允许 `main` 和 `v*` 分支、未允许 `v*` 标签而被拒绝；放行标签后，附件 job 又因没有 checkout 仓库而无法运行 `gh release upload`。
- 处理：保留 `main` 限制并为签名环境添加 `v*` 标签策略；Release 上传命令显式传入 `--repo "$GITHUB_REPOSITORY"`。同时给 `workflow_dispatch` 增加可选的已存在 Release 标签输入，默认仍只构建 artifact，只有明确填写标签才会发布。
- 经验：GitHub Release 的 `GITHUB_REF` 是标签，环境规则需要将 tag 与 branch 分开配置；只下载 artifact 的 job 不应假定有 `.git` 仓库，调用 `gh` 时显式提供 `--repo`。Release 失败后不要改写已有远程标签，应通过受校验的发布恢复入口继续上传。
