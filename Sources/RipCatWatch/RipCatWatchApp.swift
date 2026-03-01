import SwiftUI
import RipCatCore

@main
struct RipCatWatchApp: App {
    @State private var viewModel = TideViewModel()

    var body: some Scene {
        WindowGroup {
            TodayView()
                .environment(viewModel)
        }
    }
}
