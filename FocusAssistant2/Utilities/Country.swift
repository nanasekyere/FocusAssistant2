//
//  Country.swift
//  FocusAssistant2
//
//  Created by Nana Sekyere on 27/09/2025.
//

import Foundation

struct Country: Identifiable, Codable, Hashable {
    var id: String = UUID().uuidString
    var name: String
    var dialCode: String?
    var code: String
    
    enum CodingKeys: CodingKey {
        case name, dialCode, code
    }
    
}
