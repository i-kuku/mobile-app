import 'package:flutter_test/flutter_test.dart';
import 'package:ikuku/shared/utils/validators.dart';

void main() {
  group('validatePhoneNumber', () {
    test('accepts a 10 character number', () {
      expect(validatePhoneNumber('0712345678'), isTrue);
    });

    test('rejects null, empty and whitespace', () {
      expect(validatePhoneNumber(null), isFalse);
      expect(validatePhoneNumber(''), isFalse);
      expect(validatePhoneNumber('   '), isFalse);
    });

    test('rejects numbers that are too short or too long', () {
      expect(validatePhoneNumber('071234567'), isFalse);
      expect(validatePhoneNumber('07123456789'), isFalse);
    });
  });

  group('requiredField', () {
    test('returns null for a non-empty value', () {
      expect(requiredField('hello'), isNull);
    });

    test('uses a default field name', () {
      expect(requiredField(null), 'This field is required');
      expect(requiredField(''), 'This field is required');
    });

    test('uses the supplied field name', () {
      expect(requiredField('', fieldName: 'Name'), 'Name is required');
    });
  });

  group('minLength', () {
    test('returns null when long enough or null', () {
      expect(minLength('abcd', 4), isNull);
      expect(minLength(null, 4), isNull);
    });

    test('returns an error when too short', () {
      expect(minLength('ab', 4), 'This field must be at least 4 characters');
      expect(
        minLength('ab', 3, fieldName: 'Farm'),
        'Farm must be at least 3 characters',
      );
    });
  });

  group('emailValidator', () {
    test('requires a value', () {
      expect(emailValidator(null), 'Email is required');
      expect(
        emailValidator('', fieldName: 'Work email'),
        'Work email is required',
      );
    });

    test('accepts valid emails', () {
      expect(emailValidator('farmer@ikuku.co.ke'), isNull);
      expect(emailValidator('first.last-name@example.com'), isNull);
      expect(emailValidator('farmer+eggs@gmail.com'), isNull);
      expect(emailValidator('info@kuku.online'), isNull);
      expect(emailValidator('info@shamba.agency'), isNull);
    });

    test('rejects invalid emails', () {
      for (final email in [
        'farmer',
        'farmer@',
        '@ikuku.com',
        'a@b',
        'a b@c.com',
      ]) {
        expect(emailValidator(email), 'Enter a valid email', reason: email);
      }
    });
  });

  group('passwordValidator', () {
    test('requires a value', () {
      expect(passwordValidator(null), 'Password is required');
      expect(passwordValidator('', fieldName: 'PIN'), 'PIN is required');
    });

    test('enforces the default minimum of 6', () {
      expect(
        passwordValidator('12345'),
        'Password must be at least 6 characters',
      );
      expect(passwordValidator('123456'), isNull);
    });

    test('respects a custom minimum', () {
      expect(
        passwordValidator('1234567', minLength: 8),
        'Password must be at least 8 characters',
      );
      expect(passwordValidator('12345678', minLength: 8), isNull);
    });
  });
}
