import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const languages = ['en', 'sw'];

Map<String, dynamic> load(String language) =>
    jsonDecode(File('assets/translations/$language.json').readAsStringSync())
        as Map<String, dynamic>;

// 'key'.tr(...), "key".plural(...) and tr('key'), with the key's quotes
// matched.
final _literalKey = RegExp(
  r'''(['"])((?:\\.|(?!\1).)*?)\1\s*\.(tr|plural)\(|\btr\(\s*(['"])((?:\\.|(?!\4).)*?)\4''',
);

String _unescape(String raw) => raw.replaceAllMapped(
  RegExp(r'\\(.)'),
  (m) => switch (m[1]) {
    'n' => '\n',
    't' => '\t',
    _ => m[1]!,
  },
);

typedef KeyUse = ({String where, bool plural});

/// Every key the app translates as a literal, with where it is first used
/// and whether that's with plural(), which needs one/other forms.
Map<String, KeyUse> literalKeysInLib() {
  final keys = <String, KeyUse>{};
  final files = Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'));
  for (final file in files) {
    final source = file.readAsStringSync();
    for (final match in _literalKey.allMatches(source)) {
      final raw = match[2] ?? match[5]!;
      // Interpolated keys are built at runtime and can't be checked here.
      if (raw.contains(r'$')) continue;
      final line = '\n'.allMatches(source.substring(0, match.start)).length + 1;
      keys.putIfAbsent(
        _unescape(raw),
        () => (where: '${file.path}:$line', plural: match[3] == 'plural'),
      );
    }
  }
  return keys;
}

bool _hasPluralForms(Object? value) =>
    value is Map && value['one'] is String && value['other'] is String;

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

      test('has every key the app uses, in the form it uses it', () {
        final translations = load(language);
        final used = literalKeysInLib();
        final missing = {
          for (final MapEntry(:key, value: use) in used.entries)
            if (use.plural
                ? !_hasPluralForms(translations[key])
                : translations[key] is! String)
              key: use.where,
        };
        expect(
          missing,
          isEmpty,
          reason:
              'Add these keys to $language.json, as text for tr() or as '
              'one/other forms for plural() (key: first use)',
        );
        // Guards the scan itself against silently matching nothing.
        expect(used.length, greaterThan(300));
        expect(used.values.where((use) => use.plural), isNotEmpty);
      });
    });
  }
}
