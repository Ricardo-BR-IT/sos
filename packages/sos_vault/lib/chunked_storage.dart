/// chunked_storage.dart
/// PRODUCTION IMPLEMENTATION
/// Splits files into 64KB blocks and computes SHA-256 hashes.

import 'dart:io';
import 'package:crypto/crypto.dart';

const int CHUNK_SIZE = 64 * 1024; // 64 KB

class ChunkedStorage {
  /// Splits a File into chunks and returns a list of chunk data objects.
  /// Each object contains: index, data (bytes), hash.
  Stream<Map<String, dynamic>> splitFile(File file) async* {
    if (!await file.exists()) throw Exception("File not found");

    final len = await file.length();
    final openFile = await file.open();
    int index = 0;

    try {
      while (index * CHUNK_SIZE < len) {
        final bytes = await openFile.read(CHUNK_SIZE);
        final hash = sha256.convert(bytes).toString();

        yield {
          'index': index,
          'data': bytes,
          'hash': hash,
          'size': bytes.length
        };
        index++;
      }
    } finally {
      await openFile.close();
    }
  }

  /// Reassembles chunks into a destination file.
  /// [chunks] must be sorted by index.
  Future<File> reassembleFile(
      List<List<int>> sortedChunks, String destPath) async {
    final file = File(destPath);
    final sink = file.openWrite();

    for (var chunk in sortedChunks) {
      sink.add(chunk);
    }

    await sink.flush();
    await sink.close();
    return file;
  }
}
