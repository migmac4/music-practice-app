import Foundation
import SwiftData

@Model
final class PracticeExercise {
    var id: String
    var name: String
    var exerciseDescription: String
    var category: PracticeCategory?
    var practices: [PracticeSession]?
    
    init(id: String = UUID().uuidString,
         name: String,
         exerciseDescription: String,
         category: PracticeCategory? = nil) {
        self.id = id
        self.name = name
        self.exerciseDescription = exerciseDescription
        self.category = category
    }
}

extension PracticeExercise {
    func toMap() -> [String: Any] {
        return [
            "id": id,
            "name": name,
            "exerciseDescription": exerciseDescription,
            "category": category?.id ?? "",
        ]
    }
    
    static func fromMap(_ map: [String: Any]) -> PracticeExercise {
        return PracticeExercise(
            id: map["id"] as? String ?? UUID().uuidString,
            name: map["name"] as? String ?? "",
            exerciseDescription: map["exerciseDescription"] as? String ?? ""
        )
    }
    
    func update(from map: [String: Any]) {
        if let name = map["name"] as? String {
            self.name = name
        }
        if let description = map["exerciseDescription"] as? String {
            self.exerciseDescription = description
        }
    }
}