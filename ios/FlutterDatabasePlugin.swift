import Foundation
import Flutter

@objc class FlutterDatabasePlugin: NSObject {
    private let dbManager = DatabaseManager.shared
    
    @objc func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "com.musicpractice.app/database",
            binaryMessenger: registrar.messenger()
        )
        channel.setMethodCallHandler(handle)
    }
    
    private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        Task {
            do {
                switch call.method {
                // Exercise Methods
                case "createExercise":
                    if let args = call.arguments as? [String: Any] {
                        let exercise = Exercise.fromMap(args)
                        try await dbManager.createExercise(exercise)
                        result(exercise.id)
                    }
                    
                case "getExercise":
                    if let args = call.arguments as? [String: Any],
                       let id = args["id"] as? String {
                        let exercise = try await dbManager.getExercise(id: id)
                        result(exercise?.toMap())
                    }
                    
                case "getAllExercises":
                    let exercises = try await dbManager.getAllExercises()
                    result(exercises.map { $0.toMap() })
                    
                case "updateExercise":
                    if let args = call.arguments as? [String: Any],
                       let id = args["id"] as? String,
                       let exercise = try await dbManager.getExercise(id: id) {
                        let updatedExercise = Exercise.fromMap(args)
                        exercise.name = updatedExercise.name
                        exercise.exerciseDescription = updatedExercise.exerciseDescription
                        exercise.category = updatedExercise.category
                        exercise.plannedDuration = updatedExercise.plannedDuration
                        exercise.date = updatedExercise.date
                        try await dbManager.updateExercise(exercise)
                        result(true)
                    }
                    
                case "deleteExercise":
                    if let args = call.arguments as? [String: Any],
                       let id = args["id"] as? String,
                       let exercise = try await dbManager.getExercise(id: id) {
                        try await dbManager.deleteExercise(exercise)
                        result(true)
                    }
                    
                case "findExercisesByCategory":
                    if let args = call.arguments as? [String: Any],
                       let categoryString = args["category"] as? String,
                       let category = PracticeCategory(rawValue: categoryString) {
                        let exercises = try await dbManager.findExercisesByCategory(category)
                        result(exercises.map { $0.toMap() })
                    }
                    
                // Practice Session Methods
                case "createPracticeSession":
                    if let args = call.arguments as? [String: Any] {
                        let session = PracticeSession.fromMap(args)
                        if let exerciseId = args["exerciseId"] as? String,
                           let exercise = try await dbManager.getExercise(id: exerciseId) {
                            session.exercise = exercise
                        }
                        try await dbManager.createPracticeSession(session)
                        result(session.id)
                    }
                    
                case "getPracticeSession":
                    if let args = call.arguments as? [String: Any],
                       let id = args["id"] as? String {
                        let session = try await dbManager.getPracticeSession(id: id)
                        result(session?.toMap())
                    }
                    
                case "getAllPracticeSessions":
                    let sessions = try await dbManager.getAllPracticeSessions()
                    result(sessions.map { $0.toMap() })
                    
                case "updatePracticeSession":
                    if let args = call.arguments as? [String: Any],
                       let id = args["id"] as? String,
                       let session = try await dbManager.getPracticeSession(id: id) {
                        let updatedSession = PracticeSession.fromMap(args)
                        session.startTime = updatedSession.startTime
                        session.endTime = updatedSession.endTime
                        session.actualDuration = updatedSession.actualDuration
                        session.category = updatedSession.category
                        session.notes = updatedSession.notes
                        try await dbManager.updatePracticeSession(session)
                        result(true)
                    }
                    
                case "deletePracticeSession":
                    if let args = call.arguments as? [String: Any],
                       let id = args["id"] as? String,
                       let session = try await dbManager.getPracticeSession(id: id) {
                        try await dbManager.deletePracticeSession(session)
                        result(true)
                    }
                    
                case "findPracticeSessionsByDateRange":
                    if let args = call.arguments as? [String: Any],
                       let startMillis = args["startDate"] as? Double,
                       let endMillis = args["endDate"] as? Double {
                        let start = Date(timeIntervalSince1970: startMillis / 1000)
                        let end = Date(timeIntervalSince1970: endMillis / 1000)
                        let sessions = try await dbManager.findPracticeSessionsByDateRange(start: start, end: end)
                        result(sessions.map { $0.toMap() })
                    }
                    
                case "getTotalPracticeDuration":
                    if let args = call.arguments as? [String: Any],
                       let startMillis = args["startDate"] as? Double,
                       let endMillis = args["endDate"] as? Double {
                        let start = Date(timeIntervalSince1970: startMillis / 1000)
                        let end = Date(timeIntervalSince1970: endMillis / 1000)
                        let duration = try await dbManager.getTotalPracticeDuration(start: start, end: end)
                        result(duration)
                    }
                    
                case "getPracticeDurationByCategory":
                    if let args = call.arguments as? [String: Any],
                       let startMillis = args["startDate"] as? Double,
                       let endMillis = args["endDate"] as? Double {
                        let start = Date(timeIntervalSince1970: startMillis / 1000)
                        let end = Date(timeIntervalSince1970: endMillis / 1000)
                        let durationByCategory = try await dbManager.getDurationByCategory(start: start, end: end)
                        let mappedResult = durationByCategory.mapKeys { $0.rawValue }
                        result(mappedResult)
                    }
                    
                case "getConsecutivePracticeDays":
                    if let args = call.arguments as? [String: Any],
                       let endDateMillis = args["endDate"] as? Double {
                        let endDate = Date(timeIntervalSince1970: endDateMillis / 1000)
                        let days = try await dbManager.getConsecutivePracticeDays(endDate: endDate)
                        result(days)
                    }
                    
                default:
                    result(FlutterMethodNotImplemented)
                }
            } catch {
                result(FlutterError(code: "DATABASE_ERROR",
                                  message: error.localizedDescription,
                                  details: nil))
            }
        }
    }
}

extension Dictionary {
    func mapKeys<T>(_ transform: (Key) -> T) -> [T: Value] {
        return Dictionary<T, Value>(uniqueKeysWithValues: map { (transform($0.key), $0.value) })
    }
} 