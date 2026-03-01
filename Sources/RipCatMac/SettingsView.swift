import SwiftUI
import RipCatCore

struct SettingsView: View {
    @Environment(TideViewModel.self) private var viewModel

    var body: some View {
        @Bindable var vm = viewModel

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

            Section("Default Location") {
                TextField("City", text: $vm.defaultCity)
                    .onSubmit {
                        Task { await viewModel.fetchTides(for: vm.defaultCity) }
                    }

                Text("Press Return to load tides for this location.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section("About") {
                LabeledContent("App", value: "RipCat")
                LabeledContent("Data Source", value: "NOAA CO-OPS")
            }
        }
        .formStyle(.grouped)
        .navigationTitle("Settings")
    }
}
