# Google Play 图形素材

- `app-icon-512.png`：商店图标，512×512 PNG。
- `app-icon-1024.png`：高分辨率母版；由它生成 Android/iOS 启动图标。
- `feature-graphic-1024x500.jpg`：商店 Feature graphic，1024×500 JPEG（无 Alpha 通道）。

`tooling/generate_google_play_assets.swift` 生成母版；`tooling/update_launcher_icons.sh` 将图标缩放到 Android 和 iOS 所需尺寸。界面截图必须来自真实运行的应用，不能用这张 feature graphic 替代。
