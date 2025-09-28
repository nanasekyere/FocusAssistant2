import SwiftUI

struct TodayView: View {
    @State var viewModel: TodayViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                switch viewModel.state {
                case .idle:
                    ContentUnavailableView("No session", systemImage: "timer", description: Text("Start a focus session"))
                case .running(let startDate):
                    VStack(spacing: 8) {
                        Text("Focusing…")
                            .font(.title2).bold()
                        Text(startDate, style: .time)
                            .foregroundStyle(.secondary)
                    }
                }

                Stepper("Length: \(viewModel.focusMinutes) min", value: $viewModel.focusMinutes, in: 5...120, step: 5)
                    .disabled({ if case .running = viewModel.state { return true } else { return false } }())

                Button(action: {
                    switch viewModel.state {
                    case .idle: viewModel.start()
                    case .running: viewModel.stop()
                    }
                }) {
                    Text({ if case .idle = viewModel.state { return "Start" } else { return "Stop" } }())
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .navigationTitle("Today")
        }
    }
}

#Preview {
    TodayView(viewModel: TodayViewModel())
}
