import SwiftUI
import RipCatCore

struct MenuBarExtraContent: View {
    @Environment(TideViewModel.self) private var viewModel

    var body: some View {
        VStack(spacing: 0) {
            if viewModel.isLoading {
                Text("Loading...")
                    .padding()
            } else if let tideData = viewModel.tideData {
                menuContent(tideData)
            } else {
                Text("No tide data")
                    .padding()
            }

            Divider()

            Button("Refresh") {
                Task { await viewModel.fetchTides(for: viewModel.defaultCity) }
            }
            .keyboardShortcut("r")

            Divider()

            Button("Quit RipCat") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q")
        }
        .task {
            if viewModel.tideData == nil {
                await viewModel.fetchTides(for: viewModel.defaultCity)
            }
        }
    }

    private func menuContent(_ tideData: TideData) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(tideData.stationName)
                .font(.headline)
                .padding(.horizontal)
                .padding(.top, 8)

            Divider()

            ForEach(Array(tideData.hiloPoints.enumerated()), id: \.offset) { _, point in
                HStack {
                    Image(systemName: point.type == .high
                          ? "arrow.up.circle.fill"
                          : "arrow.down.circle.fill")
                        .foregroundStyle(point.type == .high ? .red : .green)

                    Text(point.type == .high ? "High" : "Low")

                    Spacer()

                    Text(String(format: "%.1f ft", point.height))
                        .monospacedDigit()

                    Text(point.time, style: .time)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)
            }

            if let next = nextHiLo(tideData) {
                Divider()

                HStack {
                    Text("Next:")
                        .fontWeight(.medium)
                    Text(next.type == .high ? "High" : "Low")
                    Text(String(format: "%.1f ft", next.height))
                        .monospacedDigit()
                    Text("at")
                    Text(next.time, style: .time)
                }
                .font(.caption)
                .padding(.horizontal)
                .padding(.bottom, 8)
            }
        }
    }

    private func nextHiLo(_ tideData: TideData) -> HiLoPoint? {
        let now = Date()
        return tideData.hiloPoints.first { $0.time > now } ?? tideData.hiloPoints.last
    }
}
