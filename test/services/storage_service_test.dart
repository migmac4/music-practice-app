import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_practice_app/services/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late NativeStorageService storageService;
  const channel = MethodChannel('com.miguelmacedo.music_practice_app/storage');

  setUp(() {
    storageService = NativeStorageService();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        switch (methodCall.method) {
          case 'saveThemeMode':
            return null;
          case 'getThemeMode':
            return true;
          case 'saveLocale':
            return null;
          case 'getLocale':
            return 'pt';
          case 'saveDefaultInstrument':
            return null;
          case 'getDefaultInstrument':
            return 'violin';
          case 'saveDailyReminder':
            return null;
          case 'getDailyReminder':
            return {
              'enabled': true,
              'hour': 9,
              'minute': 30,
            };
          default:
            throw PlatformException(
              code: 'UNSUPPORTED_METHOD',
              message: '${methodCall.method} is not supported',
            );
        }
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      null,
    );
  });

  group('Theme Mode Tests', () {
    test('saveThemeMode should complete without error', () async {
      await expectLater(
        storageService.saveThemeMode(true),
        completes,
      );
    });

    test('getThemeMode should return mocked value', () async {
      final result = await storageService.getThemeMode();
      expect(result, isTrue);
    });
  });

  group('Locale Tests', () {
    test('saveLocale should complete without error', () async {
      await expectLater(
        storageService.saveLocale('pt'),
        completes,
      );
    });

    test('getLocale should return mocked value', () async {
      final result = await storageService.getLocale();
      expect(result, equals('pt'));
    });
  });

  group('Default Instrument Tests', () {
    test('saveDefaultInstrument should complete without error', () async {
      await expectLater(
        storageService.saveDefaultInstrument('violin'),
        completes,
      );
    });

    test('getDefaultInstrument should return mocked value', () async {
      final result = await storageService.getDefaultInstrument();
      expect(result, equals('violin'));
    });
  });

  group('Daily Reminder Tests', () {
    test('saveDailyReminder should complete without error', () async {
      await expectLater(
        storageService.saveDailyReminder(true, 9, 30),
        completes,
      );
    });

    test('getDailyReminder should return mocked value', () async {
      final result = await storageService.getDailyReminder();
      expect(result, isNotNull);
      expect(result!['enabled'], isTrue);
      expect(result['hour'], equals(9));
      expect(result['minute'], equals(30));
    });
  });

  group('Error Handling Tests', () {
    setUp(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        channel,
        (MethodCall methodCall) async {
          throw PlatformException(
            code: 'ERROR',
            message: 'Test error',
          );
        },
      );
    });

    test('getThemeMode should return null on error', () async {
      final result = await storageService.getThemeMode();
      expect(result, isNull);
    });

    test('getLocale should return null on error', () async {
      final result = await storageService.getLocale();
      expect(result, isNull);
    });

    test('getDefaultInstrument should return null on error', () async {
      final result = await storageService.getDefaultInstrument();
      expect(result, isNull);
    });

    test('getDailyReminder should return null on error', () async {
      final result = await storageService.getDailyReminder();
      expect(result, isNull);
    });
  });

  group('Method Channel Arguments Tests', () {
    test('saveThemeMode should send correct arguments', () async {
      const isDarkMode = true;
      
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        channel,
        (MethodCall methodCall) async {
          expect(methodCall.method, equals('saveThemeMode'));
          expect(methodCall.arguments, isA<Map>());
          expect(methodCall.arguments['isDarkMode'], equals(isDarkMode));
          return null;
        },
      );

      await storageService.saveThemeMode(isDarkMode);
    });

    test('saveLocale should send correct arguments', () async {
      const locale = 'pt-BR';
      
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        channel,
        (MethodCall methodCall) async {
          expect(methodCall.method, equals('saveLocale'));
          expect(methodCall.arguments, isA<Map>());
          expect(methodCall.arguments['locale'], equals(locale));
          return null;
        },
      );

      await storageService.saveLocale(locale);
    });

    test('saveDefaultInstrument should send correct arguments', () async {
      const instrumentId = 'violin';
      
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        channel,
        (MethodCall methodCall) async {
          expect(methodCall.method, equals('saveDefaultInstrument'));
          expect(methodCall.arguments, isA<Map>());
          expect(methodCall.arguments['instrumentId'], equals(instrumentId));
          return null;
        },
      );

      await storageService.saveDefaultInstrument(instrumentId);
    });

    test('saveDailyReminder should send correct arguments', () async {
      const enabled = true;
      const hour = 9;
      const minute = 30;
      
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        channel,
        (MethodCall methodCall) async {
          expect(methodCall.method, equals('saveDailyReminder'));
          expect(methodCall.arguments, isA<Map>());
          expect(methodCall.arguments['enabled'], equals(enabled));
          expect(methodCall.arguments['hour'], equals(hour));
          expect(methodCall.arguments['minute'], equals(minute));
          return null;
        },
      );

      await storageService.saveDailyReminder(enabled, hour, minute);
    });

    test('saveDailyReminder should validate hour range', () async {
      expect(
        () => storageService.saveDailyReminder(true, 24, 30),
        throwsA(isA<ArgumentError>().having(
          (error) => error.message,
          'message',
          'Hour must be between 0 and 23',
        )),
      );

      expect(
        () => storageService.saveDailyReminder(true, -1, 30),
        throwsA(isA<ArgumentError>().having(
          (error) => error.message,
          'message',
          'Hour must be between 0 and 23',
        )),
      );
    });

    test('saveDailyReminder should validate minute range', () async {
      expect(
        () => storageService.saveDailyReminder(true, 9, 60),
        throwsA(isA<ArgumentError>().having(
          (error) => error.message,
          'message',
          'Minute must be between 0 and 59',
        )),
      );

      expect(
        () => storageService.saveDailyReminder(true, 9, -1),
        throwsA(isA<ArgumentError>().having(
          (error) => error.message,
          'message',
          'Minute must be between 0 and 59',
        )),
      );
    });
  });

  group('Response Type Tests', () {
    setUp(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        channel,
        (MethodCall methodCall) async {
          switch (methodCall.method) {
            case 'getThemeMode':
              return 'invalid_type'; // Retorna string em vez de bool
            case 'getLocale':
              return 42; // Retorna número em vez de string
            case 'getDefaultInstrument':
              return true; // Retorna bool em vez de string
            case 'getDailyReminder':
              return 'not_a_map'; // Retorna string em vez de map
            default:
              return null;
          }
        },
      );
    });

    test('getThemeMode should handle invalid response type', () async {
      final result = await storageService.getThemeMode();
      expect(result, isNull);
    });

    test('getLocale should handle invalid response type', () async {
      final result = await storageService.getLocale();
      expect(result, isNull);
    });

    test('getDefaultInstrument should handle invalid response type', () async {
      final result = await storageService.getDefaultInstrument();
      expect(result, isNull);
    });

    test('getDailyReminder should handle invalid response type', () async {
      final result = await storageService.getDailyReminder();
      expect(result, isNull);
    });
  });
} 