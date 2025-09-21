import SwiftUI

struct SettingsView: View {
    @State var viewModel: SettingsViewModel

    var body: some View {
        NavigationStack {
            Form {
                Section("Focus") {
                    Stepper("Default length: \(viewModel.defaultFocusMinutes) min", value: $viewModel.defaultFocusMinutes, in: 5...120, step: 5)
                }

                Section("Notifications") {
                    Toggle("Enable notifications", isOn: $viewModel.notificationsEnabled)
                    Picker("Sound", selection: $viewModel.sound) {
                        ForEach(viewModel.availableSounds, id: \.self) { sound in
                            Text(sound).tag(sound)
                        }
                    }
                }

                Section(footer: Text("More settings coming soon.")) {
                    Link(destination: URL(string: "https://example.com/privacy")!) {
                        Label("Privacy Policy", systemImage: "hand.raised")
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView(viewModel: SettingsViewModel())
}
