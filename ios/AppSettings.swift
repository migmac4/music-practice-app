import Foundation
import SwiftData

@Model
final class AppSettings {
    var isDarkMode: Bool
    
    init(isDarkMode: Bool = false) {
        self.isDarkMode = isDarkMode
    }
} 