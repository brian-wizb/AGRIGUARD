import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

class PasswordDigest {
  const PasswordDigest({required this.hash, required this.salt});

  final String hash;
  final String salt;
}

class PasswordHasher {
  PasswordHasher({Random? secureRandom})
    : _secureRandom = secureRandom ?? Random.secure();

  final Random _secureRandom;

  PasswordDigest hash(String password) {
    final saltBytes = List<int>.generate(16, (_) => _secureRandom.nextInt(256));
    final salt = base64UrlEncode(saltBytes);
    return PasswordDigest(hash: _derive(password, salt), salt: salt);
  }

  bool verify({
    required String password,
    required String expectedHash,
    required String salt,
  }) {
    final actual = _derive(password, salt);
    if (actual.length != expectedHash.length) return false;
    var difference = 0;
    for (var index = 0; index < actual.length; index++) {
      difference |= actual.codeUnitAt(index) ^ expectedHash.codeUnitAt(index);
    }
    return difference == 0;
  }

  String _derive(String password, String salt) {
    List<int> bytes = utf8.encode('$salt:$password');
    for (var round = 0; round < 12000; round++) {
      bytes = sha256.convert(bytes).bytes;
    }
    return base64UrlEncode(bytes);
  }
}
