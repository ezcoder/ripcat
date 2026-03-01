import CoreGraphics
import Foundation
import Observation
import RipCatCore

@Observable
@MainActor
final class TideViewModel {
    var tideData: TideData?
    var chartImage: CGImage?
    var stations: [NOAAStation] = []
    var selectedStation: NOAAStation?
    var distanceMiles: Double?
    var isLoading = false
    var errorMessage: String?
    var selectedThemeName: String = "light"
    var defaultCity: String = "San Francisco, CA"

    var selectedTheme: ChartTheme {
        ChartTheme.named(selectedThemeName) ?? .light
    }

    private static let noaaDateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm"
        df.locale = Locale(identifier: "en_US_POSIX")
        return df
    }()

    private static let apiDateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyyMMdd"
        df.locale = Locale(identifier: "en_US_POSIX")
        return df
    }()

    private static let displayDateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        df.locale = Locale(identifier: "en_US_POSIX")
        return df
    }()

    func loadStations() async {
        guard stations.isEmpty else { return }
        do {
            stations = try await NOAAClient.fetchStations()
        } catch {
            errorMessage = "Failed to load stations: \(error.localizedDescription)"
        }
    }

    func fetchTides(for city: String) async {
        isLoading = true
        errorMessage = nil
        tideData = nil
        chartImage = nil

        do {
            let (lat, lon) = try await GeocoderService.geocode(city: city)
            await fetchTides(latitude: lat, longitude: lon)
        } catch {
            errorMessage = "Geocoding failed: \(error.localizedDescription)"
            isLoading = false
        }
    }

    func fetchTides(latitude: Double, longitude: Double) async {
        isLoading = true
        errorMessage = nil
        tideData = nil
        chartImage = nil

        do {
            await loadStations()

            guard let result = StationFinder.findNearest(
                latitude: latitude, longitude: longitude, stations: stations
            ) else {
                errorMessage = "No tide stations found nearby."
                isLoading = false
                return
            }

            selectedStation = result.station
            distanceMiles = result.distanceMiles

            let today = Self.apiDateFormatter.string(from: Date())
            let displayDate = Self.displayDateFormatter.string(from: Date())

            async let predictionsResult = NOAAClient.fetchPredictions(
                stationID: result.station.id, date: today
            )
            async let hiloResult = NOAAClient.fetchHiLo(
                stationID: result.station.id, date: today
            )

            let predictions = try await predictionsResult
            let hilos = try await hiloResult

            let tidePoints = predictions.compactMap { p -> TideDataPoint? in
                guard let date = Self.noaaDateFormatter.date(from: p.t),
                      let height = Double(p.v) else { return nil }
                return TideDataPoint(time: date, height: height)
            }

            let hiloPoints = hilos.compactMap { p -> HiLoPoint? in
                guard let date = Self.noaaDateFormatter.date(from: p.t),
                      let height = Double(p.v),
                      let type = HiLoType(rawValue: p.type) else { return nil }
                return HiLoPoint(time: date, height: height, type: type)
            }

            let data = TideData(
                stationID: result.station.id,
                stationName: result.station.name,
                date: displayDate,
                predictions: tidePoints,
                hiloPoints: hiloPoints
            )

            tideData = data
            renderChart()
        } catch {
            errorMessage = "Failed to fetch tides: \(error.localizedDescription)"
        }

        isLoading = false
    }

    func renderChart() {
        guard let tideData else { return }
        do {
            chartImage = try TideChartRenderer.renderToImage(
                tideData: tideData,
                theme: selectedTheme,
                showCurrentTime: true
            )
        } catch {
            errorMessage = "Chart render failed: \(error.localizedDescription)"
        }
    }
}
