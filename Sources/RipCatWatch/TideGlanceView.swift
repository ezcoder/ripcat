import SwiftUI
import RipCatCore

struct TideGlanceView: View {
    @Environment(TideViewModel.self) private var viewModel

    var body: some View {
        if let next = viewModel.nextHiLo {
            VStack(spacing: 4) {
                Image(systemName: next.type == .high
                      ? "arrow.up.circle.fill"
                      : "arrow.down.circle.fill")
                    .font(.title3)
                    .foregroundStyle(next.type == .high ? .red : .green)

                Text(next.type == .high ? "High" : "Low")
                    .font(.headline)

                Text(String(format: "%.1f ft", next.height))
                    .font(.title3.monospacedDigit())

                Text(next.time, style: .time)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        } else if viewModel.isLoading {
            ProgressView()
        } else {
            Text("No Data")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
