import SwiftUI
import RipCatCore

struct SearchView: View {
    @Environment(TideViewModel.self) private var viewModel
    @State private var searchText = ""
    @State private var hasSearched = false

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Searching...")
            } else if let error = viewModel.errorMessage, hasSearched {
                ContentUnavailableView(
                    "No Results",
                    systemImage: "magnifyingglass",
                    description: Text(error)
                )
            } else if let tideData = viewModel.tideData, hasSearched {
                searchResults(tideData)
            } else {
                ContentUnavailableView(
                    "Search for Tides",
                    systemImage: "water.waves",
                    description: Text("Enter a city name to find the nearest tide station.")
                )
            }
        }
        .navigationTitle("Search")
        .searchable(text: $searchText, prompt: "City name (e.g. Seattle, WA)")
        .onSubmit(of: .search) {
            Task { await search() }
        }
    }

    private func searchResults(_ tideData: TideData) -> some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(spacing: 4) {
                    Text(tideData.stationName)
                        .font(.title2.bold())

                    if let distance = viewModel.distanceMiles {
                        Text(String(format: "%.1f mi away • Station %@", distance, tideData.stationID))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                TideChartView()

                VStack(alignment: .leading, spacing: 8) {
                    Text("High & Low Tides")
                        .font(.headline)

                    ForEach(Array(tideData.hiloPoints.enumerated()), id: \.offset) { _, point in
                        HStack {
                            Image(systemName: point.type == .high
                                  ? "arrow.up.circle.fill"
                                  : "arrow.down.circle.fill")
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
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
            }
            .padding()
        }
    }

    private func search() async {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return }
        hasSearched = true
        await viewModel.fetchTides(for: query)
    }
}
