import 'package:flutter/services.dart';

abstract class StorageService {
  Future<void> saveThemeMode(bool isDarkMode);
  Future<bool?> getThemeMode();
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
      return result as bool?;
    } catch (e) {
      print('Error getting theme mode: $e');
      return null;
    }
  }

  Future<void> saveLocale(String languageCode) async {
    try {
      await _platform.invokeMethod('saveLocale', {'locale': languageCode});
    } catch (e) {
      print('Error saving locale: $e');
    }
  }

  Future<String?> getLocale() async {
    try {
      final result = await _platform.invokeMethod('getLocale');
      return result as String?;
    } catch (e) {
      print('Error getting locale: $e');
      return null;
    }
  }
} 