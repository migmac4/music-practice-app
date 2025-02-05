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
                    "saveDefaultInstrument" -> {
                        val instrumentId = call.argument<String>("instrumentId")
                        if (instrumentId != null) {
                            scope.launch {
                                try {
                                    dataManager.saveDefaultInstrument(instrumentId)
                                    result.success(null)
                                } catch (e: Exception) {
                                    result.error("ERROR", e.message, null)
                                }
                            }
                        } else {
                            result.error("INVALID_ARGUMENTS", "instrumentId is required", null)
                        }
                    }
                    "getDefaultInstrument" -> {
                        scope.launch {
                            try {
                                val instrumentId = dataManager.getDefaultInstrument()
                                result.success(instrumentId)
                            } catch (e: Exception) {
                                result.error("ERROR", e.message, null)
                            }
                        }
                    }
                    "saveDailyReminder" -> {
                        val enabled = call.argument<Boolean>("enabled")
                        val hour = call.argument<Int>("hour")
                        val minute = call.argument<Int>("minute")
                        if (enabled != null && hour != null && minute != null) {
                            scope.launch {
                                try {
                                    dataManager.saveDailyReminder(enabled, hour, minute)
                                    result.success(null)
                                } catch (e: Exception) {
                                    result.error("ERROR", e.message, null)
                                }
                            }
                        } else {
                            result.error("INVALID_ARGUMENTS", "enabled, hour and minute are required", null)
                        }
                    }
                    "getDailyReminder" -> {
                        scope.launch {
                            try {
                                val reminder = dataManager.getDailyReminder()
                                result.success(reminder)
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
