import Flutter
import Foundation

public class DatabasePlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "com.miguelmacedo.music_practice_app/data_manager",
                                         binaryMessenger: registrar.messenger())
        let instance = DatabasePlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        Task {
            do {
                switch call.method {
                case "saveInstrument":
                    if let args = call.arguments as? [String: Any],
                       let name = args["name"] as? String {
                        let instrument = try await DatabaseManager.shared.saveInstrument(name)
                        result(["id": instrument.id, "name": instrument.name])
                    } else {
                        result(FlutterError(code: "INVALID_ARGUMENTS",
                                          message: "Invalid arguments for saveInstrument",
                                          details: nil))
                    }
                    
                case "getInstruments":
                    let instruments = try await DatabaseManager.shared.getInstruments()
                    result(instruments.map { ["id": $0.id, "name": $0.name] })
                    
                case "saveCategory":
                    if let args = call.arguments as? [String: Any],
                       let name = args["name"] as? String,
                       let instrumentId = args["instrumentId"] as? String {
                        let category = try await DatabaseManager.shared.saveCategory(name, instrumentId: instrumentId)
                        result([
                            "id": category.id,
                            "name": category.name,
                            "instrumentId": category.instrument?.id as Any
                        ])
                    } else {
                        result(FlutterError(code: "INVALID_ARGUMENTS",
                                          message: "Invalid arguments for saveCategory",
                                          details: nil))
                    }
                    
                case "getCategories":
                    if let args = call.arguments as? [String: Any] {
                        let instrumentId = args["instrumentId"] as? String
                        let categories = try await DatabaseManager.shared.getCategories(instrumentId: instrumentId)
                        result(categories.map {
                            [
                                "id": $0.id,
                                "name": $0.name,
                                "instrumentId": $0.instrument?.id as Any
                            ]
                        })
                    } else {
                        result(FlutterError(code: "INVALID_ARGUMENTS",
                                          message: "Invalid arguments for getCategories",
                                          details: nil))
                    }
                    
                case "saveExercise":
                    if let args = call.arguments as? [String: Any],
                       let name = args["name"] as? String,
                       let description = args["description"] as? String,
                       let categoryId = args["categoryId"] as? String {
                        let exercise = try await DatabaseManager.shared.saveExercise(
                            name: name,
                            exerciseDescription: description,
                            categoryId: categoryId
                        )
                        result([
                            "id": exercise.id,
                            "name": exercise.name,
                            "description": exercise.exerciseDescription,
                            "categoryId": exercise.category?.id as Any
                        ])
                    } else {
                        result(FlutterError(code: "INVALID_ARGUMENTS",
                                          message: "Invalid arguments for saveExercise",
                                          details: nil))
                    }
                    
                case "getExercises":
                    if let args = call.arguments as? [String: Any] {
                        let categoryId = args["categoryId"] as? String
                        let exercises = try await DatabaseManager.shared.getExercises(categoryId: categoryId)
                        result(exercises.map {
                            [
                                "id": $0.id,
                                "name": $0.name,
                                "description": $0.exerciseDescription,
                                "categoryId": $0.category?.id as Any
                            ]
                        })
                    } else {
                        result(FlutterError(code: "INVALID_ARGUMENTS",
                                          message: "Invalid arguments for getExercises",
                                          details: nil))
                    }
                    
                case "savePractice":
                    if let args = call.arguments as? [String: Any],
                       let exerciseId = args["exerciseId"] as? String,
                       let instrumentId = args["instrumentId"] as? String,
                       let duration = args["duration"] as? Double {
                        let notes = args["notes"] as? String
                        let practice = try await DatabaseManager.shared.savePractice(
                            exerciseId: exerciseId,
                            instrumentId: instrumentId,
                            duration: duration,
                            notes: notes
                        )
                        result([
                            "id": practice.id,
                            "startTime": practice.startTime.timeIntervalSince1970,
                            "duration": practice.duration,
                            "notes": practice.notes as Any,
                            "exerciseId": practice.exercise?.id as Any,
                            "instrumentId": practice.instrument?.id as Any
                        ])
                    } else {
                        result(FlutterError(code: "INVALID_ARGUMENTS",
                                          message: "Invalid arguments for savePractice",
                                          details: nil))
                    }
                    
                case "getPractices":
                    if let args = call.arguments as? [String: Any] {
                        let exerciseId = args["exerciseId"] as? String
                        let instrumentId = args["instrumentId"] as? String
                        let practices = try await DatabaseManager.shared.getPractices(
                            exerciseId: exerciseId,
                            instrumentId: instrumentId
                        )
                        result(practices.map {
                            [
                                "id": $0.id,
                                "startTime": $0.startTime.timeIntervalSince1970,
                                "duration": $0.duration,
                                "notes": $0.notes as Any,
                                "exerciseId": $0.exercise?.id as Any,
                                "instrumentId": $0.instrument?.id as Any
                            ]
                        })
                    } else {
                        result(FlutterError(code: "INVALID_ARGUMENTS",
                                          message: "Invalid arguments for getPractices",
                                          details: nil))
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