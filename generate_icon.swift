#!/usr/bin/env swift

import Foundation
import AppKit
import SwiftUI

// 주식 그래프 아이콘 생성
func generateStockIcon(size: CGSize) -> NSImage {
    let image = NSImage(size: size)
    image.lockFocus()

    let rect = CGRect(origin: .zero, size: size)

    // 블루 그라디언트 배경
    let gradient = NSGradient(
        colors: [
            NSColor(red: 0.2, green: 0.4, blue: 0.8, alpha: 1.0),
            NSColor(red: 0.1, green: 0.2, blue: 0.5, alpha: 1.0)
        ]
    )!
    gradient.draw(in: rect, angle: 135)

    // 그래프 라인 그리기
    let path = NSBezierPath()
    let margin = size.width * 0.15
    let graphWidth = size.width - (margin * 2)
    let graphHeight = size.height - (margin * 2)

    // 상승하는 그래프 라인
    let points: [(x: CGFloat, y: CGFloat)] = [
        (0.0, 0.7),
        (0.2, 0.6),
        (0.4, 0.4),
        (0.6, 0.3),
        (0.8, 0.15),
        (1.0, 0.1)
    ]

    path.move(to: CGPoint(
        x: margin + (points[0].x * graphWidth),
        y: margin + (points[0].y * graphHeight)
    ))

    for point in points.dropFirst() {
        path.line(to: CGPoint(
            x: margin + (point.x * graphWidth),
            y: margin + (point.y * graphHeight)
        ))
    }

    // 라인 스타일
    NSColor.white.setStroke()
    path.lineWidth = size.width * 0.08
    path.lineCapStyle = .round
    path.lineJoinStyle = .round
    path.stroke()

    // 점 그리기
    for point in points {
        let dotPath = NSBezierPath()
        let dotSize = size.width * 0.12
        let center = CGPoint(
            x: margin + (point.x * graphWidth),
            y: margin + (point.y * graphHeight)
        )
        dotPath.appendOval(in: CGRect(
            x: center.x - dotSize/2,
            y: center.y - dotSize/2,
            width: dotSize,
            height: dotSize
        ))
        NSColor.white.setFill()
        dotPath.fill()
    }

    image.unlockFocus()
    return image
}

// PNG로 저장
func saveImage(_ image: NSImage, to path: String) {
    guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
        print("Failed to create CGImage")
        return
    }

    let bitmapRep = NSBitmapImageRep(cgImage: cgImage)
    guard let pngData = bitmapRep.representation(using: .png, properties: [:]) else {
        print("Failed to create PNG data")
        return
    }

    do {
        try pngData.write(to: URL(fileURLWithPath: path))
        print("✓ Created: \(path)")
    } catch {
        print("✗ Failed to save: \(path) - \(error)")
    }
}

// 필요한 모든 크기의 아이콘 생성
let basePath = "/Users/leekisang/stock-folio/StockFolio/Resources/Assets.xcassets/AppIcon.appiconset"

let sizes: [(name: String, size: CGFloat, scale: Int)] = [
    ("iphone-20@2x", 20, 2),
    ("iphone-20@3x", 20, 3),
    ("iphone-29@2x", 29, 2),
    ("iphone-29@3x", 29, 3),
    ("iphone-40@2x", 40, 2),
    ("iphone-40@3x", 40, 3),
    ("iphone-60@2x", 60, 2),
    ("iphone-60@3x", 60, 3),
    ("ipad-20", 20, 1),
    ("ipad-20@2x", 20, 2),
    ("ipad-29", 29, 1),
    ("ipad-29@2x", 29, 2),
    ("ipad-40", 40, 1),
    ("ipad-40@2x", 40, 2),
    ("ipad-76", 76, 1),
    ("ipad-76@2x", 76, 2),
    ("ipad-83.5@2x", 83.5, 2),
    ("appstore", 1024, 1)
]

print("Generating app icons...")
for sizeInfo in sizes {
    let pixelSize = sizeInfo.size * CGFloat(sizeInfo.scale)
    let image = generateStockIcon(size: CGSize(width: pixelSize, height: pixelSize))
    let filename = "\(sizeInfo.name).png"
    saveImage(image, to: "\(basePath)/\(filename)")
}

print("\nDone! Generated \(sizes.count) icon files.")
