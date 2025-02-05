import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_practice_app/widgets/custom_time_picker.dart';

void main() {
  group('CustomTimePicker Widget Tests', () {
    testWidgets('renders initial time correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(alwaysUse24HourFormat: true),
            child: CustomTimePicker(
              initialTime: const TimeOfDay(hour: 14, minute: 30),
              onTimeChanged: (_) {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final hourText = find.byWidgetPredicate(
        (widget) => widget is Text && 
          widget.data == '14' && 
          (widget.style?.fontSize == 24 || widget.style?.fontWeight == FontWeight.bold),
      );

      final minuteText = find.byWidgetPredicate(
        (widget) => widget is Text && 
          widget.data == '30' && 
          (widget.style?.fontSize == 24 || widget.style?.fontWeight == FontWeight.bold),
      );

      expect(hourText, findsOneWidget);
      expect(minuteText, findsOneWidget);
    });

    testWidgets('handles 12-hour format correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(alwaysUse24HourFormat: false),
            child: CustomTimePicker(
              initialTime: const TimeOfDay(hour: 14, minute: 30),
              onTimeChanged: (_) {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final hourText = find.byWidgetPredicate(
        (widget) => widget is Text && 
          widget.data == '2' && 
          (widget.style?.fontSize == 24 || widget.style?.fontWeight == FontWeight.bold),
      );

      final minuteText = find.byWidgetPredicate(
        (widget) => widget is Text && 
          widget.data == '30' && 
          (widget.style?.fontSize == 24 || widget.style?.fontWeight == FontWeight.bold),
      );

      expect(hourText, findsOneWidget);
      expect(minuteText, findsOneWidget);
      expect(find.text('PM'), findsOneWidget);
    });

    testWidgets('handles hour selection', (WidgetTester tester) async {
      TimeOfDay? selectedTime;
      
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(alwaysUse24HourFormat: true),
            child: CustomTimePicker(
              initialTime: const TimeOfDay(hour: 14, minute: 30),
              onTimeChanged: (time) => selectedTime = time,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final hourWheel = find.byType(ListWheelScrollView).first;
      await tester.drag(hourWheel, const Offset(0, 50));
      await tester.pumpAndSettle();

      expect(selectedTime, isNotNull);
      expect(selectedTime!.hour, isNot(14));
    });

    testWidgets('handles minute selection', (WidgetTester tester) async {
      TimeOfDay? selectedTime;
      
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(alwaysUse24HourFormat: true),
            child: CustomTimePicker(
              initialTime: const TimeOfDay(hour: 14, minute: 30),
              onTimeChanged: (time) => selectedTime = time,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final minuteWheel = find.byType(ListWheelScrollView).last;
      await tester.drag(minuteWheel, const Offset(0, 50));
      await tester.pumpAndSettle();

      expect(selectedTime, isNotNull);
      expect(selectedTime!.minute, isNot(30));
    });

    testWidgets('handles AM/PM toggle in 12-hour format', (WidgetTester tester) async {
      TimeOfDay? selectedTime;
      
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(alwaysUse24HourFormat: false),
            child: CustomTimePicker(
              initialTime: const TimeOfDay(hour: 14, minute: 30),
              onTimeChanged: (time) => selectedTime = time,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('PM'));
      await tester.pumpAndSettle();

      expect(find.text('AM'), findsOneWidget);
      expect(selectedTime?.period, equals(DayPeriod.am));
    });

    testWidgets('adapts to dark theme', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: CustomTimePicker(
            initialTime: const TimeOfDay(hour: 14, minute: 30),
            onTimeChanged: (_) {},
          ),
        ),
      );

      await tester.pumpAndSettle();

      final hourText = find.byWidgetPredicate(
        (widget) => widget is Text && 
          widget.data == '14' && 
          (widget.style?.fontSize == 24 || widget.style?.fontWeight == FontWeight.bold),
      ).evaluate().first.widget as Text;

      expect(hourText.style?.color, equals(Colors.white));
    });

    testWidgets('updates when new initial time is provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(alwaysUse24HourFormat: true),
            child: CustomTimePicker(
              initialTime: const TimeOfDay(hour: 14, minute: 30),
              onTimeChanged: (_) {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(alwaysUse24HourFormat: true),
            child: CustomTimePicker(
              initialTime: const TimeOfDay(hour: 15, minute: 45),
              onTimeChanged: (_) {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final hourText = find.byWidgetPredicate(
        (widget) => widget is Text && 
          widget.data == '15' && 
          (widget.style?.fontSize == 24 || widget.style?.fontWeight == FontWeight.bold),
      );

      final minuteText = find.byWidgetPredicate(
        (widget) => widget is Text && 
          widget.data == '45' && 
          (widget.style?.fontSize == 24 || widget.style?.fontWeight == FontWeight.bold),
      );

      expect(hourText, findsOneWidget);
      expect(minuteText, findsOneWidget);
    });
  });
} 