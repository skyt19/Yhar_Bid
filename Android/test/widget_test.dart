// test/widget_test.dart
//
// Tests that run without Firebase, GetStorage or a .env file.
// Run with: flutter test

import 'package:flutter_test/flutter_test.dart';
import 'package:yharbid_android/main.dart';
import 'package:yharbid_android/translations/app_translations.dart';

/// Every route constant declared in AppRoutes.
/// When you add a route to AppRoutes, add it here too.
const List<String> _allRoutes = <String>[
  AppRoutes.home,
  AppRoutes.diagnostics,
  AppRoutes.test,
  AppRoutes.login,
  AppRoutes.roleSelection,
  AppRoutes.aiPersonality,
  AppRoutes.dashboard,
  AppRoutes.aiChatbot,
  AppRoutes.calendar,
  AppRoutes.settings,
  AppRoutes.advancedSettings,
  AppRoutes.tos,
  AppRoutes.proactiveTask,
  AppRoutes.habitTracker,
  AppRoutes.analytics,
  AppRoutes.notificationSettings,
];

void main() {
  group('AppRoutes', () {
    test('home route is the root path', () {
      expect(AppRoutes.home, '/');
    });

    test('every route starts with a slash', () {
      for (final String route in _allRoutes) {
        expect(route.startsWith('/'), isTrue, reason: 'Bad route: $route');
      }
    });

    test('route paths are unique', () {
      expect(
        _allRoutes.toSet().length,
        _allRoutes.length,
        reason: 'Two routes share the same path',
      );
    });
  });

  group('AppTranslations', () {
    test('provides the locales used in main.dart (th_TH and en_US)', () {
      final Map<String, Map<String, String>> keys = AppTranslations().keys;
      expect(keys.containsKey('th_TH'), isTrue);
      expect(keys.containsKey('en_US'), isTrue);
    });

    test('Thai and English define the same keys', () {
      final Map<String, Map<String, String>> keys = AppTranslations().keys;
      final Set<String> th = keys['th_TH']!.keys.toSet();
      final Set<String> en = keys['en_US']!.keys.toSet();

      expect(
        th.difference(en),
        isEmpty,
        reason: 'Keys missing from English: ${th.difference(en)}',
      );
      expect(
        en.difference(th),
        isEmpty,
        reason: 'Keys missing from Thai: ${en.difference(th)}',
      );
    });

    test('no translation value is empty', () {
      final Map<String, Map<String, String>> keys = AppTranslations().keys;
      keys.forEach((String locale, Map<String, String> map) {
        map.forEach((String key, String value) {
          expect(value.trim().isNotEmpty, isTrue,
              reason: 'Empty value for "$key" in $locale');
        });
      });
    });
  });

}
