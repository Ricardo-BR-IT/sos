/// vault_database.dart
/// Drift Database Definition for storing Files and Chunks.

import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'vault_database.g.dart';

// Tables
class StoredFiles extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get fileName => text()();
  TextColumn get fileHash => text()(); // Merkle Root or Full SHA256
  IntColumn get totalChunks => integer()();
  BoolColumn get isComplete => boolean().withDefault(const Constant(false))();
}

class FileChunks extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get fileId => integer().references(StoredFiles, #id)();
  IntColumn get chunkIndex => integer()(); // 0, 1, 2...
  BlobColumn get data => blob()();
  TextColumn get hash => text()();
}

class PendingMessages extends Table {
  TextColumn get id => text().clientDefault(() =>
      DateTime.now().millisecondsSinceEpoch.toString() +
      '_' +
      (DateTime.now().microsecond % 100).toString())();
  TextColumn get senderId => text()(); // Sender node ID
  TextColumn get recipientId => text().nullable()(); // Null for broadcast
  TextColumn get type => text()(); // SosPacketType as string
  TextColumn get payload => text()(); // JSON encoded payload
  IntColumn get ttl => integer().withDefault(const Constant(8))();
  DateTimeColumn get createdAt =>
      dateTime().clientDefault(() => DateTime.now())();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastRetryAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [StoredFiles, FileChunks, PendingMessages])
class VaultDatabase extends _$VaultDatabase {
  VaultDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  Future<int> insertFile(StoredFilesCompanion file) =>
      into(storedFiles).insert(file);

  Future<void> insertChunk(FileChunksCompanion chunk) =>
      into(fileChunks).insert(chunk);

  Future<List<FileChunk>> getChunksForFile(int fileId) => (select(fileChunks)
        ..where((t) => t.fileId.equals(fileId))
        ..orderBy([(t) => OrderingTerm(expression: t.chunkIndex)]))
      .get();

  // Pending Messages operations
  Future<int> addPendingMessage(PendingMessagesCompanion message) =>
      into(pendingMessages).insert(message);

  Future<List<PendingMessage>> getPendingMessages() => (select(pendingMessages)
        ..orderBy([(t) => OrderingTerm(expression: t.createdAt)]))
      .get();

  Future<List<PendingMessage>> getPendingMessagesForRecipient(
          String? recipientId) =>
      (select(pendingMessages)
            ..where((t) => recipientId == null
                ? t.recipientId.isNull()
                : t.recipientId.equals(recipientId))
            ..orderBy([(t) => OrderingTerm(expression: t.createdAt)]))
          .get();

  Future<void> removePendingMessage(String messageId) =>
      (delete(pendingMessages)..where((t) => t.id.equals(messageId))).go();

  Future<void> updatePendingMessageRetry(String messageId, int retryCount) =>
      (update(pendingMessages)..where((t) => t.id.equals(messageId)))
          .write(PendingMessagesCompanion(
        retryCount: Value(retryCount),
        lastRetryAt: Value(DateTime.now()),
      ));
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'sos_vault.sqlite'));
    return NativeDatabase(file);
  });
}
