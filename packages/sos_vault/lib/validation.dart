/// validation.dart
/// Hash + Ed25519 signature verification using libsodium.

import 'dart:convert';

import 'package:sodium_libs/sodium_libs.dart';

class Validation {
  Future<bool> verify({
    required List<int> data,
    required String signature,
    required String publicKey,
  }) async {
    final sodium = await SodiumInit.init();
    final sig = base64Decode(signature);
    final pk = base64Decode(publicKey);
    return sodium.crypto.sign.verifyDetached(
      message: Uint8List.fromList(data),
      signature: sig,
      publicKey: pk,
    );
  }
}
