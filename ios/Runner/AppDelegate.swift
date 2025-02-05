import UIKit
import Flutter

@UIApplicationMain
class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        
        // Register storage plugin
        let storageChannel = FlutterMethodChannel(name: "com.miguelmacedo.music_practice_app/storage",
                                                binaryMessenger: controller.binaryMessenger)
        let storageInstance = StoragePlugin()
        storageChannel.setMethodCallHandler(storageInstance.handle)
        
        // Register database plugin
        let databaseChannel = FlutterMethodChannel(name: "com.miguelmacedo.music_practice_app/data_manager",
                                                 binaryMessenger: controller.binaryMessenger)
        let databaseInstance = DatabasePlugin()
        databaseChannel.setMethodCallHandler(databaseInstance.handle)
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
} 
