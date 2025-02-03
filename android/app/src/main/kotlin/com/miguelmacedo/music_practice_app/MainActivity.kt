package com.miguelmacedo.music_practice_app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

class MainActivity: FlutterActivity() {
    private val scope = CoroutineScope(Dispatchers.Main)
    private lateinit var dataManager: DataManager

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        dataManager = DataManager(applicationContext)

        // Storage Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.miguelmacedo.music_practice_app/storage")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "saveThemeMode" -> {
                        val isDarkMode = call.argument<Boolean>("isDarkMode")
                        if (isDarkMode != null) {
                            scope.launch {
                                try {
                                    dataManager.saveThemeMode(isDarkMode)
                                    result.success(null)
                                } catch (e: Exception) {
                                    result.error("ERROR", e.message, null)
                                }
                            }
                        } else {
                            result.error("INVALID_ARGUMENTS", "isDarkMode is required", null)
                        }
                    }
                    "getThemeMode" -> {
                        scope.launch {
                            try {
                                val isDarkMode = dataManager.getThemeMode()
                                result.success(isDarkMode)
                            } catch (e: Exception) {
                                result.error("ERROR", e.message, null)
                            }
                        }
                    }
                    "saveLocale" -> {
                        val locale = call.argument<String>("locale")
                        if (locale != null) {
                            scope.launch {
                                try {
                                    dataManager.saveLocale(locale)
                                    result.success(null)
                                } catch (e: Exception) {
                                    result.error("ERROR", e.message, null)
                                }
                            }
                        } else {
                            result.error("INVALID_ARGUMENTS", "locale is required", null)
                        }
                    }
                    "getLocale" -> {
                        scope.launch {
                            try {
                                val locale = dataManager.getLocale()
                                result.success(locale)
                            } catch (e: Exception) {
                                result.error("ERROR", e.message, null)
                            }
                        }
                    }
                    else -> result.notImplemented()
                }
            }

        // Data Manager Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.miguelmacedo.music_practice_app/data_manager")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getPractices" -> {
                        scope.launch {
                            try {
                                val practices = dataManager.getPractices()
                                result.success(practices)
                            } catch (e: Exception) {
                                result.error("ERROR", e.message, null)
                            }
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
