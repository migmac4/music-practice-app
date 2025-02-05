import 'package:flutter/services.dart';

abstract class StorageService {
  Future<void> saveThemeMode(bool isDarkMode);
  Future<bool?> getThemeMode();
  Future<void> saveLocale(String languageCode);
  Future<String?> getLocale();
  Future<void> saveDefaultInstrument(String instrumentId);
  Future<String?> getDefaultInstrument();
  Future<void> saveDailyReminder(bool enabled, int hour, int minute);
  Future<Map<String, dynamic>?> getDailyReminder();
}

class NativeStorageService implements StorageService {
  static const _platform = MethodChannel('com.miguelmacedo.music_practice_app/storage');
  
  @override
  Future<void> saveThemeMode(bool isDarkMode) async {
    try {
      await _platform.invokeMethod('saveThemeMode', {'isDarkMode': isDarkMode});
    } catch (e) {
      print('Error saving theme mode: $e');
    }
  }

  @override
  Future<bool?> getThemeMode() async {
    try {
      final result = await _platform.invokeMethod('getThemeMode');
      if (result is! bool) {
        print('Error: getThemeMode returned invalid type: ${result.runtimeType}');
        return null;
      }
      return result;
    } catch (e) {
      print('Error getting theme mode: $e');
      return null;
    }
  }

  @override
  Future<void> saveLocale(String languageCode) async {
    try {
      await _platform.invokeMethod('saveLocale', {'locale': languageCode});
    } catch (e) {
      print('Error saving locale: $e');
    }
  }

  @override
  Future<String?> getLocale() async {
    try {
      final result = await _platform.invokeMethod('getLocale');
      if (result is! String) {
        print('Error: getLocale returned invalid type: ${result.runtimeType}');
        return null;
      }
      return result;
    } catch (e) {
      print('Error getting locale: $e');
      return null;
    }
  }

  @override
  Future<void> saveDefaultInstrument(String instrumentId) async {
    try {
      await _platform.invokeMethod('saveDefaultInstrument', {'instrumentId': instrumentId});
    } catch (e) {
      print('Error saving default instrument: $e');
    }
  }

  @override
  Future<String?> getDefaultInstrument() async {
    try {
      final result = await _platform.invokeMethod('getDefaultInstrument');
      if (result is! String) {
        print('Error: getDefaultInstrument returned invalid type: ${result.runtimeType}');
        return null;
      }
      return result;
    } catch (e) {
      print('Error getting default instrument: $e');
      return null;
    }
  }

  @override
  Future<void> saveDailyReminder(bool enabled, int hour, int minute) async {
    if (hour < 0 || hour > 23) {
      throw ArgumentError('Hour must be between 0 and 23');
    }
    if (minute < 0 || minute > 59) {
      throw ArgumentError('Minute must be between 0 and 59');
    }

    try {
      await _platform.invokeMethod('saveDailyReminder', {
        'enabled': enabled,
        'hour': hour,
        'minute': minute,
      });
    } catch (e) {
      print('Error saving daily reminder: $e');
    }
  }

  @override
  Future<Map<String, dynamic>?> getDailyReminder() async {
    try {
      final result = await _platform.invokeMethod('getDailyReminder');
      if (result == null) return null;
      
      if (result is! Map) {
        print('Error: getDailyReminder returned invalid type: ${result.runtimeType}');
        return null;
      }
      
      // Convert the platform-specific map to a Dart Map<String, dynamic>
      return Map<String, dynamic>.from(result as Map);
    } catch (e) {
      print('Error getting daily reminder: $e');
      return null;
    }
  }
} 