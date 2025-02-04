import Foundation
import SwiftData

@Model
final class PracticeInstrument {
    var id: String
    var name: String
    var practices: [PracticeSession]?
    
    init(id: String = UUID().uuidString, name: String) {
        self.id = id
        self.name = name
    }
} 