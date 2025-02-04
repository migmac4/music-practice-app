import Flutter
import SwiftData

class DatabasePlugin: NSObject {
    private let messenger: FlutterBinaryMessenger
    private let methodChannel: FlutterMethodChannel
    private let databaseManager: DatabaseManager
    
    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        self.methodChannel = FlutterMethodChannel(name: "com.musicpractice.app/database",
                                                binaryMessenger: messenger)
        self.databaseManager = DatabaseManager.shared
        
        super.init()
        
        self.methodChannel.setMethodCallHandler { [weak self] (call, result) in
            guard let self = self else { return }
            
            switch call.method {
            case "createExercise":
                if let args = call.arguments as? [String: Any] {
                    self.databaseManager.createExercise(from: args) { id in
                        result(id)
                    }
                } else {
                    result(FlutterError(code: "INVALID_ARGUMENTS",
                                      message: "Invalid arguments for createExercise",
                                      details: nil))
                }
                
            case "getExercise":
                if let args = call.arguments as? [String: Any],
                   let id = args["id"] as? String {
                    self.databaseManager.getExercise(id: id) { exercise in
                        result(exercise?.toMap())
                    }
                } else {
                    result(FlutterError(code: "INVALID_ARGUMENTS",
                                      message: "Invalid arguments for getExercise",
                                      details: nil))
                }
                
            case "getAllExercises":
                self.databaseManager.getAllExercises { exercises in
                    result(exercises.map { $0.toMap() })
                }
                
            case "updateExercise":
                if let args = call.arguments as? [String: Any] {
                    self.databaseManager.updateExercise(from: args) { success in
                        result(success)
                    }
                } else {
                    result(FlutterError(code: "INVALID_ARGUMENTS",
                                      message: "Invalid arguments for updateExercise",
                                      details: nil))
                }
                
            case "deleteExercise":
                if let args = call.arguments as? [String: Any],
                   let id = args["id"] as? String {
                    self.databaseManager.deleteExercise(id: id) { success in
                        result(success)
                    }
                } else {
                    result(FlutterError(code: "INVALID_ARGUMENTS",
                                      message: "Invalid arguments for deleteExercise",
                                      details: nil))
                }
                
            case "createPracticeSession":
                if let args = call.arguments as? [String: Any] {
                    self.databaseManager.createPracticeSession(from: args) { id in
                        result(id)
                    }
                } else {
                    result(FlutterError(code: "INVALID_ARGUMENTS",
                                      message: "Invalid arguments for createPracticeSession",
                                      details: nil))
                }
                
            case "getPracticeSession":
                if let args = call.arguments as? [String: Any],
                   let id = args["id"] as? String {
                    self.databaseManager.getPracticeSession(id: id) { session in
                        result(session?.toMap())
                    }
                } else {
                    result(FlutterError(code: "INVALID_ARGUMENTS",
                                      message: "Invalid arguments for getPracticeSession",
                                      details: nil))
                }
                
            case "getAllPracticeSessions":
                self.databaseManager.getAllPracticeSessions { sessions in
                    result(sessions.map { $0.toMap() })
                }
                
            case "updatePracticeSession":
                if let args = call.arguments as? [String: Any] {
                    self.databaseManager.updatePracticeSession(from: args) { success in
                        result(success)
                    }
                } else {
                    result(FlutterError(code: "INVALID_ARGUMENTS",
                                      message: "Invalid arguments for updatePracticeSession",
                                      details: nil))
                }
                
            case "deletePracticeSession":
                if let args = call.arguments as? [String: Any],
                   let id = args["id"] as? String {
                    self.databaseManager.deletePracticeSession(id: id) { success in
                        result(success)
                    }
                } else {
                    result(FlutterError(code: "INVALID_ARGUMENTS",
                                      message: "Invalid arguments for deletePracticeSession",
                                      details: nil))
                }
                
            case "findPracticeSessionsByDateRange":
                if let args = call.arguments as? [String: Any],
                   let startDate = args["startDate"] as? Double,
                   let endDate = args["endDate"] as? Double {
                    let start = Date(timeIntervalSince1970: startDate / 1000)
                    let end = Date(timeIntervalSince1970: endDate / 1000)
                    self.databaseManager.findPracticeSessionsByDateRange(start: start, end: end) { sessions in
                        result(sessions.map { $0.toMap() })
                    }
                } else {
                    result(FlutterError(code: "INVALID_ARGUMENTS",
                                      message: "Invalid arguments for findPracticeSessionsByDateRange",
                                      details: nil))
                }
                
            case "getTotalPracticeDuration":
                if let args = call.arguments as? [String: Any],
                   let startDate = args["startDate"] as? Double,
                   let endDate = args["endDate"] as? Double {
                    let start = Date(timeIntervalSince1970: startDate / 1000)
                    let end = Date(timeIntervalSince1970: endDate / 1000)
                    self.databaseManager.getTotalPracticeDuration(start: start, end: end) { duration in
                        result(duration)
                    }
                } else {
                    result(FlutterError(code: "INVALID_ARGUMENTS",
                                      message: "Invalid arguments for getTotalPracticeDuration",
                                      details: nil))
                }
                
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }
} 