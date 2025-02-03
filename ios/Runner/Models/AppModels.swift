import Foundation
import SwiftData

@Model
final class AppSettings {
    var isDarkMode: Bool
    
    init(isDarkMode: Bool = false) {
        self.isDarkMode = isDarkMode
    }
}

@Model
final class Instrument {
    var id: String
    var name: String
    var practices: [Practice]?
    
    init(id: String = UUID().uuidString, name: String) {
        self.id = id
        self.name = name
    }
}

@Model
final class Category {
    var id: String
    var name: String
    var exercises: [Exercise]?
    
    init(id: String = UUID().uuidString, name: String) {
        self.id = id
        self.name = name
    }
}

@Model
final class Exercise {
    var id: String
    var name: String
    var exerciseDescription: String
    var category: Category?
    var practices: [Practice]?
    
    init(id: String = UUID().uuidString, name: String, exerciseDescription: String) {
        self.id = id
        self.name = name
        self.exerciseDescription = exerciseDescription
    }
}

@Model
final class Practice {
    var id: String
    var startTime: Date
    var duration: TimeInterval
    var notes: String?
    var exercise: Exercise?
    var instrument: Instrument?
    
    init(id: String = UUID().uuidString, 
         startTime: Date = Date(),
         duration: TimeInterval = 0,
         notes: String? = nil) {
        self.id = id
        self.startTime = startTime
        self.duration = duration
        self.notes = notes
    }
} 