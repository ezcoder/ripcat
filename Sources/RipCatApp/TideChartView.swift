import SwiftUI

struct TideChartView: View {
    @Environment(TideViewModel.self) private var viewModel

    var body: some View {
        Group {
            if let cgImage = viewModel.chartImage {
                Image(decorative: cgImage, scale: 2.0)
                    .resizable()
                    .aspectRatio(2.0, contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
}
