//
//  TodayViewModel.swift
//  FocusAssistant2
//
//  Created by Nana Sekyere on 21/09/2025.
//
import SwiftUI

@Observable
final class TodayViewModel {
    enum SessionState { case idle, running(Date) }

    var state: SessionState = .idle
    var focusMinutes: Int = 25

    func start() {
        guard case .idle = state else { return }
        state = .running(Date())
    }

    func stop() {
        state = .idle
    }
}
