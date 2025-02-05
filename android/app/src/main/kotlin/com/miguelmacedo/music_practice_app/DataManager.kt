package com.miguelmacedo.music_practice_app

import android.content.Context
import android.content.SharedPreferences
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

class DataManager(private val context: Context) {
    private val prefs: SharedPreferences = context.getSharedPreferences("app_settings", Context.MODE_PRIVATE)

    companion object {
        private const val THEME_KEY = "theme_mode"
        private const val LOCALE_KEY = "app_locale"
        private const val DEFAULT_INSTRUMENT_KEY = "default_instrument"
        private const val REMINDER_ENABLED_KEY = "reminder_enabled"
        private const val REMINDER_HOUR_KEY = "reminder_hour"
        private const val REMINDER_MINUTE_KEY = "reminder_minute"
        private const val DAILY_GOAL_KEY = "daily_goal"
    }

    suspend fun saveThemeMode(isDarkMode: Boolean) = withContext(Dispatchers.IO) {
        prefs.edit().putBoolean(THEME_KEY, isDarkMode).apply()
    }

    suspend fun getThemeMode(): Boolean = withContext(Dispatchers.IO) {
        return@withContext prefs.getBoolean(THEME_KEY, false)
    }

    suspend fun saveLocale(locale: String) = withContext(Dispatchers.IO) {
        prefs.edit().putString(LOCALE_KEY, locale).apply()
    }

    suspend fun getLocale(): String? = withContext(Dispatchers.IO) {
        return@withContext prefs.getString(LOCALE_KEY, null)
    }

    suspend fun saveDefaultInstrument(instrumentId: String) = withContext(Dispatchers.IO) {
        prefs.edit().putString(DEFAULT_INSTRUMENT_KEY, instrumentId).apply()
    }

    suspend fun getDefaultInstrument(): String? = withContext(Dispatchers.IO) {
        return@withContext prefs.getString(DEFAULT_INSTRUMENT_KEY, null)
    }

    suspend fun saveDailyReminder(enabled: Boolean, hour: Int, minute: Int) = withContext(Dispatchers.IO) {
        prefs.edit()
            .putBoolean(REMINDER_ENABLED_KEY, enabled)
            .putInt(REMINDER_HOUR_KEY, hour)
            .putInt(REMINDER_MINUTE_KEY, minute)
            .apply()
    }

    suspend fun getDailyReminder(): Map<String, Any>? = withContext(Dispatchers.IO) {
        val enabled = prefs.getBoolean(REMINDER_ENABLED_KEY, false)
        val hour = prefs.getInt(REMINDER_HOUR_KEY, 0)
        val minute = prefs.getInt(REMINDER_MINUTE_KEY, 0)
        return@withContext mapOf(
            "enabled" to enabled,
            "hour" to hour,
            "minute" to minute
        )
    }

    suspend fun saveDailyGoal(minutes: Int) = withContext(Dispatchers.IO) {
        prefs.edit().putInt(DAILY_GOAL_KEY, minutes).apply()
    }

    suspend fun getDailyGoal(): Int = withContext(Dispatchers.IO) {
        return@withContext prefs.getInt(DAILY_GOAL_KEY, 30) // 30 minutos como valor padrão
    }
} 