import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../widgets/dashboard_card.dart';
import '../data/data_manager.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

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

    return FutureBuilder<Map<String, dynamic>>(
      future: _getDashboardStats(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        final stats = snapshot.data!;
        final totalTime = stats['totalTime'] as Duration;
        final exerciseCount = stats['exerciseCount'] as int;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: DashboardCard(
                      icon: Icons.timer_outlined,
                      title: l10n.dashboardTotalPracticeTime,
                      value: _formatDuration(totalTime),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DashboardCard(
                      icon: Icons.music_note_outlined,
                      title: l10n.dashboardExerciseCount,
                      value: exerciseCount.toString(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
} 