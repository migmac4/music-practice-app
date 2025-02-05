import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../widgets/dashboard_card.dart';
import '../data/data_manager.dart';
import '../services/storage_service.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  final Function(bool) onThemeChanged;
  final Function(String) onLocaleChanged;
  final bool isDarkMode;
  final Locale currentLocale;
  
  const HomeScreen({
    super.key,
    required this.onThemeChanged,
    required this.onLocaleChanged,
    required this.isDarkMode,
    required this.currentLocale,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsScreen(
          onThemeChanged: widget.onThemeChanged,
          onLocaleChanged: widget.onLocaleChanged,
          isDarkMode: widget.isDarkMode,
          currentLocale: widget.currentLocale,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _openSettings,
            tooltip: l10n.settings,
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _getDashboardStats(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

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