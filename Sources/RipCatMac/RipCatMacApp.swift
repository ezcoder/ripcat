import SwiftUI

@main
struct RipCatMacApp: App {
    @State private var viewModel = TideViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(viewModel)
                .frame(minWidth: 700, minHeight: 500)
        }

        MenuBarExtra("RipCat", systemImage: "water.waves") {
            MenuBarExtraContent()
                .environment(viewModel)
        }
    }
}
