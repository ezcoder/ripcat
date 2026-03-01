import SwiftUI
import RipCatCore

struct ContentView: View {
    @Environment(TideViewModel.self) private var viewModel
    @State private var selection: SidebarItem? = .today

    enum SidebarItem: String, CaseIterable {
        case today = "Today"
        case search = "Search"
        case settings = "Settings"

        var icon: String {
            switch self {
            case .today: "water.waves"
            case .search: "magnifyingglass"
            case .settings: "gear"
            }
        }
    }

    var body: some View {
        NavigationSplitView {
            List(SidebarItem.allCases, id: \.self, selection: $selection) { item in
                Label(item.rawValue, systemImage: item.icon)
            }
            .navigationSplitViewColumnWidth(min: 160, ideal: 180)
        } detail: {
            switch selection {
            case .today:
                TodayDetailView()
            case .search:
                SearchView()
            case .settings:
                SettingsView()
            case nil:
                Text("Select an item from the sidebar.")
                    .foregroundStyle(.secondary)
            }
        }
    }
}
