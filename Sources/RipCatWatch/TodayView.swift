import CoreLocation
import SwiftUI
import RipCatCore

struct TodayView: View {
    @Environment(TideViewModel.self) private var viewModel
    @State private var locationManager = LocationManager()

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading...")
                } else if let error = viewModel.errorMessage {
                    VStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.title3)
                        Text(error)
                            .font(.caption2)
                            .multilineTextAlignment(.center)
                    }
                } else if let tideData = viewModel.tideData {
                    tideContent(tideData)
                } else {
                    VStack(spacing: 8) {
                        Image(systemName: "water.waves")
                            .font(.title3)
                        Text("Tap to load tides")
                            .font(.caption2)
                    }
                }
            }
            .navigationTitle("RipCat")
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
        List {
            Section {
                VStack(spacing: 2) {
                    Text(tideData.stationName)
                        .font(.headline)

                    if let distance = viewModel.distanceMiles {
                        Text(String(format: "%.1f mi away", distance))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(maxWidth: .infinity)
                .listRowBackground(Color.clear)
            }

            Section("High & Low Tides") {
                ForEach(Array(tideData.hiloPoints.enumerated()), id: \.offset) { _, point in
                    HStack {
                        Image(systemName: point.type == .high
                              ? "arrow.up.circle.fill"
                              : "arrow.down.circle.fill")
                            .foregroundStyle(point.type == .high ? .red : .green)
                            .font(.body)

                        Text(point.type == .high ? "High" : "Low")
                            .font(.caption)

                        Spacer()

                        VStack(alignment: .trailing, spacing: 2) {
                            Text(String(format: "%.1f ft", point.height))
                                .font(.caption.monospacedDigit())
                            Text(point.time, style: .time)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            if let next = viewModel.nextHiLo {
                Section("Next") {
                    TideGlanceView()
                        .frame(maxWidth: .infinity)
                }
            }
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
