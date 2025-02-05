import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_practice_app/widgets/dashboard_card.dart';

void main() {
  group('DashboardCard Widget Tests', () {
    testWidgets('renders all elements correctly', (tester) async {
      // Arrange
      const title = 'Total Time';
      const value = '2:30h';
      const icon = Icons.timer;
      const iconColor = Colors.blue;
      const iconBackgroundColor = Colors.blue;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DashboardCard(
              icon: icon,
              title: title,
              value: value,
              iconColor: iconColor,
              iconBackgroundColor: iconBackgroundColor,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text(title), findsOneWidget);
      expect(find.text(value), findsOneWidget);
      expect(find.byIcon(icon), findsOneWidget);
    });

    testWidgets('applies correct styles', (tester) async {
      // Arrange
      const title = 'Exercises';
      const value = '5';
      const icon = Icons.music_note;
      const iconColor = Colors.orange;
      const iconBackgroundColor = Colors.orange;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Scaffold(
            body: DashboardCard(
              icon: icon,
              title: title,
              value: value,
              iconColor: iconColor,
              iconBackgroundColor: iconBackgroundColor,
            ),
          ),
        ),
      );

      // Assert
      final iconWidget = tester.widget<Icon>(find.byIcon(icon));
      expect(iconWidget.color, equals(iconColor));

      final containerFinder = find.ancestor(
        of: find.byIcon(icon),
        matching: find.byType(Container),
      );
      final container = tester.widget<Container>(containerFinder);
      final decoration = container.decoration as BoxDecoration;
      expect(
        decoration.color,
        equals(iconBackgroundColor.withOpacity(0.2)),
      );
    });

    testWidgets('adapts to dark theme', (tester) async {
      // Arrange
      const title = 'Practice Time';
      const value = '1:00h';
      const icon = Icons.timer;
      const iconColor = Colors.blue;
      const iconBackgroundColor = Colors.blue;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: DashboardCard(
              icon: icon,
              title: title,
              value: value,
              iconColor: iconColor,
              iconBackgroundColor: iconBackgroundColor,
            ),
          ),
        ),
      );

      // Assert
      final card = find.byType(Card);
      final cardWidget = tester.widget<Card>(card);
      expect(cardWidget.color, equals(ThemeData.dark().colorScheme.surface));
    });

    testWidgets('handles long text gracefully', (tester) async {
      // Arrange
      const longTitle = 'Very Very Very Long Title That Should Still Look Good';
      const longValue = '999:59h';
      const icon = Icons.timer;
      const iconColor = Colors.blue;
      const iconBackgroundColor = Colors.blue;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200, // Constrain width to test overflow behavior
              child: DashboardCard(
                icon: icon,
                title: longTitle,
                value: longValue,
                iconColor: iconColor,
                iconBackgroundColor: iconBackgroundColor,
              ),
            ),
          ),
        ),
      );

      // Assert
      expect(find.text(longTitle), findsOneWidget);
      expect(find.text(longValue), findsOneWidget);
      
      // Ensure no errors from overflow
      expect(tester.takeException(), isNull);
    });
  });
} 