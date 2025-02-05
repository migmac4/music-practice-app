import Foundation
import SwiftData

@Model
final class PracticeCategory {
    var id: String
    var name: String
    var instrument: PracticeInstrument?
    var exercises: [PracticeExercise]?
    
    init(id: String = UUID().uuidString, name: String, instrument: PracticeInstrument? = nil) {
        self.id = id
        self.name = name
        self.instrument = instrument
    }
} 