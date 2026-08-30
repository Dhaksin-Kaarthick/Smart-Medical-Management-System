import 'package:flutter_test/flutter_test.dart';
import 'package:smart_medical_management/core/utils/validation_helper.dart';

void main() {
  group('ValidationHelper Tests', () {
    test('validateName correctly validates names', () {
      expect(ValidationHelper.validateName(''), isNotNull);
      expect(ValidationHelper.validateName('A'), isNotNull);
      expect(ValidationHelper.validateName('Arun Kumar'), isNull);
    });

    test('validateEmail correctly validates email formats', () {
      expect(ValidationHelper.validateEmail('invalid-email'), isNotNull);
      expect(ValidationHelper.validateEmail('test@'), isNotNull);
      expect(ValidationHelper.validateEmail('user@example.com'), isNull);
    });

    test('validatePassword validates minimum 6 chars', () {
      expect(ValidationHelper.validatePassword('123'), isNotNull);
      expect(ValidationHelper.validatePassword('password123'), isNull);
    });

    test('validateConfirmPassword checks match', () {
      expect(ValidationHelper.validateConfirmPassword('abc', 'xyz'), isNotNull);
      expect(ValidationHelper.validateConfirmPassword('pass', 'pass'), isNull);
    });
  });
}
