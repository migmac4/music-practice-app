import Foundation
import SwiftData

@Model
final class Category {
    var id: String
    var name: String
    var exercises: [PracticeExercise]?
    
    init(id: String = UUID().uuidString, name: String) {
        self.id = id
        self.name = name
    }
} 