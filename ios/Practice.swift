import Foundation
import SwiftData

@Model
final class PracticeSession {
    var id: String
    var startTime: Date
    var duration: TimeInterval
    var notes: String?
    var exercise: PracticeExercise?
    var instrument: PracticeInstrument?
    
    init(id: String = UUID().uuidString,
         startTime: Date = Date(),
         duration: TimeInterval,
         notes: String? = nil,
         exercise: PracticeExercise? = nil,
         instrument: PracticeInstrument? = nil) {
        self.id = id
        self.startTime = startTime
        self.duration = duration
        self.notes = notes
        self.exercise = exercise
        self.instrument = instrument
    }
} 