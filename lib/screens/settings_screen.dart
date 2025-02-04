import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../widgets/custom_time_picker.dart';

class SettingsScreen extends StatefulWidget {
  final Function(bool) onThemeChanged;
  final Function(String) onLocaleChanged;
  final bool isDarkMode;
  final Locale currentLocale;

  const SettingsScreen({
    super.key,
    required this.onThemeChanged,
    required this.onLocaleChanged,
    required this.isDarkMode,
    required this.currentLocale,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _storageService = NativeStorageService();
  final _notificationService = NotificationService.instance;
  late String _currentLanguage;
  bool _isReminderEnabled = false;
  TimeOfDay? _reminderTime;

  @override
  void initState() {
    super.initState();
    _currentLanguage = widget.currentLocale.languageCode;
    _loadReminderSettings();
  }

  Future<void> _loadReminderSettings() async {
    final isEnabled = await _notificationService.isReminderEnabled();
    final savedTime = await _notificationService.getReminderTime();

    setState(() {
      _isReminderEnabled = isEnabled;
      _reminderTime = savedTime != null
          ? TimeOfDay(hour: savedTime.hour, minute: savedTime.minute)
          : const TimeOfDay(hour: 19, minute: 0); // Padrão: 19:00
    });
  }

  Future<void> _toggleTheme() async {
    try {
      final newMode = !widget.isDarkMode;
      await _storageService.saveThemeMode(newMode);
      widget.onThemeChanged(newMode);
    } catch (e) {
      print('SettingsScreen - Error toggling theme: $e');
    }
  }

  Future<void> _changeLocale(String languageCode) async {
    try {
      setState(() {
        _currentLanguage = languageCode;
      });
      await _storageService.saveLocale(languageCode);
      widget.onLocaleChanged(languageCode);
    } catch (e) {
      print('SettingsScreen - Error changing locale: $e');
      setState(() {
        _currentLanguage = widget.currentLocale.languageCode;
      });
    }
  }

  Future<void> _toggleReminder(bool enabled) async {
    if (enabled) {
      if (_reminderTime == null) {
        _reminderTime = TimeOfDay.now();
      }

      final now = DateTime.now();
      final reminderDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        _reminderTime!.hour,
        _reminderTime!.minute,
      );

      final l10n = AppLocalizations.of(context)!;
      await NotificationService.instance.scheduleDailyReminder(
        title: l10n.reminderNotificationTitle,
        body: l10n.reminderNotificationBody,
        time: reminderDateTime,
      );
    } else {
      await NotificationService.instance.cancelDailyReminder();
    }

    setState(() {
      _isReminderEnabled = enabled;
    });
  }

  Future<void> _selectReminderTime() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppLocalizations.of(context)!.selectTime,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                CustomTimePicker(
                  initialTime: _reminderTime ?? const TimeOfDay(hour: 19, minute: 0),
                  onTimeChanged: (TimeOfDay newTime) async {
                    setState(() {
                      _reminderTime = newTime;
                    });

                    if (_isReminderEnabled) {
                      final now = DateTime.now();
                      final reminderDateTime = DateTime(
                        now.year,
                        now.month,
                        now.day,
                        newTime.hour,
                        newTime.minute,
                      );

                      final l10n = AppLocalizations.of(context)!;
                      await NotificationService.instance.scheduleDailyReminder(
                        title: l10n.reminderNotificationTitle,
                        body: l10n.reminderNotificationBody,
                        time: reminderDateTime,
                      );
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(AppLocalizations.of(context)!.ok),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getDisplayLanguage(String code) {
    return switch (code) {
      'en' => 'English',
      'pt' => 'Português',
      _ => code,
    };
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text(l10n.darkMode),
            trailing: Switch(
              value: widget.isDarkMode,
              onChanged: (bool value) => _toggleTheme(),
            ),
          ),
          ListTile(
            title: Text(l10n.language),
            trailing: DropdownButton<String>(
              value: _currentLanguage,
              items: ['en', 'pt'].map((String code) {
                return DropdownMenuItem<String>(
                  value: code,
                  child: Text(_getDisplayLanguage(code)),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  _changeLocale(newValue);
                }
              },
            ),
          ),
          ListTile(
            title: Text(l10n.dailyReminder),
            trailing: Switch(
              value: _isReminderEnabled,
              onChanged: _toggleReminder,
            ),
          ),
          if (_isReminderEnabled)
            ListTile(
              title: Text(l10n.reminderTime),
              trailing: TextButton(
                onPressed: _selectReminderTime,
                child: Text(
                  _reminderTime != null ? _formatTimeOfDay(_reminderTime!) : '--:--',
                  style: theme.textTheme.titleMedium,
                ),
              ),
            ),
        ],
      ),
    );
  }
} 