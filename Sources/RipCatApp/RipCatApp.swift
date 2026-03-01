import SwiftUI
import RipCatCore

@main
struct RipCatApp: App {
    @State private var viewModel = TideViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(viewModel)
        }
    }
}
