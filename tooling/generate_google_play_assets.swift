import AppKit
import CoreGraphics
import Foundation

private func color(_ hex: UInt32, alpha: CGFloat = 1) -> CGColor {
    CGColor(
        red: CGFloat((hex >> 16) & 0xff) / 255,
        green: CGFloat((hex >> 8) & 0xff) / 255,
        blue: CGFloat(hex & 0xff) / 255,
        alpha: alpha
    )
}

private func roundedRect(_ rect: CGRect, radius: CGFloat) -> CGPath {
    CGPath(roundedRect: rect, cornerWidth: radius, cornerHeight: radius, transform: nil)
}

private func drawBars(
    in context: CGContext,
    center: CGPoint,
    heights: [CGFloat],
    barWidth: CGFloat,
    gap: CGFloat,
    color barColor: CGColor,
    selectedRange: ClosedRange<Int>? = nil,
    selectedColor: CGColor? = nil
) {
    let totalWidth = CGFloat(heights.count) * barWidth + CGFloat(max(0, heights.count - 1)) * gap
    let firstX = center.x - totalWidth / 2

    for (index, height) in heights.enumerated() {
        let x = firstX + CGFloat(index) * (barWidth + gap)
        let rect = CGRect(x: x, y: center.y - height / 2, width: barWidth, height: height)
        let color = selectedRange?.contains(index) == true ? (selectedColor ?? barColor) : barColor
        context.setFillColor(color)
        context.addPath(roundedRect(rect, radius: barWidth / 2))
        context.fillPath()
    }
}

private func writePNG(
    width: Int,
    height: Int,
    to url: URL,
    drawing: (CGContext) -> Void
) throws {
    let bitmap = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: width,
        pixelsHigh: height,
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
    )!
    let graphics = NSGraphicsContext(bitmapImageRep: bitmap)!
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = graphics
    graphics.imageInterpolation = .high
    drawing(graphics.cgContext)
    graphics.flushGraphics()
    NSGraphicsContext.restoreGraphicsState()
    try bitmap.representation(using: .png, properties: [:])!.write(to: url)
}

private func writeJPEG(
    width: Int,
    height: Int,
    to url: URL,
    drawing: (CGContext) -> Void
) throws {
    let bitmap = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: width,
        pixelsHigh: height,
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
    )!
    let graphics = NSGraphicsContext(bitmapImageRep: bitmap)!
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = graphics
    graphics.imageInterpolation = .high
    drawing(graphics.cgContext)
    graphics.flushGraphics()
    NSGraphicsContext.restoreGraphicsState()
    try bitmap.representation(using: .jpeg, properties: [.compressionFactor: 0.94])!.write(to: url)
}

private func makeAppIcon(at url: URL) throws {
    let side: CGFloat = 1024
    let heights: [CGFloat] = [118, 176, 252, 184, 324, 424, 286, 210, 358, 448, 300, 226, 372, 420, 276, 172, 118]

    try writePNG(width: 1024, height: 1024, to: url) { context in
        context.setFillColor(color(0x16452F))
        context.fill(CGRect(x: 0, y: 0, width: side, height: side))

        context.setFillColor(color(0x2B8053, alpha: 0.7))
        context.addPath(roundedRect(CGRect(x: 370, y: 232, width: 284, height: 560), radius: 142))
        context.fillPath()

        drawBars(
            in: context,
            center: CGPoint(x: side / 2, y: side / 2),
            heights: heights,
            barWidth: 22,
            gap: 20,
            color: color(0xF4F7F4),
            selectedRange: 5...11,
            selectedColor: color(0xD4F0DC)
        )

        for x: CGFloat in [366, 658] {
            context.setFillColor(color(0xB9E8CA))
            context.addPath(roundedRect(CGRect(x: x, y: 224, width: 16, height: 576), radius: 8))
            context.fillPath()
            context.addPath(roundedRect(CGRect(x: x - 18, y: 220, width: 52, height: 24), radius: 12))
            context.fillPath()
            context.addPath(roundedRect(CGRect(x: x - 18, y: 780, width: 52, height: 24), radius: 12))
            context.fillPath()
        }
    }
}

private func makeFeatureGraphic(at url: URL) throws {
    try writeJPEG(width: 1024, height: 500, to: url) { context in
        context.setFillColor(color(0xF4F7F4))
        context.fill(CGRect(x: 0, y: 0, width: 1024, height: 500))

        context.setFillColor(color(0xDCEBDD, alpha: 0.55))
        context.fillEllipse(in: CGRect(x: 500, y: -170, width: 420, height: 420))

        let title = NSAttributedString(
            string: "本地音剪",
            attributes: [
                .font: NSFont.systemFont(ofSize: 65, weight: .bold),
                .foregroundColor: NSColor(cgColor: color(0x1C3427))!
            ]
        )
        title.draw(at: CGPoint(x: 76, y: 292))

        let subtitle = NSAttributedString(
            string: "在设备本机完成音频剪辑",
            attributes: [
                .font: NSFont.systemFont(ofSize: 29, weight: .regular),
                .foregroundColor: NSColor(cgColor: color(0x52675A))!
            ]
        )
        subtitle.draw(at: CGPoint(x: 82, y: 232))

        context.setFillColor(color(0xE5EEE6))
        context.addPath(roundedRect(CGRect(x: 78, y: 137, width: 296, height: 48), radius: 24))
        context.fillPath()
        let badge = NSAttributedString(
            string: "无需账号 · 音频留在本机",
            attributes: [
                .font: NSFont.systemFont(ofSize: 17, weight: .medium),
                .foregroundColor: NSColor(cgColor: color(0x315640))!
            ]
        )
        badge.draw(at: CGPoint(x: 100, y: 151))

        context.setFillColor(color(0x16452F))
        context.addPath(roundedRect(CGRect(x: 630, y: 50, width: 330, height: 400), radius: 38))
        context.fillPath()

        context.setFillColor(color(0x2B8053, alpha: 0.72))
        context.addPath(roundedRect(CGRect(x: 754, y: 126, width: 108, height: 248), radius: 54))
        context.fillPath()

        drawBars(
            in: context,
            center: CGPoint(x: 795, y: 250),
            heights: [50, 72, 98, 132, 174, 120, 86, 150, 188, 126, 84, 142, 176, 112, 76, 54],
            barWidth: 10,
            gap: 7,
            color: color(0xF4F7F4),
            selectedRange: 5...10,
            selectedColor: color(0xD4F0DC)
        )

        for x: CGFloat in [748, 852] {
            context.setFillColor(color(0xB9E8CA))
            context.addPath(roundedRect(CGRect(x: x, y: 112, width: 8, height: 276), radius: 4))
            context.fillPath()
            context.addPath(roundedRect(CGRect(x: x - 8, y: 108, width: 24, height: 13), radius: 6.5))
            context.fillPath()
            context.addPath(roundedRect(CGRect(x: x - 8, y: 379, width: 24, height: 13), radius: 6.5))
            context.fillPath()
        }
    }
}

let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let assets = root.appendingPathComponent("docs/google-play/assets", isDirectory: true)
try FileManager.default.createDirectory(at: assets, withIntermediateDirectories: true)
try makeAppIcon(at: assets.appendingPathComponent("app-icon-1024.png"))
try makeFeatureGraphic(at: assets.appendingPathComponent("feature-graphic-1024x500.jpg"))
print("Generated Google Play icon and feature graphic in docs/google-play/assets")
