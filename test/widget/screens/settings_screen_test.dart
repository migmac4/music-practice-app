import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:music_practice_app/screens/settings_screen.dart';
import 'package:music_practice_app/services/storage_service.dart';
import 'package:music_practice_app/services/notification_service.dart';

void main() {
  group('SettingsScreen Widget Tests', () {
    late bool isDarkMode;
    late String currentLanguage;

    Widget createSettingsScreen({
      required Locale locale,
    }) {
      return MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: locale,
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
        home: SettingsScreen(
          onThemeChanged: (value) => isDarkMode = value,
          onLocaleChanged: (value) => currentLanguage = value,
          isDarkMode: isDarkMode,
          currentLocale: locale,
        ),
      );
    }

    setUp(() {
      isDarkMode = false;
      currentLanguage = 'en';
    });

    testWidgets('renders all settings sections', (tester) async {
      await tester.pumpWidget(
        createSettingsScreen(
          locale: const Locale('en'),
        ),
      );
      await tester.pumpAndSettle();

      // Verify section titles
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Language'), findsOneWidget);
      expect(find.text('Daily Reminder'), findsOneWidget);
      expect(find.text('Default Instrument'), findsOneWidget);
    });

    testWidgets('theme toggle works correctly', (tester) async {
      await tester.pumpWidget(
        createSettingsScreen(
          locale: const Locale('en'),
        ),
      );
      await tester.pumpAndSettle();

      // Find and tap the theme switch
      final switchFinder = find.byType(Switch).first;
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      expect(isDarkMode, isTrue);

      // Tap again to toggle back
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      expect(isDarkMode, isFalse);
    });

    testWidgets('language selection works correctly', (tester) async {
      await tester.pumpWidget(
        createSettingsScreen(
          locale: const Locale('en'),
        ),
      );
      await tester.pumpAndSettle();

      // Open language selection
      await tester.tap(find.text('Language').first);
      await tester.pumpAndSettle();

      // Select Portuguese
      await tester.tap(find.text('Português').first);
      await tester.pumpAndSettle();

      expect(currentLanguage, equals('pt'));
    });

    testWidgets('daily reminder time picker works', (tester) async {
      await tester.pumpWidget(
        createSettingsScreen(
          locale: const Locale('en'),
        ),
      );
      await tester.pumpAndSettle();

      // Enable daily reminder
      final reminderSwitch = find.byType(Switch).at(1);
      await tester.tap(reminderSwitch);
      await tester.pumpAndSettle();

      // Open time picker
      await tester.tap(find.text('Reminder Time').first);
      await tester.pumpAndSettle();

      // Verify time picker dialog is shown
      expect(find.byType(Dialog), findsOneWidget);
      expect(find.text('Select Time'), findsOneWidget);
    });

    testWidgets('instrument selection works', (tester) async {
      await tester.pumpWidget(
        createSettingsScreen(
          locale: const Locale('en'),
        ),
      );
      await tester.pumpAndSettle();

      // Open instrument selection
      await tester.tap(find.text('Default Instrument').first);
      await tester.pumpAndSettle();

      // Select Piano
      await tester.tap(find.text('Piano').first);
      await tester.pumpAndSettle();

      // Verify selection
      expect(find.text('Piano'), findsOneWidget);
    });

    testWidgets('shows correct translations in Portuguese', (tester) async {
      await tester.pumpWidget(
        createSettingsScreen(
          locale: const Locale('pt'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Configurações'), findsOneWidget);
      expect(find.text('Idioma'), findsOneWidget);
      expect(find.text('Lembrete Diário'), findsOneWidget);
      expect(find.text('Instrumento Padrão'), findsOneWidget);
    });

    testWidgets('handles back navigation', (tester) async {
      await tester.pumpWidget(
        createSettingsScreen(
          locale: const Locale('en'),
        ),
      );
      await tester.pumpAndSettle();

      // Tap back button
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      // Verify we've navigated back
      expect(find.byType(SettingsScreen), findsNothing);
    });

    testWidgets('persists settings changes', (tester) async {
      await tester.pumpWidget(
        createSettingsScreen(
          locale: const Locale('en'),
        ),
      );
      await tester.pumpAndSettle();

      // Change theme
      await tester.tap(find.byType(Switch).first);
      await tester.pumpAndSettle();
      expect(isDarkMode, isTrue);

      // Change language
      await tester.tap(find.text('Language').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Português').first);
      await tester.pumpAndSettle();
      expect(currentLanguage, equals('pt'));

      // Navigate away and back
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      
      // Rebuild with new settings
      await tester.pumpWidget(
        createSettingsScreen(
          locale: const Locale('pt'),
        ),
      );
      await tester.pumpAndSettle();

      // Verify settings persisted
      final switchWidget = tester.widget<Switch>(find.byType(Switch).first);
      expect(switchWidget.value, isTrue);
      expect(find.text('Configurações'), findsOneWidget);
    });
  });
} 