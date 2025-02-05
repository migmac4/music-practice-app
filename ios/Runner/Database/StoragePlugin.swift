import Flutter
import Foundation
import os

public class StoragePlugin: NSObject, FlutterPlugin {
    private let logger = Logger(subsystem: "com.miguelmacedo.music_practice_app", category: "StoragePlugin")
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "com.miguelmacedo.music_practice_app/storage",
                                         binaryMessenger: registrar.messenger())
        let instance = StoragePlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        logger.debug("Received method call: \(call.method)")
        if let args = call.arguments as? [String: Any] {
            logger.debug("With arguments: \(args)")
        }
        
        Task {
            do {
                switch call.method {
                case "saveThemeMode":
                    if let args = call.arguments as? [String: Any],
                       let isDarkMode = args["isDarkMode"] as? Bool {
                        try await DatabaseManager.shared.saveThemeMode(isDarkMode)
                        logger.debug("Theme mode saved: \(isDarkMode)")
                        result(nil)
                    } else {
                        logger.error("Invalid arguments for saveThemeMode")
                        result(FlutterError(code: "INVALID_ARGUMENTS",
                                          message: "Invalid arguments for saveThemeMode",
                                          details: nil))
                    }
                    
                case "getThemeMode":
                    let isDarkMode = try await DatabaseManager.shared.getThemeMode()
                    logger.debug("Retrieved theme mode: \(isDarkMode)")
                    result(isDarkMode)
                    
                case "saveLocale":
                    if let args = call.arguments as? [String: Any],
                       let locale = args["locale"] as? String {
                        UserDefaults.standard.set(locale, forKey: "app_locale")
                        logger.debug("Locale saved: \(locale)")
                        result(nil)
                    } else {
                        logger.error("Invalid arguments for saveLocale")
                        result(FlutterError(code: "INVALID_ARGUMENTS",
                                          message: "Invalid arguments for saveLocale",
                                          details: nil))
                    }
                    
                case "getLocale":
                    let locale = UserDefaults.standard.string(forKey: "app_locale") ?? "en"
                    logger.debug("Retrieved locale: \(locale)")
                    result(locale)
                    
                case "saveDailyReminder":
                    if let args = call.arguments as? [String: Any],
                       let enabled = args["enabled"] as? Bool,
                       let hour = args["hour"] as? Int,
                       let minute = args["minute"] as? Int {
                        let reminder = [
                            "enabled": enabled,
                            "hour": hour,
                            "minute": minute
                        ] as [String : Any]
                        UserDefaults.standard.set(reminder, forKey: "daily_reminder")
                        logger.debug("Daily reminder saved: enabled=\(enabled), hour=\(hour), minute=\(minute)")
                        result(nil)
                    } else {
                        logger.error("Invalid arguments for saveDailyReminder")
                        result(FlutterError(code: "INVALID_ARGUMENTS",
                                          message: "Invalid arguments for saveDailyReminder",
                                          details: nil))
                    }
                    
                case "getDailyReminder":
                    if let reminder = UserDefaults.standard.dictionary(forKey: "daily_reminder") {
                        logger.debug("Retrieved daily reminder: \(reminder)")
                        let enabled: Bool
                        if let boolValue = reminder["enabled"] as? Bool {
                            enabled = boolValue
                        } else if let intValue = reminder["enabled"] as? Int {
                            enabled = intValue == 1
                        } else {
                            enabled = false
                        }
                        
                        let hour = reminder["hour"] as? Int ?? 9
                        let minute = reminder["minute"] as? Int ?? 0
                        
                        let typedReminder: [String: Any] = [
                            "enabled": enabled,
                            "hour": hour,
                            "minute": minute
                        ]
                        
                        logger.debug("Converted reminder: \(typedReminder)")
                        result(typedReminder)
                    } else {
                        logger.debug("No daily reminder found, returning default values")
                        let defaultReminder: [String: Any] = [
                            "enabled": false,
                            "hour": 9,
                            "minute": 0
                        ]
                        result(defaultReminder)
                    }
                    
                case "saveDefaultInstrument":
                    if let args = call.arguments as? [String: Any],
                       let instrumentId = args["instrumentId"] as? String {
                        logger.debug("Attempting to save default instrument: \(instrumentId)")
                        UserDefaults.standard.set(instrumentId, forKey: "default_instrument")
                        UserDefaults.standard.synchronize()
                        
                        // Verify if the value was actually saved
                        if let savedValue = UserDefaults.standard.string(forKey: "default_instrument") {
                            logger.debug("Verification - Saved instrument value: \(savedValue)")
                            if savedValue == instrumentId {
                                logger.debug("Default instrument saved and verified successfully")
                            } else {
                                logger.error("Saved value (\(savedValue)) does not match input value (\(instrumentId))")
                            }
                        } else {
                            logger.error("Failed to verify saved instrument - value not found in UserDefaults")
                        }
                        result(nil)
                    } else {
                        logger.error("Invalid arguments for saveDefaultInstrument: \(String(describing: call.arguments))")
                        result(FlutterError(code: "INVALID_ARGUMENTS",
                                          message: "Invalid arguments for saveDefaultInstrument",
                                          details: nil))
                    }
                    
                case "getDefaultInstrument":
                    logger.debug("Attempting to retrieve default instrument")
                    let instrumentId = UserDefaults.standard.string(forKey: "default_instrument")
                    logger.debug("Retrieved default instrument from UserDefaults: \(String(describing: instrumentId))")
                    result(instrumentId)
                    
                case "saveDailyGoal":
                    if let args = call.arguments as? [String: Any],
                       let minutes = args["minutes"] as? Int {
                        UserDefaults.standard.set(minutes, forKey: "daily_goal")
                        logger.debug("Daily goal saved: \(minutes)")
                        result(nil)
                    } else {
                        logger.error("Invalid arguments for saveDailyGoal")
                        result(FlutterError(code: "INVALID_ARGUMENTS",
                                          message: "Invalid arguments for saveDailyGoal",
                                          details: nil))
                    }
                    
                case "getDailyGoal":
                    let minutes = UserDefaults.standard.integer(forKey: "daily_goal")
                    logger.debug("Retrieved daily goal: \(minutes)")
                    result(minutes)
                    
                default:
                    logger.error("Method not implemented: \(call.method)")
                    result(FlutterMethodNotImplemented)
                }
            } catch {
                logger.error("Error handling method \(call.method): \(error.localizedDescription)")
                result(FlutterError(code: "STORAGE_ERROR",
                                  message: error.localizedDescription,
                                  details: nil))
            }
        }
    }
} 