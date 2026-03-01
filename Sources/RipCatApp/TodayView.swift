import CoreLocation
import SwiftUI

struct TodayView: View {
    @Environment(TideViewModel.self) private var viewModel
    @State private var locationManager = LocationManager()

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading tides...")
                } else if let error = viewModel.errorMessage {
                    ContentUnavailableView(
                        "Error",
                        systemImage: "exclamationmark.triangle",
                        description: Text(error)
                    )
                } else if let tideData = viewModel.tideData {
                    tideContent(tideData)
                } else {
                    ContentUnavailableView(
                        "No Data",
                        systemImage: "water.waves",
                        description: Text("Tap refresh to load tides for your location.")
                    )
                }
            }
            .navigationTitle("Today's Tides")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task { await loadNearestStation() }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .task {
                await loadNearestStation()
            }
        }
    }

    private func tideContent(_ tideData: TideData) -> some View {
        ScrollView {
            VStack(spacing: 16) {
                stationHeader(tideData)
                hiloSection(tideData)
                TideChartView()
            }
            .padding()
        }
    }

    private func stationHeader(_ tideData: TideData) -> some View {
        VStack(spacing: 4) {
            Text(tideData.stationName)
                .font(.title2.bold())

            if let distance = viewModel.distanceMiles {
                Text(String(format: "%.1f mi away • Station %@", distance, tideData.stationID))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text(tideData.date)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private func hiloSection(_ tideData: TideData) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("High & Low Tides")
                .font(.headline)

            ForEach(Array(tideData.hiloPoints.enumerated()), id: \.offset) { _, point in
                hiloRow(point)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    private func hiloRow(_ point: HiLoPoint) -> some View {
        HStack {
            Image(systemName: point.type == .high ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                .foregroundStyle(point.type == .high ? .red : .green)

            Text(point.type == .high ? "High" : "Low")
                .fontWeight(.medium)

            Spacer()

            Text(String(format: "%.2f ft", point.height))
                .monospacedDigit()

            Text(point.time, style: .time)
                .foregroundStyle(.secondary)
        }
    }

    private func loadNearestStation() async {
        if let location = locationManager.lastLocation {
            await viewModel.fetchTides(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude
            )
        } else {
            locationManager.requestLocation()
            // Default to San Francisco while waiting for location
            await viewModel.fetchTides(for: "San Francisco, CA")
        }
    }
}

// MARK: - Location Manager

@Observable
final class LocationManager: NSObject, CLLocationManagerDelegate {
    var lastLocation: CLLocation?
    private let manager = CLLocationManager()

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
    }

    func requestLocation() {
        manager.requestWhenInUseAuthorization()
        manager.requestLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastLocation = locations.last
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Location errors are non-fatal; we fall back to a default city
    }
}
