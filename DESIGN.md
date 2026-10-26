---
name: 本地音剪
description: 一款参考 iOS 语音备忘录、在设备本机完成音频剪辑的工具
colors:
  primary: "#167A4B"
  primary-dark: "#63CC90"
  canvas-light: "#F4F7F4"
  canvas-dark: "#0D1510"
  surface-light: "#FFFFFF"
  surface-dark: "#19221B"
  surface-secondary-light: "#E6EFE7"
  surface-secondary-dark: "#253128"
  ink-light: "#1C271F"
  ink-dark: "#EEF5EF"
  secondary-ink-light: "#58675C"
  secondary-ink-dark: "#A8B7AB"
  separator-light: "#D0DBD2"
  separator-dark: "#3A493E"
  waveform-track-light: "#F2F7F3"
  waveform-track-dark: "#111A14"
  glass-surface-light: "#FFFFFF / 91% opacity"
  glass-surface-dark: "#151E18 / 85% opacity"
  glass-blur: "14dp"
  glass-radius: "22dp"
typography:
  display:
    fontFamily: "Platform system (SF Pro on iOS, Roboto on Android)"
    fontSize: "28sp"
    fontWeight: 700
    lineHeight: 1.15
  title:
    fontFamily: "Platform system"
    fontSize: "21sp"
    fontWeight: 600
    lineHeight: 1.2
  body:
    fontFamily: "Platform system"
    fontSize: "16sp"
    fontWeight: 400
    lineHeight: 1.45
  label:
    fontFamily: "Platform system"
    fontSize: "13sp"
    fontWeight: 500
    lineHeight: 1.3
rounded:
  waveform: "11dp"
  button: "14dp"
  group: "16dp"
  surface: "18dp"
spacing:
  xs: "4dp"
  sm: "8dp"
  md: "12dp"
  lg: "16dp"
  xl: "20dp"
  xxl: "24dp"
components:
  button-primary:
    backgroundColor: "{colors.primary}"
    textColor: "#FFFFFF"
    rounded: "{rounded.button}"
    padding: "20dp 15dp"
    height: "52dp"
---

# Design System: 本地音剪

## 1. Overview

**Creative North Star: “安静的私人剪辑台”**

界面参考 iOS「语音备忘录」：系统原生字体、清晰的信息层级，以及让波形和剪辑范围成为主角。所有视觉细节都服务于“选择、设定、试听、导出”这一条本机工作流。

浅色和深色外观跟随系统。页面以平整的系统背景承托少量白色或深绿灰内容面板，柔和的森林绿标记主要操作和当前选区。底部导出栏采用单层半透明模糊，提供轻量液态玻璃观感；隐私说明保持简短、可见。

**Key Characteristics:**
- 熟悉、克制的 iOS 工具感。
- 波形和起止位置优先于装饰。
- 系统动态字号、清晰对比和足够大的触控区域。
- 无登录、同步和远程处理流程。

**The Quiet Utility Rule.** 用户应能在第一眼找到波形、起止时间和导出操作；不需要先读宣传文案。

## 2. Colors

使用系统中性色作为画布与内容表面，微信风格的森林绿作为唯一强调色。浅色主题的按钮文字为白色；深色主题使用更亮的绿色和深色按钮文字，保持清晰对比。

### Primary
- **森林绿** (`colors.primary` / `colors.primary-dark`)：用于主按钮、波形、范围边界和当前状态；不要拿它装饰非交互内容。浅色按钮 `#167A4B` 配白字的对比度为 5.36:1，暗色按钮 `#63CC90` 配深色字为 7.97:1。

### Neutral
- **系统画布** (`colors.canvas-light` / `colors.canvas-dark`)：页面最底层背景，随系统外观切换。
- **内容表面** (`colors.surface-light` / `colors.surface-dark`)：只用于波形面板和起止时间组。
- **次级表面** (`colors.surface-secondary-light` / `colors.surface-secondary-dark`)：波形轨道、输入框和进度轨道。
- **主文字** (`colors.ink-light` / `colors.ink-dark`)：标题、文件名和时间值。
- **次级文字** (`colors.secondary-ink-light` / `colors.secondary-ink-dark`)：格式、说明和隐私提示；文字对比保持易读。
- **分隔线** (`colors.separator-light` / `colors.separator-dark`)：仅用于分组边界和底部操作栏。

**The One Accent Rule.** 森林绿仅表示主要操作、选区或播放进度；静止内容使用中性色。

## 3. Typography

- **Display Font:** 系统字体（iOS 使用 SF Pro，Android 使用 Roboto）
- **Body Font:** 同一套系统字体
- **Label/Mono Font:** 不单独引入字体；时间数字使用系统字体。

**Character:** 清楚、亲近、适合快速扫读。保留平台字形和系统动态字号，不把字号缩小来迁就固定布局。

### Hierarchy
- **Display** (700, 28sp, 1.15)：空状态的短标题。
- **Title** (600, 21sp, 1.2)：正在剪辑的文件名和主要分区标题。
- **Body** (400, 16sp, 1.45)：操作说明和正文。
- **Label** (500, 13sp, 1.3)：格式、时间字段名称和辅助信息。

**The System Type Rule.** 文本必须遵循系统缩放；大字号下起止时间改为纵向排列，按钮不使用固定高度裁切文字。

## 4. Elevation

默认不使用投影。层次由系统背景、内容表面和细分隔线建立；仅底部导出操作使用 14dp 背景模糊、半透明色面和 22dp 圆角悬浮胶囊模拟磨砂玻璃。不要给静态卡片添加悬浮阴影或扩大模糊区域。

**The Flat Surface Rule.** 只在需要区分内容区域时切换表面色，不堆叠容器或用阴影模拟深度。

**The Single Glass Rule.** 玻璃效果只用于固定在底部安全区内的圆角导出操作；保持按钮文字不透明、边缘清楚，并在没有背景内容时由半透明底色自然回退。

## 5. Components

### Buttons
- **Shape:** 轻微圆角，主按钮为 `rounded.button`。
- **Primary:** 浅色主题使用森林绿底白字，深色主题使用浅绿底深色字；最小高度 52dp，动态字号可以继续增高。
- **Secondary:** 文字与图标使用强调色，不加厚重底板。
- **Focus / Disabled:** 使用 Flutter 与系统可见的焦点、禁用状态，不隐藏可操作性。

### Cards / Containers
- **Corner Style:** 波形面板 18dp；时间分组 16dp。
- **Background:** 采用当前系统外观对应的内容表面色。
- **Shadow Strategy:** 无静态阴影。
- **Internal Padding:** 16dp；不要在卡片内再包一层卡片。
- **Glass Footer:** 在滚动内容上方使用一处裁切后的 `BackdropFilter`，模糊半径为 14dp、圆角 22dp；底色浅色 91% 不透明、深色 85% 不透明。不要将波形或整页内容模糊。

### Inputs / Fields
- 时间字段是可点按的整块触控目标，显示“开始/结束”和时间值。
- 编辑时使用 iOS 风格的系统对话框与数字输入；输入面使用次级表面，焦点使用强调色。
- 无效时间应保留在对话框中并给出简洁错误提示。

### Navigation
- 顶栏左侧显示产品名，右侧用锁图标和“仅本机”做轻量隐私提示。
- 导出操作固定在底部安全区域内，波形编辑内容在上方滚动。

### Waveform Selection
- 波形背景透明，颜色随系统强调色更新；非选区降低对比，起止边界和手柄保持清楚。
- 时间标签同时显示选区起止，用户可拖动手柄或点时间值精确输入。

## 6. Do's and Don'ts

### Do:
- **Do** 让波形、起止时间和试听成为编辑页的视觉中心。
- **Do** 使用动态字号、可读对比度和至少 44dp 的可操作触控目标。
- **Do** 让浅色与深色外观使用同一套中性层级和语义强调色。
- **Do** 将本机处理说明放在容易找到的位置，但保持简短。
- **Do** 只在底部导出栏使用轻量磨砂玻璃，保证其余编辑内容清晰稳定。

### Don't:
- **Don't** 复刻 PRODUCT.md 所述“near-black canvas paired with saturated mint-green oversized actions, stacked oversized rounded cards, and a slogan-like hero heading”。
- **Don't** 堆叠大卡片、装饰性大标题、渐变或与音频编辑无关的图形。
- **Don't** 把正文、时间或触控区域缩小来挤进固定高度。
- **Don't** 增加登录、自动同步、上传或远程分析入口。
- **Don't** 在整页、波形或多个重复容器上套用高开销模糊。
