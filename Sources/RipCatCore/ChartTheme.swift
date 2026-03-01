//
//  ChartTheme.swift
//  tidegen
//
//  Created by Ben on 2/24/26.
//

import CoreGraphics

public struct ChartTheme {
    public let name: String
    public let background: RGBA
    public let curve: RGBA
    public let curveFill: RGBA
    public let grid: RGBA
    public let axis: RGBA
    public let high: RGBA
    public let low: RGBA
    public let text: RGBA
    public let title: RGBA
    public let markerBorder: RGBA
    public let currentDot: RGBA
    public let currentGlow: RGBA

    public struct RGBA {
        public let r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat
        public init(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ a: CGFloat = 1.0) {
            self.r = r; self.g = g; self.b = b; self.a = a
        }
    }
}

// MARK: - Built-in Themes

extension ChartTheme {

    /// macOS-style light theme — clean white background, system blue curve
    public static let light = ChartTheme(
        name: "light",
        background:   RGBA(0.98, 0.98, 1.0),
        curve:        RGBA(0.10, 0.35, 0.70),
        curveFill:    RGBA(0.10, 0.35, 0.70, 0.12),
        grid:         RGBA(0.82, 0.82, 0.85),
        axis:         RGBA(0.30, 0.30, 0.30),
        high:         RGBA(0.85, 0.15, 0.15),
        low:          RGBA(0.10, 0.55, 0.20),
        text:         RGBA(0.25, 0.25, 0.25),
        title:        RGBA(0.30, 0.30, 0.30),
        markerBorder: RGBA(1.00, 1.00, 1.00),
        currentDot:   RGBA(0.90, 0.00, 0.00),
        currentGlow:  RGBA(0.90, 0.00, 0.00, 0.25)
    )

    /// macOS-style dark theme — dark gray background, bright blue curve
    public static let dark = ChartTheme(
        name: "dark",
        background:   RGBA(0.11, 0.11, 0.12),
        curve:        RGBA(0.25, 0.55, 1.00),
        curveFill:    RGBA(0.25, 0.55, 1.00, 0.15),
        grid:         RGBA(0.25, 0.25, 0.27),
        axis:         RGBA(0.55, 0.55, 0.58),
        high:         RGBA(1.00, 0.35, 0.35),
        low:          RGBA(0.30, 0.85, 0.45),
        text:         RGBA(0.72, 0.72, 0.75),
        title:        RGBA(0.88, 0.88, 0.90),
        markerBorder: RGBA(0.11, 0.11, 0.12),
        currentDot:   RGBA(1.00, 0.28, 0.28),
        currentGlow:  RGBA(1.00, 0.28, 0.28, 0.30)
    )

    /// Warm coastal palette — sandy background, teal water, coral accents
    public static let coastal = ChartTheme(
        name: "coastal",
        background:   RGBA(0.98, 0.96, 0.92),
        curve:        RGBA(0.00, 0.55, 0.55),
        curveFill:    RGBA(0.00, 0.55, 0.55, 0.12),
        grid:         RGBA(0.87, 0.84, 0.78),
        axis:         RGBA(0.40, 0.35, 0.30),
        high:         RGBA(0.90, 0.35, 0.25),
        low:          RGBA(0.20, 0.60, 0.50),
        text:         RGBA(0.40, 0.37, 0.32),
        title:        RGBA(0.30, 0.25, 0.20),
        markerBorder: RGBA(0.98, 0.96, 0.92),
        currentDot:   RGBA(0.90, 0.35, 0.25),
        currentGlow:  RGBA(0.90, 0.35, 0.25, 0.25)
    )

    /// Deep nautical palette — dark navy background, gold accents
    public static let nautical = ChartTheme(
        name: "nautical",
        background:   RGBA(0.08, 0.10, 0.18),
        curve:        RGBA(0.40, 0.75, 0.90),
        curveFill:    RGBA(0.40, 0.75, 0.90, 0.12),
        grid:         RGBA(0.18, 0.20, 0.28),
        axis:         RGBA(0.45, 0.50, 0.58),
        high:         RGBA(0.95, 0.75, 0.25),
        low:          RGBA(0.40, 0.80, 0.70),
        text:         RGBA(0.60, 0.65, 0.72),
        title:        RGBA(0.90, 0.85, 0.70),
        markerBorder: RGBA(0.08, 0.10, 0.18),
        currentDot:   RGBA(0.95, 0.75, 0.25),
        currentGlow:  RGBA(0.95, 0.75, 0.25, 0.30)
    )

    public static func named(_ name: String) -> ChartTheme? {
        switch name {
        case "light": return .light
        case "dark": return .dark
        case "coastal": return .coastal
        case "nautical": return .nautical
        default: return nil
        }
    }

    public static let allNames = ["light", "dark", "coastal", "nautical"]
}
