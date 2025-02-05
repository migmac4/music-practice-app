import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:music_practice_app/screens/home_screen.dart';
import 'package:music_practice_app/widgets/dashboard_card.dart';

void main() {
  group('HomeScreen Widget Tests', () {
    Widget createHomeScreen({
      required bool isDarkMode,
      required Locale locale,
    }) {
      return MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: locale,
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
        home: HomeScreen(
          onThemeChanged: (_) {},
          onLocaleChanged: (_) {},
          isDarkMode: isDarkMode,
          currentLocale: locale,
        ),
      );
    }

    testWidgets('renders all main elements', (tester) async {
      await tester.pumpWidget(
        createHomeScreen(
          isDarkMode: false,
          locale: const Locale('en'),
        ),
      );

      // Verify app bar
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);

      // Verify dashboard cards
      expect(find.byType(DashboardCard), findsNWidgets(2));

      // Verify practice button
      expect(find.byType(FilledButton), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    });

    testWidgets('shows correct translations in English', (tester) async {
      await tester.pumpWidget(
        createHomeScreen(
          isDarkMode: false,
          locale: const Locale('en'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Music Practice'), findsOneWidget);
      expect(find.text('Practice Now'), findsOneWidget);
      expect(find.text('Total Time Today'), findsOneWidget);
      expect(find.text('Exercises Today'), findsOneWidget);
    });

    testWidgets('shows correct translations in Portuguese', (tester) async {
      await tester.pumpWidget(
        createHomeScreen(
          isDarkMode: false,
          locale: const Locale('pt'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Prática Musical'), findsOneWidget);
      expect(find.text('Praticar Agora'), findsOneWidget);
      expect(find.text('Tempo Total Hoje'), findsOneWidget);
      expect(find.text('Exercícios Hoje'), findsOneWidget);
    });

    testWidgets('opens settings screen when settings button is tapped',
        (tester) async {
      await tester.pumpWidget(
        createHomeScreen(
          isDarkMode: false,
          locale: const Locale('en'),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Verify settings screen is shown
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Language'), findsOneWidget);
      expect(find.text('Daily Reminder'), findsOneWidget);
    });

    testWidgets('adapts to dark theme', (tester) async {
      await tester.pumpWidget(
        createHomeScreen(
          isDarkMode: true,
          locale: const Locale('en'),
        ),
      );
      await tester.pumpAndSettle();

      // Verify dark theme colors are applied
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(
        scaffold.backgroundColor,
        equals(ThemeData.dark().scaffoldBackgroundColor),
      );
    });

    testWidgets('shows loading state while fetching data', (tester) async {
      await tester.pumpWidget(
        createHomeScreen(
          isDarkMode: false,
          locale: const Locale('en'),
        ),
      );

      // Verify loading state
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // After data is loaded
      await tester.pumpAndSettle();
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(DashboardCard), findsNWidgets(2));
    });

    testWidgets('handles practice button tap', (tester) async {
      await tester.pumpWidget(
        createHomeScreen(
          isDarkMode: false,
          locale: const Locale('en'),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      // TODO: Add verification for practice screen navigation
      // This will be implemented when the practice screen is created
    });
  });
} 