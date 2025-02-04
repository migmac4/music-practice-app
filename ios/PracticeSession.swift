import Foundation
import SwiftData

@Model
final class PracticeSession: MappableObject {
    var id: String
    var startTime: Date
    var duration: Int
    var notes: String?
    var exerciseId: String?
    var exercise: Exercise?
    
    init(id: String = UUID().uuidString,
         startTime: Date = Date(),
         duration: Int,
         notes: String? = nil,
         exerciseId: String? = nil,
         exercise: Exercise? = nil) {
        self.id = id
        self.startTime = startTime
        self.duration = duration
        self.notes = notes
        self.exerciseId = exerciseId
        self.exercise = exercise
        super.init()
    }
    
    var endTime: Date {
        return startTime.addingTimeInterval(TimeInterval(duration * 60))
    }
    
    var actualDuration: Int {
        return duration
    }
    
    override func toMap() -> [String: Any] {
        var map: [String: Any] = [
            "id": id,
            "startTime": Int(startTime.timeIntervalSince1970 * 1000),
            "duration": duration
        ]
        
        if let notes = notes {
            map["notes"] = notes
        }
        
        if let exerciseId = exerciseId {
            map["exerciseId"] = exerciseId
        }
        
        if let exercise = exercise {
            map["exercise"] = exercise.toMap()
        }
        
        return map
    }
    
    static func fromMap(_ map: [String: Any]) -> PracticeSession {
        let startTimeDouble = map["startTime"] as? Double ?? 0
        let startTime = Date(timeIntervalSince1970: startTimeDouble / 1000)
        
        return PracticeSession(
            id: map["id"] as? String ?? UUID().uuidString,
            startTime: startTime,
            duration: map["duration"] as? Int ?? 0,
            notes: map["notes"] as? String,
            exerciseId: map["exerciseId"] as? String
        )
    }
    
    func update(from map: [String: Any]) {
        if let startTimeDouble = map["startTime"] as? Double {
            self.startTime = Date(timeIntervalSince1970: startTimeDouble / 1000)
        }
        if let duration = map["duration"] as? Int {
            self.duration = duration
        }
        if let notes = map["notes"] as? String {
            self.notes = notes
        }
        if let exerciseId = map["exerciseId"] as? String {
            self.exerciseId = exerciseId
        }
    }
} 