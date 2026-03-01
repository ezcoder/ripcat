import SwiftUI
import RipCatCore

struct SettingsView: View {
    @Environment(TideViewModel.self) private var viewModel

    var body: some View {
        @Bindable var vm = viewModel

        NavigationStack {
            Form {
                Section("Chart Theme") {
                    Picker("Theme", selection: $vm.selectedThemeName) {
                        ForEach(ChartTheme.allNames, id: \.self) { name in
                            Text(name.capitalized).tag(name)
                        }
                    }
                    .pickerStyle(.inline)
                    .onChange(of: vm.selectedThemeName) {
                        viewModel.renderChart()
                    }
                }

                Section("About") {
                    LabeledContent("App", value: "RipCat")
                    LabeledContent("Data Source", value: "NOAA CO-OPS")
                }
            }
            .navigationTitle("Settings")
        }
    }
}
