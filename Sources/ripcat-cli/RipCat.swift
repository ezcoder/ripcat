//
//  RipCat.swift
//  ripcat-cli
//

import ArgumentParser
import Foundation
import RipCatCore

@main
struct RipCat: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "ripcat",
        abstract: "Generate tide predictions and charts for US coastal locations.",
        version: "1.0.0"
    )

    @Option(name: .long, help: "City name to geocode (e.g., 'San Francisco, CA')")
    var city: String?

    @Option(name: .long, help: "Latitude for GPS coordinates")
    var lat: Double?

    @Option(name: .long, help: "Longitude for GPS coordinates")
    var lon: Double?

    @Option(name: .shortAndLong, help: "Date for tide predictions (YYYY-MM-DD). Defaults to today.")
    var date: String?

    @Option(name: .long, help: "Output format: json or text (default: json)")
    var format: FormatOption = .json

    @Option(name: .long, help: "File path for tide chart PNG image. If omitted, no chart is generated.")
    var chart: String?

    @Option(name: .long, help: "Chart image width in pixels (default: 1200)")
    var chartWidth: Int = 1200

    @Option(name: .long, help: "Chart image height in pixels (default: 600)")
    var chartHeight: Int = 600

    @Flag(name: .long, help: "Show a red dot on the chart at the current tide level.")
    var current: Bool = false

    @Option(name: .long, help: "Chart color theme: light, dark, coastal, nautical (default: light)")
    var theme: ThemeChoice = .light

    enum FormatOption: String, ExpressibleByArgument, CaseIterable {
        case json
        case text

        var outputFormat: OutputFormat {
            switch self {
            case .json: return .json
            case .text: return .text
            }
        }
    }

    enum ThemeChoice: String, ExpressibleByArgument, CaseIterable {
        case light, dark, coastal, nautical

        var chartTheme: ChartTheme {
            switch self {
            case .light: return .light
            case .dark: return .dark
            case .coastal: return .coastal
            case .nautical: return .nautical
            }
        }
    }

    func validate() throws {
        if city == nil && (lat == nil || lon == nil) {
            throw ValidationError("Provide either --city or both --lat and --lon.")
        }
        if city != nil && (lat != nil || lon != nil) {
            throw ValidationError("Provide either --city or --lat/--lon, not both.")
        }
        if (lat != nil) != (lon != nil) {
            throw ValidationError("Both --lat and --lon must be provided together.")
        }
    }

    private func resolvedDateString() throws -> String {
        if let dateStr = date {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            guard formatter.date(from: dateStr) != nil else {
                throw ValidationError("Invalid date format '\(dateStr)'. Use YYYY-MM-DD.")
            }
            return dateStr.replacingOccurrences(of: "-", with: "")
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMdd"
            return formatter.string(from: Date())
        }
    }

    private func displayDate() throws -> String {
        if let dateStr = date {
            return dateStr
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            return formatter.string(from: Date())
        }
    }

    mutating func run() async throws {
        // 1. Resolve coordinates
        let coordinates: (latitude: Double, longitude: Double)
        if let city = city {
            fputs("Geocoding '\(city)'...\n", stderr)
            coordinates = try await GeocoderService.geocode(city: city)
        } else {
            coordinates = (lat!, lon!)
        }

        // 2. Find nearest station
        fputs("Finding nearest tide station...\n", stderr)
        let stations = try await NOAAClient.fetchStations()
        guard let (station, distance) = StationFinder.findNearest(
            latitude: coordinates.latitude,
            longitude: coordinates.longitude,
            stations: stations
        ) else {
            throw CleanExit.message("Error: No NOAA tide stations found.")
        }
        fputs("Using station: \(station.name) (\(station.id)), \(String(format: "%.1f", distance)) miles away\n", stderr)

        // 3. Parse date
        let noaaDate = try resolvedDateString()
        let prettyDate = try displayDate()

        // 4. Fetch predictions and hi/lo concurrently
        fputs("Fetching tide data...\n", stderr)
        async let predictionsTask = NOAAClient.fetchPredictions(stationID: station.id, date: noaaDate)
        async let hiloTask = NOAAClient.fetchHiLo(stationID: station.id, date: noaaDate)
        let (rawPredictions, rawHiLo) = try await (predictionsTask, hiloTask)

        // 5. Parse into internal models
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"

        let predictions: [TideDataPoint] = rawPredictions.compactMap { p in
            guard let time = dateFormatter.date(from: p.t),
                  let height = Double(p.v) else { return nil }
            return TideDataPoint(time: time, height: height)
        }

        let hiloPoints: [HiLoPoint] = rawHiLo.compactMap { p in
            guard let time = dateFormatter.date(from: p.t),
                  let height = Double(p.v),
                  let type = HiLoType(rawValue: p.type) else { return nil }
            return HiLoPoint(time: time, height: height, type: type)
        }

        let tideData = TideData(
            stationID: station.id,
            stationName: station.name,
            date: prettyDate,
            predictions: predictions,
            hiloPoints: hiloPoints
        )

        // 6. Output formatted data
        let output = try OutputFormatter.format(tideData: tideData, as: format.outputFormat)
        print(output)

        // 7. Optionally render chart
        if let chartPath = chart {
            fputs("Generating tide chart...\n", stderr)
            try TideChartRenderer.render(
                tideData: tideData,
                config: .init(width: chartWidth, height: chartHeight),
                theme: theme.chartTheme,
                showCurrentTime: current,
                outputPath: chartPath
            )
            fputs("Chart saved to \(chartPath)\n", stderr)
        }
    }
}
