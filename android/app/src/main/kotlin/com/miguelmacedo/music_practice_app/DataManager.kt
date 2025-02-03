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

    suspend fun getPractices(): List<Map<String, Any>> = withContext(Dispatchers.IO) {
        return@withContext emptyList()
    }
} 