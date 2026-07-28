import 'package:agriguard/core/security/password_hasher.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('password hashes use unique salts and verify correctly', () {
    final hasher = PasswordHasher();
    final first = hasher.hash('strong-password');
    final second = hasher.hash('strong-password');

    expect(first.salt, isNot(second.salt));
    expect(first.hash, isNot(second.hash));
    expect(
      hasher.verify(
        password: 'strong-password',
        expectedHash: first.hash,
        salt: first.salt,
      ),
      isTrue,
    );
    expect(
      hasher.verify(
        password: 'wrong-password',
        expectedHash: first.hash,
        salt: first.salt,
      ),
      isFalse,
    );
  });
}
