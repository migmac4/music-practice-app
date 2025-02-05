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
  Instrument _selectedInstrument = Instrument.acousticGuitar;
  int _dailyGoal = 30; // Valor padrão de 30 minutos
  final _dailyGoalController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _dailyGoalController.addListener(() {
      if (!_dailyGoalController.text.isEmpty) {
        final minutes = int.tryParse(_dailyGoalController.text);
        if (minutes != null && minutes > 0 && minutes != _dailyGoal) {
          _updateDailyGoal(_dailyGoalController.text);
        }
      }
    });
  }

  @override
  void dispose() {
    _dailyGoalController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    try {
      final locale = await _storageService.getLocale();
      final reminder = await _storageService.getDailyReminder();
      final defaultInstrument = await _storageService.getDefaultInstrument();
      final dailyGoal = await _storageService.getDailyGoal();
      
      print('DEBUG: Loading daily goal from storage: $dailyGoal');

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
          if (dailyGoal != null) {
            print('DEBUG: Setting daily goal to: $dailyGoal');
            _dailyGoal = dailyGoal;
            _dailyGoalController.text = dailyGoal.toString();
          } else {
            print('DEBUG: No daily goal found, setting default to 30');
            _dailyGoal = 30;
            _dailyGoalController.text = '30';
            // Salvar o valor padrão se não existir
            _storageService.saveDailyGoal(30);
          }
        });
      }
    } catch (e) {
      print('Error loading settings: $e');
      // Em caso de erro, garantir que pelo menos o valor padrão seja exibido
      if (mounted) {
        setState(() {
          _dailyGoal = 30;
          _dailyGoalController.text = '30';
        });
      }
    }
  }

  Future<void> _toggleTheme(bool value) async {
    try {
      await _storageService.saveThemeMode(value);
      widget.onThemeChanged(value);
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
    
    if (MediaQuery.of(context).alwaysUse24HourFormat) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
    
    // Formato 12 horas
    final hour = time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    
    // Ajusta para exibir 12 ao invés de 0 para meio-dia/meia-noite
    final hourDisplay = hour == 0 ? 12 : hour;
    
    return '$hourDisplay:$minute $period';
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

  Future<void> _updateDailyGoal(String value) async {
    print('DEBUG: Attempting to update daily goal with value: $value');
    final minutes = int.tryParse(value);
    if (minutes != null && minutes > 0) {
      print('DEBUG: Valid minutes value: $minutes');
      setState(() {
        _dailyGoal = minutes;
      });
      try {
        print('DEBUG: Saving daily goal to storage: $minutes');
        await _storageService.saveDailyGoal(minutes);
        print('DEBUG: Daily goal saved successfully');
      } catch (e) {
        print('DEBUG: Error saving daily goal: $e');
        // Restaurar o valor anterior em caso de erro
        setState(() {
          _dailyGoal = int.tryParse(_dailyGoalController.text) ?? 30;
        });
      }
    } else {
      print('DEBUG: Invalid minutes value: $value');
      // Restaurar o valor anterior se o input for inválido
      setState(() {
        _dailyGoalController.text = _dailyGoal.toString();
      });
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
        leading: BackButton(
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Theme Section
          Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: theme.colorScheme.outline.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        height: 40,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          widget.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                          color: theme.colorScheme.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.isDarkMode ? l10n.darkMode : l10n.lightMode,
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                      Switch(
                        value: widget.isDarkMode,
                        onChanged: _toggleTheme,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Daily Goal Section
          Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: theme.colorScheme.outline.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    height: 40,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.flag_rounded,
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    l10n.dailyGoal,
                    style: theme.textTheme.titleMedium,
                  ),
                  const Spacer(),
                  Container(
                    width: 120,
                    height: 40,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _dailyGoalController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.end,
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: InputDecoration(
                              hintText: '0',
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              isDense: true,
                              constraints: const BoxConstraints(maxHeight: 40),
                              hintStyle: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            onSubmitted: _updateDailyGoal,
                            onEditingComplete: () {
                              _updateDailyGoal(_dailyGoalController.text);
                            },
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 8,
                          ),
                          child: Text(
                            'min',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Daily Reminder Section
          Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: theme.colorScheme.outline.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        height: 40,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.notifications_outlined,
                          color: theme.colorScheme.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        l10n.dailyReminder,
                        style: theme.textTheme.titleMedium,
                      ),
                      const Spacer(),
                      Switch(
                        value: _isReminderEnabled,
                        onChanged: _toggleReminder,
                      ),
                    ],
                  ),
                  if (_isReminderEnabled) ...[
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                        visualDensity: VisualDensity.compact,
                        minVerticalPadding: 0,
                        title: Text(
                          l10n.reminderTime,
                          style: theme.textTheme.bodyLarge,
                        ),
                        trailing: TextButton(
                          onPressed: _selectReminderTime,
                          child: Text(
                            _reminderTime != null ? _formatTimeOfDay(_reminderTime!) : '--:--',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Language Section
          Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: theme.colorScheme.outline.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    height: 40,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.language,
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    l10n.language,
                    style: theme.textTheme.titleMedium,
                  ),
                  const Spacer(),
                  Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    constraints: const BoxConstraints(maxHeight: 40),
                    child: DropdownButton<String>(
                      value: _currentLanguage,
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          _changeLocale(newValue);
                        }
                      },
                      items: const [
                        DropdownMenuItem(
                          value: 'en',
                          child: Text('English'),
                        ),
                        DropdownMenuItem(
                          value: 'pt',
                          child: Text('Português'),
                        ),
                      ],
                      underline: const SizedBox(),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                      menuMaxHeight: 300,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Default Instrument Section
          Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: theme.colorScheme.outline.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    height: 40,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SvgPicture.asset(
                      _selectedInstrument.iconPath,
                      width: 24,
                      height: 24,
                      colorFilter: ColorFilter.mode(
                        theme.colorScheme.primary,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    l10n.instrument,
                    style: theme.textTheme.titleMedium,
                  ),
                  const Spacer(),
                  Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: Colors.transparent,
                            builder: (context) => Container(
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(28),
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(height: 8),
                                  Container(
                                    width: 32,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Text(
                                      l10n.instrument,
                                      style: theme.textTheme.titleLarge,
                                    ),
                                  ),
                                  const Divider(),
                                  Flexible(
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: sortedInstruments.length,
                                      itemBuilder: (context, index) {
                                        final instrument = sortedInstruments[index];
                                        final isSelected = instrument == _selectedInstrument;
                                        return ListTile(
                                          leading: Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                ? theme.colorScheme.primary.withOpacity(0.1)
                                                : theme.colorScheme.surfaceVariant.withOpacity(0.3),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: SvgPicture.asset(
                                              instrument.iconPath,
                                              width: 24,
                                              height: 24,
                                              colorFilter: ColorFilter.mode(
                                                isSelected
                                                  ? theme.colorScheme.primary
                                                  : theme.colorScheme.onSurfaceVariant,
                                                BlendMode.srcIn,
                                              ),
                                            ),
                                          ),
                                          title: Text(
                                            _getInstrumentName(instrument, l10n),
                                            style: theme.textTheme.bodyLarge?.copyWith(
                                              color: isSelected
                                                ? theme.colorScheme.primary
                                                : theme.colorScheme.onSurface,
                                              fontWeight: isSelected ? FontWeight.bold : null,
                                            ),
                                          ),
                                          trailing: isSelected
                                            ? Icon(
                                                Icons.check_circle,
                                                color: theme.colorScheme.primary,
                                              )
                                            : null,
                                          onTap: () {
                                            _onInstrumentChanged(instrument);
                                            Navigator.pop(context);
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                  SafeArea(
                                    child: Container(
                                      height: 8,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _getInstrumentName(_selectedInstrument, l10n),
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.arrow_drop_down,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
} 