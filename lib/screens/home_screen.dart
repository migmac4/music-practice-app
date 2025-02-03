import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../widgets/dashboard_card.dart';
import '../data/data_manager.dart';
import '../services/storage_service.dart';

class HomeScreen extends StatefulWidget {
  final Function(bool) onThemeChanged;
  final Function(String) onLocaleChanged;
  
  const HomeScreen({
    super.key,
    required this.onThemeChanged,
    required this.onLocaleChanged,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _storageService = NativeStorageService();
  bool _isDarkMode = false;
  Locale _currentLocale = const Locale('en');

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    try {
      final savedLocale = await _storageService.getLocale();
      if (savedLocale != null && mounted) {
        setState(() {
          _currentLocale = Locale(savedLocale);
        });
      }
    } catch (e) {
      // Error handling
    }
  }

  Future<void> _changeLocale(String languageCode) async {
    try {
      setState(() {
        _currentLocale = Locale(languageCode);
      });
      await _storageService.saveLocale(languageCode);
      widget.onLocaleChanged(languageCode);
    } catch (e) {
      // Error handling
    }
  }

  Future<void> _loadThemeMode() async {
    try {
      final savedMode = await _storageService.getThemeMode();
      if (savedMode != null && mounted) {
        setState(() {
          _isDarkMode = savedMode;
        });
      }
    } catch (e) {
      // Error handling
    }
  }

  Future<void> _toggleTheme() async {
    try {
      final newMode = !_isDarkMode;
      setState(() {
        _isDarkMode = newMode;
      });
      await _storageService.saveThemeMode(newMode);
      widget.onThemeChanged(newMode);
    } catch (e) {
      // Error handling
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    
    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}h';
    } else {
      return '${minutes}m';
    }
  }

  Future<Map<String, dynamic>> _getDashboardStats() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final practices = await DataManager.shared.getPractices();
    
    // Filter practices for today
    final todayPractices = practices.where((practice) {
      return practice.startTime.isAfter(startOfDay) && 
             practice.startTime.isBefore(endOfDay);
    }).toList();

    // Calculate total practice time
    final totalDuration = todayPractices.fold<Duration>(
      Duration.zero,
      (total, practice) => total + Duration(seconds: practice.duration.toInt()),
    );

    // Count unique exercises practiced
    final uniqueExercises = todayPractices.map((p) => p.exercise?.id).toSet();
    
    return {
      'totalTime': totalDuration,
      'exerciseCount': uniqueExercises.length,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            icon: Icon(
              _isDarkMode ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: _toggleTheme,
            tooltip: _isDarkMode ? l10n.lightMode : l10n.darkMode,
          ),
          PopupMenuButton<String>(
            onSelected: _changeLocale,
            tooltip: l10n.language,
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: 'en',
                  child: Row(
                    children: [
                      if (_currentLocale.languageCode == 'en')
                        const Icon(Icons.check, size: 18),
                      if (_currentLocale.languageCode == 'en')
                        const SizedBox(width: 8),
                      const Text('English'),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'pt',
                  child: Row(
                    children: [
                      if (_currentLocale.languageCode == 'pt')
                        const Icon(Icons.check, size: 18),
                      if (_currentLocale.languageCode == 'pt')
                        const SizedBox(width: 8),
                      const Text('Português'),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _getDashboardStats(),
        builder: (context, snapshot) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Dashboard Cards
                if (!snapshot.hasError) ...[
                  Row(
                    children: [
                      Expanded(
                        child: DashboardCard(
                          icon: Icons.timer_outlined,
                          title: l10n.dashboardTotalTime,
                          value: snapshot.hasData
                              ? _formatDuration(snapshot.data!['totalTime'] as Duration)
                              : '0m',
                          iconColor: Colors.blue,
                          iconBackgroundColor: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DashboardCard(
                          icon: Icons.music_note_outlined,
                          title: l10n.dashboardExercises,
                          value: snapshot.hasData
                              ? (snapshot.data!['exerciseCount'] as int).toString()
                              : '0',
                          iconColor: Colors.orange,
                          iconBackgroundColor: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
                
                // Practice Now Button
                FilledButton.icon(
                  onPressed: () {
                    // Practice now logic here
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: Text(l10n.practiceNow),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
} 