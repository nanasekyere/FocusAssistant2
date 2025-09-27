//
//  ContentView.swift
//  FocusAssistant2
//
//  Created by Nana Sekyere on 20/09/2025.
//

import SwiftUI
import SwiftData

struct TabBar: View {
    var body: some View {
        OTPKit("user_log_Status") {
            if #available(iOS 26.0, *) {
                TabView {
                    TodayView(viewModel: TodayViewModel())
                        .tabItem {
                            Label("Today", systemImage: "sun.max")
                        }
                    
                    TasksView(viewModel: TasksViewModel())
                        .tabItem {
                            Label("Tasks", systemImage: "checklist")
                        }
                    
                    SettingsView(viewModel: SettingsViewModel())
                        .tabItem {
                            Label("Settings", systemImage: "gearshape")
                        }
                }
            }
        }
    }
}

#Preview {
    TabBar()
}
