import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const languages = ['en', 'sw'];

Map<String, dynamic> load(String language) =>
    jsonDecode(File('assets/translations/$language.json').readAsStringSync())
        as Map<String, dynamic>;

// 'key'.tr(...), "key".tr(...) and tr('key'), with the key's quotes matched.
final _literalKey = RegExp(
  r'''(['"])((?:\\.|(?!\1).)*?)\1\s*\.tr\(|\btr\(\s*(['"])((?:\\.|(?!\3).)*?)\3''',
);

String _unescape(String raw) => raw.replaceAllMapped(
  RegExp(r'\\(.)'),
  (m) => switch (m[1]) {
    'n' => '\n',
    't' => '\t',
    _ => m[1]!,
  },
);

/// Every key the app translates as a literal, with where it is used.
Map<String, String> literalKeysInLib() {
  final keys = <String, String>{};
  final files = Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'));
  for (final file in files) {
    final source = file.readAsStringSync();
    for (final match in _literalKey.allMatches(source)) {
      final raw = match[2] ?? match[4]!;
      // Interpolated keys are built at runtime and can't be checked here.
      if (raw.contains(r'$')) continue;
      final line = '\n'.allMatches(source.substring(0, match.start)).length + 1;
      keys.putIfAbsent(_unescape(raw), () => '${file.path}:$line');
    }
  }
  return keys;
}

void main() {
  for (final language in languages) {
    group('$language.json', () {
      test('is a valid JSON object', () {
        expect(load(language), isA<Map<String, dynamic>>());
      });

      test('uses {} placeholders, the only kind easy_localization fills', () {
        final numbered = load(language).entries
            .where((e) => RegExp(r'\{\d+\}').hasMatch('${e.value}'))
            .map((e) => e.key);
        expect(numbered, isEmpty);
      });

      test('has every key the app uses', () {
        final translations = load(language);
        final used = literalKeysInLib();
        final missing = {
          for (final MapEntry(:key, :value) in used.entries)
            if (!translations.containsKey(key)) key: value,
        };
        expect(
          missing,
          isEmpty,
          reason: 'Add these keys to $language.json (key: first use)',
        );
        // Guards the scan itself against silently matching nothing.
        expect(used.length, greaterThan(300));
      });
    });
  }
}
