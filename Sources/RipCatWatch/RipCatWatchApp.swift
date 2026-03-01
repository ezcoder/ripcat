import SwiftUI

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
