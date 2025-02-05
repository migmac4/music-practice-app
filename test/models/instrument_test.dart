import 'package:flutter_test/flutter_test.dart';
import 'package:music_practice_app/models/instrument.dart';

void main() {
  group('Instrument Tests', () {
    test('Instrument icon paths are correctly formatted', () {
      // Test a few representative instruments
      expect(Instrument.acousticGuitar.iconPath, 'assets/icons/instruments/acousticGuitar.svg');
      expect(Instrument.electricGuitar.iconPath, 'assets/icons/instruments/electricGuitar.svg');
      expect(Instrument.piano.iconPath, 'assets/icons/instruments/piano.svg');
      expect(Instrument.violin.iconPath, 'assets/icons/instruments/violin.svg');
    });

    test('All instruments have corresponding icon files', () {
      // Test all instruments
      for (final instrument in Instrument.values) {
        expect(
          instrument.iconPath,
          matches(RegExp(r'^assets/icons/instruments/[a-zA-Z]+\.svg$')),
          reason: '${instrument.name} should have a valid icon path',
        );
      }
    });

    test('Instrument names are in camelCase', () {
      for (final instrument in Instrument.values) {
        expect(
          instrument.name,
          matches(r'^[a-z][a-zA-Z]*$'),
          reason: '${instrument.name} should be in camelCase',
        );
      }
    });
  });
} 