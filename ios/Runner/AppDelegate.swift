import Flutter
import UIKit
import SwiftData

// Os arquivos no mesmo módulo não precisam ser importados explicitamente
// O Swift encontrará automaticamente as classes no mesmo target

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    
    // Storage Channel
    let storageChannel = FlutterMethodChannel(
      name: "com.miguelmacedo.music_practice_app/storage",
      binaryMessenger: controller.binaryMessenger
    )
    
    storageChannel.setMethodCallHandler { [weak self] call, result in
      switch call.method {
      case "saveThemeMode":
        if let args = call.arguments as? [String: Any],
           let isDarkMode = args["isDarkMode"] as? Bool {
          Task { @MainActor in
            do {
              try await DataManager.shared.saveThemeMode(isDarkMode)
              result(nil)
            } catch {
              result(FlutterError(
                code: "ERROR",
                message: error.localizedDescription,
                details: nil
              ))
            }
          }
        } else {
          result(FlutterError(
            code: "INVALID_ARGUMENTS",
            message: "isDarkMode is required",
            details: nil
          ))
        }
        
      case "getThemeMode":
        Task { @MainActor in
          do {
            let isDarkMode = try await DataManager.shared.getThemeMode()
            result(isDarkMode)
          } catch {
            result(FlutterError(
              code: "ERROR",
              message: error.localizedDescription,
              details: nil
            ))
          }
        }
        
      case "saveLocale":
        if let args = call.arguments as? [String: Any],
           let locale = args["locale"] as? String {
          UserDefaults.standard.set(locale, forKey: "app_locale")
          result(nil)
        } else {
          result(FlutterError(
            code: "INVALID_ARGUMENTS",
            message: "locale is required",
            details: nil
          ))
        }
        
      case "getLocale":
        let locale = UserDefaults.standard.string(forKey: "app_locale")
        result(locale)
        
      default:
        result(FlutterMethodNotImplemented)
      }
    }
    
    // Data Manager Channel
    let dataManagerChannel = FlutterMethodChannel(
      name: "com.miguelmacedo.music_practice_app/data_manager",
      binaryMessenger: controller.binaryMessenger
    )
    
    dataManagerChannel.setMethodCallHandler { [weak self] call, result in
      switch call.method {
      case "getPractices":
        Task { @MainActor in
          do {
            let practices = try await DataManager.shared.getPractices()
            let practicesData = practices.map { practice in
              [
                "id": practice.id,
                "startTime": Int(practice.startTime.timeIntervalSince1970 * 1000),
                "duration": practice.duration,
                "notes": practice.notes,
                "exercise": practice.exercise.map { exercise in
                  [
                    "id": exercise.id,
                    "name": exercise.name,
                    "exerciseDescription": exercise.exerciseDescription
                  ]
                },
                "instrument": practice.instrument.map { instrument in
                  [
                    "id": instrument.id,
                    "name": instrument.name
                  ]
                }
              ]
            }
            result(practicesData)
          } catch {
            result(FlutterError(
              code: "ERROR",
              message: error.localizedDescription,
              details: nil
            ))
          }
        }
        
      default:
        result(FlutterMethodNotImplemented)
      }
    }
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
