//
//  OutputFormatter.swift
//  RipCatCore
//

import Foundation

public struct OutputFormatter {
    public static func format(tideData: TideData, as outputFormat: OutputFormat) throws -> String {
        switch outputFormat {
        case .json:
            return try formatJSON(tideData)
        case .text:
            return formatText(tideData)
        }
    }

    private static func formatJSON(_ data: TideData) throws -> String {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"

        let json = TideDataJSON(
            station: .init(id: data.stationID, name: data.stationName),
            date: data.date,
            predictions: data.predictions.map {
                .init(time: timeFormatter.string(from: $0.time), height: $0.height)
            },
            highLow: data.hiloPoints.map {
                .init(
                    time: timeFormatter.string(from: $0.time),
                    height: $0.height,
                    type: $0.type == .high ? "high" : "low"
                )
            }
        )
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let jsonData = try encoder.encode(json)
        return String(data: jsonData, encoding: .utf8) ?? "{}"
    }

    private static func formatText(_ data: TideData) -> String {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a"

        var lines: [String] = []
        lines.append("Tide Predictions for \(data.stationName) (Station \(data.stationID))")
        lines.append("Date: \(data.date)")
        lines.append("")
        lines.append("High/Low Tides:")
        lines.append("  Time        Type    Height (ft)")
        lines.append("  " + String(repeating: "-", count: 36))

        for point in data.hiloPoints {
            let typeStr = point.type == .high ? "High" : "Low"
            let timeStr = timeFormatter.string(from: point.time)
            let padTime = timeStr.padding(toLength: 10, withPad: " ", startingAt: 0)
            let padType = typeStr.padding(toLength: 6, withPad: " ", startingAt: 0)
            lines.append("  \(padTime)  \(padType)  \(String(format: "%.2f", point.height))")
        }

        lines.append("")
        lines.append("Total 6-minute predictions: \(data.predictions.count)")

        if let minPred = data.predictions.min(by: { $0.height < $1.height }),
           let maxPred = data.predictions.max(by: { $0.height < $1.height }) {
            lines.append(String(format: "Range: %.2f ft to %.2f ft", minPred.height, maxPred.height))
        }

        return lines.joined(separator: "\n")
    }
}
