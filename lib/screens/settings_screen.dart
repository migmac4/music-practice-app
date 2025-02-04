import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../widgets/custom_time_picker.dart';
import '../models/instrument.dart';

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
  late String _currentLanguage = widget.currentLocale.languageCode;
  bool _isReminderEnabled = false;
  TimeOfDay? _reminderTime;
  Instrument _selectedInstrument = Instrument.acousticGuitar; // Default instrument

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final locale = await _storageService.getLocale();
    final reminder = await _storageService.getDailyReminder();
    final defaultInstrument = await _storageService.getDefaultInstrument();

    if (mounted) {
      setState(() {
        _currentLanguage = locale ?? 'en';
        _isReminderEnabled = reminder?['enabled'] as bool? ?? false;
        _reminderTime = reminder != null
            ? TimeOfDay(hour: reminder['hour'] as int, minute: reminder['minute'] as int)
            : const TimeOfDay(hour: 9, minute: 0);
        if (defaultInstrument != null) {
          _selectedInstrument = Instrument.values.firstWhere(
            (i) => i.name == defaultInstrument,
            orElse: () => Instrument.acousticGuitar,
          );
        }
      });
    }
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

    // Salvar as configurações do lembrete
    await _storageService.saveDailyReminder(
      enabled,
      _reminderTime?.hour ?? 9,
      _reminderTime?.minute ?? 0,
    );
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

                      // Salvar as configurações do lembrete
                      await _storageService.saveDailyReminder(
                        _isReminderEnabled,
                        newTime.hour,
                        newTime.minute,
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
    final context = this.context;
    return MediaQuery.of(context).alwaysUse24HourFormat
        ? '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}'
        : time.format(context);
  }

  String _getInstrumentName(Instrument instrument, AppLocalizations l10n) {
    return switch (instrument) {
      Instrument.acousticGuitar => l10n.instrumentAcousticGuitar,
      Instrument.bass => l10n.instrumentBass,
      Instrument.cello => l10n.instrumentCello,
      Instrument.clarinet => l10n.instrumentClarinet,
      Instrument.drums => l10n.instrumentDrums,
      Instrument.electricGuitar => l10n.instrumentElectricGuitar,
      Instrument.flute => l10n.instrumentFlute,
      Instrument.keyboard => l10n.instrumentKeyboard,
      Instrument.piano => l10n.instrumentPiano,
      Instrument.saxophone => l10n.instrumentSaxophone,
      Instrument.trumpet => l10n.instrumentTrumpet,
      Instrument.ukulele => l10n.instrumentUkulele,
      Instrument.violin => l10n.instrumentViolin,
    };
  }

  void _onInstrumentChanged(Instrument? newValue) {
    if (newValue != null) {
      setState(() {
        _selectedInstrument = newValue;
      });
      _storageService.saveDefaultInstrument(newValue.name);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    // Criar lista ordenada de instrumentos
    final sortedInstruments = Instrument.values.toList()
      ..sort((a, b) => _getInstrumentName(a, l10n).compareTo(_getInstrumentName(b, l10n)));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text(l10n.instrument),
            trailing: DropdownButton<Instrument>(
              value: _selectedInstrument,
              items: sortedInstruments.map((Instrument instrument) {
                return DropdownMenuItem<Instrument>(
                  value: instrument,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        instrument.iconPath,
                        width: 24,
                        height: 24,
                        colorFilter: ColorFilter.mode(
                          Theme.of(context).iconTheme.color ?? Colors.black,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(_getInstrumentName(instrument, l10n)),
                    ],
                  ),
                );
              }).toList(),
              onChanged: _onInstrumentChanged,
            ),
          ),
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