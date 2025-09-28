//
//  SettingsViewModel.swift
//  FocusAssistant2
//
//  Created by Nana Sekyere on 21/09/2025.
//
import SwiftUI

@Observable
final class SettingsViewModel {
    var notificationsEnabled: Bool = true
    var defaultFocusMinutes: Int = 25
    var sound: String = "Chime"

    let availableSounds = ["Chime", "Bell", "Woodblock"]
}
