//
//  isiOS26.swifte
//  FocusAssistant2
//
//  Created by Nana Sekyere on 27/09/2025.
//

import Foundation

var isiOS26: Bool {
    if #available(iOS 26.0, *) {
        return true
    }
    return false
}
