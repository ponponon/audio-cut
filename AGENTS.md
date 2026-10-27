# 项目约定

- 本应用的音频解码、预览、剪切和导出全部在设备本地完成。不得新增登录、云同步、上传、广告、远程分析或音频相关网络请求。
- 只通过系统文件选择器读取用户主动选中的文件；应用不得申请不必要的存储、麦克风或网络权限。
- 修改 UI 前，先检查目标组件源码、同类控件实现、图标定义和设计 token；检查后再实现，完成后核对视觉一致性。
- 开始 UI 设计前阅读 `PRODUCT.md` 和 `DESIGN.md`，并保持实现与已确认的产品方向、无障碍规范一致。
- 开始开发前阅读 `FEATURE.md` 和 `FailureExperience.md`。
- Android 发布前阅读 `docs/google-play/release-checklist.md`；上传密钥和 `key.properties` 只能留在本机安全备份，不能提交到 Git。
- 音频处理依赖本机运行，不得因发布接入远程处理、统计或广告 SDK；隐私政策和 Data safety 声明必须与实际 release 包一致。

每次新增加功能，都要加到 FEATURE.md 里面，为什么要这样做？为了以后可以换一个 AI 的时候，可以从 0 到 1 重新创建

每次我指正出来的错误，得到的经验都要加到 FailureExperience.md 文件里面，避免再次犯错

且记得阅读 FEATURE.md 和 FailureExperience.md，方便了解项目的上下文
