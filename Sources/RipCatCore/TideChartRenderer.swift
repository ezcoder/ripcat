//
//  TideChartRenderer.swift
//  tidegen
//
//  Created by Ben on 2/24/26.
//

import CoreGraphics
import CoreText
import Foundation
import ImageIO
import UniformTypeIdentifiers

public enum ChartError: LocalizedError {
    case contextCreationFailed
    case imageCreationFailed
    case fileCreationFailed(String)
    case writeFailed(String)
    case noData

    public var errorDescription: String? {
        switch self {
        case .contextCreationFailed: return "Failed to create graphics context"
        case .imageCreationFailed: return "Failed to create image from context"
        case .fileCreationFailed(let p): return "Failed to create file at \(p)"
        case .writeFailed(let p): return "Failed to write PNG to \(p)"
        case .noData: return "No prediction data to chart"
        }
    }
}

public struct TideChartRenderer {
    public struct Configuration {
        public var width: Int = 1200
        public var height: Int = 600

        public init(width: Int = 1200, height: Int = 600) {
            self.width = width
            self.height = height
        }
    }

    public static func render(
        tideData: TideData,
        config: Configuration = Configuration(),
        theme: ChartTheme = .light,
        showCurrentTime: Bool = false,
        outputPath: String
    ) throws {
        guard !tideData.predictions.isEmpty else {
            throw ChartError.noData
        }

        let width = config.width
        let height = config.height

        // Margins
        let marginTop: CGFloat = 55
        let marginBottom: CGFloat = 60
        let marginLeft: CGFloat = 65
        let marginRight: CGFloat = 30

        let plotW = CGFloat(width) - marginLeft - marginRight
        let plotH = CGFloat(height) - marginTop - marginBottom

        // Create color space (needed for both colors and context)
        let colorSpace = CGColorSpaceCreateDeviceRGB()

        func rgb(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ a: CGFloat = 1.0) -> CGColor {
            CGColor(colorSpace: colorSpace, components: [r, g, b, a])!
        }
        func c(_ rgba: ChartTheme.RGBA) -> CGColor {
            rgb(rgba.r, rgba.g, rgba.b, rgba.a)
        }

        // Colors from theme
        let bgColor = c(theme.background)
        let lineColor = c(theme.curve)
        let fillColor = c(theme.curveFill)
        let gridColor = c(theme.grid)
        let axisColor = c(theme.axis)
        let highColor = c(theme.high)
        let lowColor = c(theme.low)
        let textColor = c(theme.text)
        let titleColor = c(theme.title)
        let markerBorderColor = c(theme.markerBorder)
        let currentDotColor = c(theme.currentDot)
        let currentGlowColor = c(theme.currentGlow)
        guard let ctx = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: 4 * width,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            throw ChartError.contextCreationFailed
        }

        // Background
        ctx.setFillColor(bgColor)
        ctx.fill(CGRect(x: 0, y: 0, width: width, height: height))

        // Compute data ranges
        let heights = tideData.predictions.map(\.height)
        let minHeight = heights.min()!
        let maxHeight = heights.max()!
        let heightPadding = (maxHeight - minHeight) * 0.15
        let yMin = floor(minHeight - heightPadding)
        let yMax = ceil(maxHeight + heightPadding)

        // Compute time range (minutes from start of day)
        let calendar = Calendar.current
        func minutesInDay(_ date: Date) -> Double {
            let comps = calendar.dateComponents([.hour, .minute], from: date)
            return Double(comps.hour! * 60 + comps.minute!)
        }

        let xMin: Double = 0
        let xMax: Double = 1440

        // Mapping functions
        func mapX(_ minutes: Double) -> CGFloat {
            return marginLeft + CGFloat((minutes - xMin) / (xMax - xMin)) * plotW
        }
        func mapY(_ h: Double) -> CGFloat {
            return marginBottom + CGFloat((h - yMin) / (yMax - yMin)) * plotH
        }

        // Draw grid lines
        ctx.setLineWidth(0.5)
        ctx.setStrokeColor(gridColor)

        // Horizontal grid (every 1 ft)
        var yTick = ceil(yMin)
        while yTick <= floor(yMax) {
            let py = mapY(yTick)
            ctx.move(to: CGPoint(x: marginLeft, y: py))
            ctx.addLine(to: CGPoint(x: marginLeft + plotW, y: py))
            ctx.strokePath()

            // Y-axis label
            let label = String(format: "%.0f ft", yTick)
            drawText(label, in: ctx, at: CGPoint(x: marginLeft - 8, y: py - 5),
                     fontSize: 11, color: textColor, alignment: .right)
            yTick += 1
        }

        // Vertical grid (every 3 hours)
        let hourLabels = ["12am", "3am", "6am", "9am", "12pm", "3pm", "6pm", "9pm"]
        for i in 0...8 {
            let minutes = Double(i * 180)
            let px = mapX(minutes)
            ctx.move(to: CGPoint(x: px, y: marginBottom))
            ctx.addLine(to: CGPoint(x: px, y: marginBottom + plotH))
            ctx.strokePath()

            if i < hourLabels.count {
                drawText(hourLabels[i], in: ctx,
                         at: CGPoint(x: px, y: marginBottom - 20),
                         fontSize: 11, color: textColor, alignment: .center)
            }
        }

        // Draw axes
        ctx.setLineWidth(1.0)
        ctx.setStrokeColor(axisColor)
        // X-axis
        ctx.move(to: CGPoint(x: marginLeft, y: marginBottom))
        ctx.addLine(to: CGPoint(x: marginLeft + plotW, y: marginBottom))
        // Y-axis
        ctx.move(to: CGPoint(x: marginLeft, y: marginBottom))
        ctx.addLine(to: CGPoint(x: marginLeft, y: marginBottom + plotH))
        ctx.strokePath()

        // Draw filled area under curve
        ctx.saveGState()
        ctx.beginPath()
        let firstPoint = tideData.predictions[0]
        let firstX = mapX(minutesInDay(firstPoint.time))
        let firstY = mapY(firstPoint.height)
        ctx.move(to: CGPoint(x: firstX, y: mapY(yMin)))
        ctx.addLine(to: CGPoint(x: firstX, y: firstY))

        for point in tideData.predictions.dropFirst() {
            let px = mapX(minutesInDay(point.time))
            let py = mapY(point.height)
            ctx.addLine(to: CGPoint(x: px, y: py))
        }

        let lastPoint = tideData.predictions.last!
        let lastX = mapX(minutesInDay(lastPoint.time))
        ctx.addLine(to: CGPoint(x: lastX, y: mapY(yMin)))
        ctx.closePath()
        ctx.setFillColor(fillColor)
        ctx.fillPath()
        ctx.restoreGState()

        // Draw tide curve line
        ctx.setLineWidth(2.5)
        ctx.setStrokeColor(lineColor)
        ctx.beginPath()
        ctx.move(to: CGPoint(x: firstX, y: firstY))

        for point in tideData.predictions.dropFirst() {
            let px = mapX(minutesInDay(point.time))
            let py = mapY(point.height)
            ctx.addLine(to: CGPoint(x: px, y: py))
        }
        ctx.strokePath()

        // Draw hi/lo markers
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a"

        for point in tideData.hiloPoints {
            let px = mapX(minutesInDay(point.time))
            let py = mapY(point.height)
            let color = point.type == .high ? highColor : lowColor
            let markerRadius: CGFloat = 5

            // Filled circle
            ctx.setFillColor(color)
            ctx.fillEllipse(in: CGRect(
                x: px - markerRadius, y: py - markerRadius,
                width: markerRadius * 2, height: markerRadius * 2
            ))

            // White border
            ctx.setStrokeColor(markerBorderColor)
            ctx.setLineWidth(1.5)
            ctx.strokeEllipse(in: CGRect(
                x: px - markerRadius, y: py - markerRadius,
                width: markerRadius * 2, height: markerRadius * 2
            ))

            // Label
            let typeStr = point.type == .high ? "H" : "L"
            let heightStr = String(format: "%.1f ft", point.height)
            let timeStr = timeFormatter.string(from: point.time)
            let label = "\(typeStr): \(heightStr)"
            let yOffset: CGFloat = point.type == .high ? 12 : -22

            drawText(label, in: ctx,
                     at: CGPoint(x: px, y: py + yOffset),
                     fontSize: 11, color: color, alignment: .center, bold: true)
            drawText(timeStr, in: ctx,
                     at: CGPoint(x: px, y: py + yOffset + (point.type == .high ? 14 : -14)),
                     fontSize: 9, color: textColor, alignment: .center)
        }

        // Draw title
        let title = "Tide Predictions: \(tideData.stationName) — \(tideData.date)"
        drawText(title, in: ctx,
                 at: CGPoint(x: CGFloat(width) / 2, y: CGFloat(height) - 30),
                 fontSize: 16, color: titleColor, alignment: .center, bold: true)

        // Y-axis label
        let yLabel = "Height (ft, MLLW)"
        drawText(yLabel, in: ctx,
                 at: CGPoint(x: 14, y: marginBottom + plotH / 2),
                 fontSize: 10, color: textColor, alignment: .center, rotated: true)

        // Draw current time marker
        if showCurrentTime {
            let now = Date()
            let nowMinutes = minutesInDay(now)
            // Find the closest prediction to the current time
            if let closest = tideData.predictions.min(by: {
                abs(minutesInDay($0.time) - nowMinutes) < abs(minutesInDay($1.time) - nowMinutes)
            }) {
                let cx = mapX(nowMinutes)
                let cy = mapY(closest.height)
                let dotRadius: CGFloat = 8

                // Outer glow
                ctx.setFillColor(currentGlowColor)
                ctx.fillEllipse(in: CGRect(
                    x: cx - dotRadius * 2, y: cy - dotRadius * 2,
                    width: dotRadius * 4, height: dotRadius * 4
                ))

                // Current dot
                ctx.setFillColor(currentDotColor)
                ctx.fillEllipse(in: CGRect(
                    x: cx - dotRadius, y: cy - dotRadius,
                    width: dotRadius * 2, height: dotRadius * 2
                ))

                // Border
                ctx.setStrokeColor(markerBorderColor)
                ctx.setLineWidth(2.0)
                ctx.strokeEllipse(in: CGRect(
                    x: cx - dotRadius, y: cy - dotRadius,
                    width: dotRadius * 2, height: dotRadius * 2
                ))

                // Label
                let nowFormatter = DateFormatter()
                nowFormatter.dateFormat = "h:mm a"
                let nowLabel = "Now: \(String(format: "%.1f", closest.height)) ft"
                drawText(nowLabel, in: ctx,
                         at: CGPoint(x: cx, y: cy + 16),
                         fontSize: 11, color: currentDotColor, alignment: .center, bold: true)
                drawText(nowFormatter.string(from: now), in: ctx,
                         at: CGPoint(x: cx, y: cy + 30),
                         fontSize: 9, color: textColor, alignment: .center)
            }
        }

        // Export PNG
        guard let image = ctx.makeImage() else {
            throw ChartError.imageCreationFailed
        }
        let url = URL(fileURLWithPath: outputPath) as CFURL
        guard let destination = CGImageDestinationCreateWithURL(
            url, UTType.png.identifier as CFString, 1, nil
        ) else {
            throw ChartError.fileCreationFailed(outputPath)
        }
        CGImageDestinationAddImage(destination, image, nil)
        guard CGImageDestinationFinalize(destination) else {
            throw ChartError.writeFailed(outputPath)
        }
    }

    // MARK: - Text Drawing

    private static func drawText(
        _ text: String,
        in context: CGContext,
        at point: CGPoint,
        fontSize: CGFloat,
        color: CGColor,
        alignment: TextAlignment,
        bold: Bool = false,
        rotated: Bool = false
    ) {
        let fontName = bold ? "Helvetica-Bold" : "Helvetica"
        let font = CTFontCreateWithName(fontName as CFString, fontSize, nil)
        let attributes: [CFString: Any] = [
            kCTFontAttributeName: font,
            kCTForegroundColorAttributeName: color,
        ]
        let attrString = CFAttributedStringCreate(nil, text as CFString, attributes as CFDictionary)!
        let line = CTLineCreateWithAttributedString(attrString)
        let bounds = CTLineGetBoundsWithOptions(line, [])

        context.saveGState()

        if rotated {
            context.translateBy(x: point.x, y: point.y)
            context.rotate(by: .pi / 2)
            let xOffset: CGFloat
            switch alignment {
            case .center: xOffset = -bounds.width / 2
            case .right: xOffset = -bounds.width
            case .left: xOffset = 0
            }
            context.textPosition = CGPoint(x: xOffset, y: -bounds.height / 2)
        } else {
            let xOffset: CGFloat
            switch alignment {
            case .center: xOffset = point.x - bounds.width / 2
            case .right: xOffset = point.x - bounds.width
            case .left: xOffset = point.x
            }
            context.textPosition = CGPoint(x: xOffset, y: point.y)
        }

        CTLineDraw(line, context)
        context.restoreGState()
    }

    private enum TextAlignment {
        case left, center, right
    }
}
