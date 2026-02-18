// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vault_database.dart';

// ignore_for_file: type=lint
class $StoredFilesTable extends StoredFiles with TableInfo<$StoredFilesTable, StoredFile>{
@override final GeneratedDatabase attachedDatabase;
final String? _alias;
$StoredFilesTable(this.attachedDatabase, [this._alias]);
static const VerificationMeta _idMeta = const VerificationMeta('id');
@override
late final GeneratedColumn<int> id = GeneratedColumn<int>('id', aliasedName, false, hasAutoIncrement: true, type: DriftSqlType.int, requiredDuringInsert: false, defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
static const VerificationMeta _fileNameMeta = const VerificationMeta('fileName');
@override
late final GeneratedColumn<String> fileName = GeneratedColumn<String>('file_name', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
static const VerificationMeta _fileHashMeta = const VerificationMeta('fileHash');
@override
late final GeneratedColumn<String> fileHash = GeneratedColumn<String>('file_hash', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
static const VerificationMeta _totalChunksMeta = const VerificationMeta('totalChunks');
@override
late final GeneratedColumn<int> totalChunks = GeneratedColumn<int>('total_chunks', aliasedName, false, type: DriftSqlType.int, requiredDuringInsert: true);
static const VerificationMeta _isCompleteMeta = const VerificationMeta('isComplete');
@override
late final GeneratedColumn<bool> isComplete = GeneratedColumn<bool>('is_complete', aliasedName, false, type: DriftSqlType.bool, requiredDuringInsert: false, defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("is_complete" IN (0, 1))'), defaultValue: const Constant(false));
@override
List<GeneratedColumn> get $columns => [id, fileName, fileHash, totalChunks, isComplete];
@override
String get aliasedName => _alias ?? actualTableName;
@override
String get actualTableName => $name;
static const String $name = 'stored_files';
@override
VerificationContext validateIntegrity(Insertable<StoredFile> instance, {bool isInserting = false}) {
final context = VerificationContext();
final data = instance.toColumns(true);
if (data.containsKey('id')) {
context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));}if (data.containsKey('file_name')) {
context.handle(_fileNameMeta, fileName.isAcceptableOrUnknown(data['file_name']!, _fileNameMeta));} else if (isInserting) {
context.missing(_fileNameMeta);
}
if (data.containsKey('file_hash')) {
context.handle(_fileHashMeta, fileHash.isAcceptableOrUnknown(data['file_hash']!, _fileHashMeta));} else if (isInserting) {
context.missing(_fileHashMeta);
}
if (data.containsKey('total_chunks')) {
context.handle(_totalChunksMeta, totalChunks.isAcceptableOrUnknown(data['total_chunks']!, _totalChunksMeta));} else if (isInserting) {
context.missing(_totalChunksMeta);
}
if (data.containsKey('is_complete')) {
context.handle(_isCompleteMeta, isComplete.isAcceptableOrUnknown(data['is_complete']!, _isCompleteMeta));}return context;
}
@override
Set<GeneratedColumn> get $primaryKey => {id};
@override StoredFile map(Map<String, dynamic> data, {String? tablePrefix})  {
final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';return StoredFile(id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!, fileName: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}file_name'])!, fileHash: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}file_hash'])!, totalChunks: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}total_chunks'])!, isComplete: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}is_complete'])!, );
}
@override
$StoredFilesTable createAlias(String alias) {
return $StoredFilesTable(attachedDatabase, alias);}
}class StoredFile extends DataClass implements Insertable<StoredFile> 
{
final int id;
final String fileName;
final String fileHash;
final int totalChunks;
final bool isComplete;
const StoredFile({required this.id, required this.fileName, required this.fileHash, required this.totalChunks, required this.isComplete});@override
Map<String, Expression> toColumns(bool nullToAbsent) {
final map = <String, Expression> {};map['id'] = Variable<int>(id);
map['file_name'] = Variable<String>(fileName);
map['file_hash'] = Variable<String>(fileHash);
map['total_chunks'] = Variable<int>(totalChunks);
map['is_complete'] = Variable<bool>(isComplete);
return map; 
}
StoredFilesCompanion toCompanion(bool nullToAbsent) {
return StoredFilesCompanion(id: Value(id),fileName: Value(fileName),fileHash: Value(fileHash),totalChunks: Value(totalChunks),isComplete: Value(isComplete),);
}
factory StoredFile.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
serializer ??= driftRuntimeOptions.defaultSerializer;
return StoredFile(id: serializer.fromJson<int>(json['id']),fileName: serializer.fromJson<String>(json['fileName']),fileHash: serializer.fromJson<String>(json['fileHash']),totalChunks: serializer.fromJson<int>(json['totalChunks']),isComplete: serializer.fromJson<bool>(json['isComplete']),);}
@override Map<String, dynamic> toJson({ValueSerializer? serializer}) {
serializer ??= driftRuntimeOptions.defaultSerializer;
return <String, dynamic>{
'id': serializer.toJson<int>(id),'fileName': serializer.toJson<String>(fileName),'fileHash': serializer.toJson<String>(fileHash),'totalChunks': serializer.toJson<int>(totalChunks),'isComplete': serializer.toJson<bool>(isComplete),};}StoredFile copyWith({int? id,String? fileName,String? fileHash,int? totalChunks,bool? isComplete}) => StoredFile(id: id ?? this.id,fileName: fileName ?? this.fileName,fileHash: fileHash ?? this.fileHash,totalChunks: totalChunks ?? this.totalChunks,isComplete: isComplete ?? this.isComplete,);StoredFile copyWithCompanion(StoredFilesCompanion data) {
return StoredFile(
id: data.id.present ? data.id.value : this.id,fileName: data.fileName.present ? data.fileName.value : this.fileName,fileHash: data.fileHash.present ? data.fileHash.value : this.fileHash,totalChunks: data.totalChunks.present ? data.totalChunks.value : this.totalChunks,isComplete: data.isComplete.present ? data.isComplete.value : this.isComplete,);
}
@override
String toString() {return (StringBuffer('StoredFile(')..write('id: $id, ')..write('fileName: $fileName, ')..write('fileHash: $fileHash, ')..write('totalChunks: $totalChunks, ')..write('isComplete: $isComplete')..write(')')).toString();}
@override
 int get hashCode => Object.hash(id, fileName, fileHash, totalChunks, isComplete);@override
bool operator ==(Object other) => identical(this, other) || (other is StoredFile && other.id == this.id && other.fileName == this.fileName && other.fileHash == this.fileHash && other.totalChunks == this.totalChunks && other.isComplete == this.isComplete);
}class StoredFilesCompanion extends UpdateCompanion<StoredFile> {
final Value<int> id;
final Value<String> fileName;
final Value<String> fileHash;
final Value<int> totalChunks;
final Value<bool> isComplete;
const StoredFilesCompanion({this.id = const Value.absent(),this.fileName = const Value.absent(),this.fileHash = const Value.absent(),this.totalChunks = const Value.absent(),this.isComplete = const Value.absent(),});
StoredFilesCompanion.insert({this.id = const Value.absent(),required String fileName,required String fileHash,required int totalChunks,this.isComplete = const Value.absent(),}): fileName = Value(fileName), fileHash = Value(fileHash), totalChunks = Value(totalChunks);
static Insertable<StoredFile> custom({Expression<int>? id, 
Expression<String>? fileName, 
Expression<String>? fileHash, 
Expression<int>? totalChunks, 
Expression<bool>? isComplete, 
}) {
return RawValuesInsertable({if (id != null)'id': id,if (fileName != null)'file_name': fileName,if (fileHash != null)'file_hash': fileHash,if (totalChunks != null)'total_chunks': totalChunks,if (isComplete != null)'is_complete': isComplete,});
}StoredFilesCompanion copyWith({Value<int>? id, Value<String>? fileName, Value<String>? fileHash, Value<int>? totalChunks, Value<bool>? isComplete}) {
return StoredFilesCompanion(id: id ?? this.id,fileName: fileName ?? this.fileName,fileHash: fileHash ?? this.fileHash,totalChunks: totalChunks ?? this.totalChunks,isComplete: isComplete ?? this.isComplete,);
}
@override
Map<String, Expression> toColumns(bool nullToAbsent) {
final map = <String, Expression> {};if (id.present) {
map['id'] = Variable<int>(id.value);}
if (fileName.present) {
map['file_name'] = Variable<String>(fileName.value);}
if (fileHash.present) {
map['file_hash'] = Variable<String>(fileHash.value);}
if (totalChunks.present) {
map['total_chunks'] = Variable<int>(totalChunks.value);}
if (isComplete.present) {
map['is_complete'] = Variable<bool>(isComplete.value);}
return map; 
}
@override
String toString() {return (StringBuffer('StoredFilesCompanion(')..write('id: $id, ')..write('fileName: $fileName, ')..write('fileHash: $fileHash, ')..write('totalChunks: $totalChunks, ')..write('isComplete: $isComplete')..write(')')).toString();}
}
class $FileChunksTable extends FileChunks with TableInfo<$FileChunksTable, FileChunk>{
@override final GeneratedDatabase attachedDatabase;
final String? _alias;
$FileChunksTable(this.attachedDatabase, [this._alias]);
static const VerificationMeta _idMeta = const VerificationMeta('id');
@override
late final GeneratedColumn<int> id = GeneratedColumn<int>('id', aliasedName, false, hasAutoIncrement: true, type: DriftSqlType.int, requiredDuringInsert: false, defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
static const VerificationMeta _fileIdMeta = const VerificationMeta('fileId');
@override
late final GeneratedColumn<int> fileId = GeneratedColumn<int>('file_id', aliasedName, false, type: DriftSqlType.int, requiredDuringInsert: true, defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES stored_files (id)'));
static const VerificationMeta _chunkIndexMeta = const VerificationMeta('chunkIndex');
@override
late final GeneratedColumn<int> chunkIndex = GeneratedColumn<int>('chunk_index', aliasedName, false, type: DriftSqlType.int, requiredDuringInsert: true);
static const VerificationMeta _dataMeta = const VerificationMeta('data');
@override
late final GeneratedColumn<Uint8List> data = GeneratedColumn<Uint8List>('data', aliasedName, false, type: DriftSqlType.blob, requiredDuringInsert: true);
static const VerificationMeta _hashMeta = const VerificationMeta('hash');
@override
late final GeneratedColumn<String> hash = GeneratedColumn<String>('hash', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
@override
List<GeneratedColumn> get $columns => [id, fileId, chunkIndex, data, hash];
@override
String get aliasedName => _alias ?? actualTableName;
@override
String get actualTableName => $name;
static const String $name = 'file_chunks';
@override
VerificationContext validateIntegrity(Insertable<FileChunk> instance, {bool isInserting = false}) {
final context = VerificationContext();
final data = instance.toColumns(true);
if (data.containsKey('id')) {
context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));}if (data.containsKey('file_id')) {
context.handle(_fileIdMeta, fileId.isAcceptableOrUnknown(data['file_id']!, _fileIdMeta));} else if (isInserting) {
context.missing(_fileIdMeta);
}
if (data.containsKey('chunk_index')) {
context.handle(_chunkIndexMeta, chunkIndex.isAcceptableOrUnknown(data['chunk_index']!, _chunkIndexMeta));} else if (isInserting) {
context.missing(_chunkIndexMeta);
}
if (data.containsKey('data')) {
context.handle(_dataMeta, this.data.isAcceptableOrUnknown(data['data']!, _dataMeta));} else if (isInserting) {
context.missing(_dataMeta);
}
if (data.containsKey('hash')) {
context.handle(_hashMeta, hash.isAcceptableOrUnknown(data['hash']!, _hashMeta));} else if (isInserting) {
context.missing(_hashMeta);
}
return context;
}
@override
Set<GeneratedColumn> get $primaryKey => {id};
@override FileChunk map(Map<String, dynamic> data, {String? tablePrefix})  {
final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';return FileChunk(id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!, fileId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}file_id'])!, chunkIndex: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}chunk_index'])!, data: attachedDatabase.typeMapping.read(DriftSqlType.blob, data['${effectivePrefix}data'])!, hash: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}hash'])!, );
}
@override
$FileChunksTable createAlias(String alias) {
return $FileChunksTable(attachedDatabase, alias);}
}class FileChunk extends DataClass implements Insertable<FileChunk> 
{
final int id;
final int fileId;
final int chunkIndex;
final Uint8List data;
final String hash;
const FileChunk({required this.id, required this.fileId, required this.chunkIndex, required this.data, required this.hash});@override
Map<String, Expression> toColumns(bool nullToAbsent) {
final map = <String, Expression> {};map['id'] = Variable<int>(id);
map['file_id'] = Variable<int>(fileId);
map['chunk_index'] = Variable<int>(chunkIndex);
map['data'] = Variable<Uint8List>(data);
map['hash'] = Variable<String>(hash);
return map; 
}
FileChunksCompanion toCompanion(bool nullToAbsent) {
return FileChunksCompanion(id: Value(id),fileId: Value(fileId),chunkIndex: Value(chunkIndex),data: Value(data),hash: Value(hash),);
}
factory FileChunk.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
serializer ??= driftRuntimeOptions.defaultSerializer;
return FileChunk(id: serializer.fromJson<int>(json['id']),fileId: serializer.fromJson<int>(json['fileId']),chunkIndex: serializer.fromJson<int>(json['chunkIndex']),data: serializer.fromJson<Uint8List>(json['data']),hash: serializer.fromJson<String>(json['hash']),);}
@override Map<String, dynamic> toJson({ValueSerializer? serializer}) {
serializer ??= driftRuntimeOptions.defaultSerializer;
return <String, dynamic>{
'id': serializer.toJson<int>(id),'fileId': serializer.toJson<int>(fileId),'chunkIndex': serializer.toJson<int>(chunkIndex),'data': serializer.toJson<Uint8List>(data),'hash': serializer.toJson<String>(hash),};}FileChunk copyWith({int? id,int? fileId,int? chunkIndex,Uint8List? data,String? hash}) => FileChunk(id: id ?? this.id,fileId: fileId ?? this.fileId,chunkIndex: chunkIndex ?? this.chunkIndex,data: data ?? this.data,hash: hash ?? this.hash,);FileChunk copyWithCompanion(FileChunksCompanion data) {
return FileChunk(
id: data.id.present ? data.id.value : this.id,fileId: data.fileId.present ? data.fileId.value : this.fileId,chunkIndex: data.chunkIndex.present ? data.chunkIndex.value : this.chunkIndex,data: data.data.present ? data.data.value : this.data,hash: data.hash.present ? data.hash.value : this.hash,);
}
@override
String toString() {return (StringBuffer('FileChunk(')..write('id: $id, ')..write('fileId: $fileId, ')..write('chunkIndex: $chunkIndex, ')..write('data: $data, ')..write('hash: $hash')..write(')')).toString();}
@override
 int get hashCode => Object.hash(id, fileId, chunkIndex, $driftBlobEquality.hash(data), hash);@override
bool operator ==(Object other) => identical(this, other) || (other is FileChunk && other.id == this.id && other.fileId == this.fileId && other.chunkIndex == this.chunkIndex && $driftBlobEquality.equals(other.data, this.data) && other.hash == this.hash);
}class FileChunksCompanion extends UpdateCompanion<FileChunk> {
final Value<int> id;
final Value<int> fileId;
final Value<int> chunkIndex;
final Value<Uint8List> data;
final Value<String> hash;
const FileChunksCompanion({this.id = const Value.absent(),this.fileId = const Value.absent(),this.chunkIndex = const Value.absent(),this.data = const Value.absent(),this.hash = const Value.absent(),});
FileChunksCompanion.insert({this.id = const Value.absent(),required int fileId,required int chunkIndex,required Uint8List data,required String hash,}): fileId = Value(fileId), chunkIndex = Value(chunkIndex), data = Value(data), hash = Value(hash);
static Insertable<FileChunk> custom({Expression<int>? id, 
Expression<int>? fileId, 
Expression<int>? chunkIndex, 
Expression<Uint8List>? data, 
Expression<String>? hash, 
}) {
return RawValuesInsertable({if (id != null)'id': id,if (fileId != null)'file_id': fileId,if (chunkIndex != null)'chunk_index': chunkIndex,if (data != null)'data': data,if (hash != null)'hash': hash,});
}FileChunksCompanion copyWith({Value<int>? id, Value<int>? fileId, Value<int>? chunkIndex, Value<Uint8List>? data, Value<String>? hash}) {
return FileChunksCompanion(id: id ?? this.id,fileId: fileId ?? this.fileId,chunkIndex: chunkIndex ?? this.chunkIndex,data: data ?? this.data,hash: hash ?? this.hash,);
}
@override
Map<String, Expression> toColumns(bool nullToAbsent) {
final map = <String, Expression> {};if (id.present) {
map['id'] = Variable<int>(id.value);}
if (fileId.present) {
map['file_id'] = Variable<int>(fileId.value);}
if (chunkIndex.present) {
map['chunk_index'] = Variable<int>(chunkIndex.value);}
if (data.present) {
map['data'] = Variable<Uint8List>(data.value);}
if (hash.present) {
map['hash'] = Variable<String>(hash.value);}
return map; 
}
@override
String toString() {return (StringBuffer('FileChunksCompanion(')..write('id: $id, ')..write('fileId: $fileId, ')..write('chunkIndex: $chunkIndex, ')..write('data: $data, ')..write('hash: $hash')..write(')')).toString();}
}
class $PendingMessagesTable extends PendingMessages with TableInfo<$PendingMessagesTable, PendingMessage>{
@override final GeneratedDatabase attachedDatabase;
final String? _alias;
$PendingMessagesTable(this.attachedDatabase, [this._alias]);
static const VerificationMeta _idMeta = const VerificationMeta('id');
@override
late final GeneratedColumn<String> id = GeneratedColumn<String>('id', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: false, clientDefault: () => DateTime.now().millisecondsSinceEpoch.toString() + '_' + (DateTime.now().microsecond % 100).toString());
static const VerificationMeta _senderIdMeta = const VerificationMeta('senderId');
@override
late final GeneratedColumn<String> senderId = GeneratedColumn<String>('sender_id', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
static const VerificationMeta _recipientIdMeta = const VerificationMeta('recipientId');
@override
late final GeneratedColumn<String> recipientId = GeneratedColumn<String>('recipient_id', aliasedName, true, type: DriftSqlType.string, requiredDuringInsert: false);
static const VerificationMeta _typeMeta = const VerificationMeta('type');
@override
late final GeneratedColumn<String> type = GeneratedColumn<String>('type', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
static const VerificationMeta _payloadMeta = const VerificationMeta('payload');
@override
late final GeneratedColumn<String> payload = GeneratedColumn<String>('payload', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
static const VerificationMeta _ttlMeta = const VerificationMeta('ttl');
@override
late final GeneratedColumn<int> ttl = GeneratedColumn<int>('ttl', aliasedName, false, type: DriftSqlType.int, requiredDuringInsert: false, defaultValue: const Constant(8));
static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
@override
late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>('created_at', aliasedName, false, type: DriftSqlType.dateTime, requiredDuringInsert: false, clientDefault: () => DateTime.now());
static const VerificationMeta _retryCountMeta = const VerificationMeta('retryCount');
@override
late final GeneratedColumn<int> retryCount = GeneratedColumn<int>('retry_count', aliasedName, false, type: DriftSqlType.int, requiredDuringInsert: false, defaultValue: const Constant(0));
static const VerificationMeta _lastRetryAtMeta = const VerificationMeta('lastRetryAt');
@override
late final GeneratedColumn<DateTime> lastRetryAt = GeneratedColumn<DateTime>('last_retry_at', aliasedName, true, type: DriftSqlType.dateTime, requiredDuringInsert: false);
@override
List<GeneratedColumn> get $columns => [id, senderId, recipientId, type, payload, ttl, createdAt, retryCount, lastRetryAt];
@override
String get aliasedName => _alias ?? actualTableName;
@override
String get actualTableName => $name;
static const String $name = 'pending_messages';
@override
VerificationContext validateIntegrity(Insertable<PendingMessage> instance, {bool isInserting = false}) {
final context = VerificationContext();
final data = instance.toColumns(true);
if (data.containsKey('id')) {
context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));}if (data.containsKey('sender_id')) {
context.handle(_senderIdMeta, senderId.isAcceptableOrUnknown(data['sender_id']!, _senderIdMeta));} else if (isInserting) {
context.missing(_senderIdMeta);
}
if (data.containsKey('recipient_id')) {
context.handle(_recipientIdMeta, recipientId.isAcceptableOrUnknown(data['recipient_id']!, _recipientIdMeta));}if (data.containsKey('type')) {
context.handle(_typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));} else if (isInserting) {
context.missing(_typeMeta);
}
if (data.containsKey('payload')) {
context.handle(_payloadMeta, payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta));} else if (isInserting) {
context.missing(_payloadMeta);
}
if (data.containsKey('ttl')) {
context.handle(_ttlMeta, ttl.isAcceptableOrUnknown(data['ttl']!, _ttlMeta));}if (data.containsKey('created_at')) {
context.handle(_createdAtMeta, createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));}if (data.containsKey('retry_count')) {
context.handle(_retryCountMeta, retryCount.isAcceptableOrUnknown(data['retry_count']!, _retryCountMeta));}if (data.containsKey('last_retry_at')) {
context.handle(_lastRetryAtMeta, lastRetryAt.isAcceptableOrUnknown(data['last_retry_at']!, _lastRetryAtMeta));}return context;
}
@override
Set<GeneratedColumn> get $primaryKey => {id};
@override PendingMessage map(Map<String, dynamic> data, {String? tablePrefix})  {
final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';return PendingMessage(id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!, senderId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}sender_id'])!, recipientId: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}recipient_id']), type: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}type'])!, payload: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}payload'])!, ttl: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}ttl'])!, createdAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!, retryCount: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}retry_count'])!, lastRetryAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}last_retry_at']), );
}
@override
$PendingMessagesTable createAlias(String alias) {
return $PendingMessagesTable(attachedDatabase, alias);}
}class PendingMessage extends DataClass implements Insertable<PendingMessage> 
{
final String id;
final String senderId;
final String? recipientId;
final String type;
final String payload;
final int ttl;
final DateTime createdAt;
final int retryCount;
final DateTime? lastRetryAt;
const PendingMessage({required this.id, required this.senderId, this.recipientId, required this.type, required this.payload, required this.ttl, required this.createdAt, required this.retryCount, this.lastRetryAt});@override
Map<String, Expression> toColumns(bool nullToAbsent) {
final map = <String, Expression> {};map['id'] = Variable<String>(id);
map['sender_id'] = Variable<String>(senderId);
if (!nullToAbsent || recipientId != null){map['recipient_id'] = Variable<String>(recipientId);
}map['type'] = Variable<String>(type);
map['payload'] = Variable<String>(payload);
map['ttl'] = Variable<int>(ttl);
map['created_at'] = Variable<DateTime>(createdAt);
map['retry_count'] = Variable<int>(retryCount);
if (!nullToAbsent || lastRetryAt != null){map['last_retry_at'] = Variable<DateTime>(lastRetryAt);
}return map; 
}
PendingMessagesCompanion toCompanion(bool nullToAbsent) {
return PendingMessagesCompanion(id: Value(id),senderId: Value(senderId),recipientId: recipientId == null && nullToAbsent ? const Value.absent() : Value(recipientId),type: Value(type),payload: Value(payload),ttl: Value(ttl),createdAt: Value(createdAt),retryCount: Value(retryCount),lastRetryAt: lastRetryAt == null && nullToAbsent ? const Value.absent() : Value(lastRetryAt),);
}
factory PendingMessage.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
serializer ??= driftRuntimeOptions.defaultSerializer;
return PendingMessage(id: serializer.fromJson<String>(json['id']),senderId: serializer.fromJson<String>(json['senderId']),recipientId: serializer.fromJson<String?>(json['recipientId']),type: serializer.fromJson<String>(json['type']),payload: serializer.fromJson<String>(json['payload']),ttl: serializer.fromJson<int>(json['ttl']),createdAt: serializer.fromJson<DateTime>(json['createdAt']),retryCount: serializer.fromJson<int>(json['retryCount']),lastRetryAt: serializer.fromJson<DateTime?>(json['lastRetryAt']),);}
@override Map<String, dynamic> toJson({ValueSerializer? serializer}) {
serializer ??= driftRuntimeOptions.defaultSerializer;
return <String, dynamic>{
'id': serializer.toJson<String>(id),'senderId': serializer.toJson<String>(senderId),'recipientId': serializer.toJson<String?>(recipientId),'type': serializer.toJson<String>(type),'payload': serializer.toJson<String>(payload),'ttl': serializer.toJson<int>(ttl),'createdAt': serializer.toJson<DateTime>(createdAt),'retryCount': serializer.toJson<int>(retryCount),'lastRetryAt': serializer.toJson<DateTime?>(lastRetryAt),};}PendingMessage copyWith({String? id,String? senderId,Value<String?> recipientId = const Value.absent(),String? type,String? payload,int? ttl,DateTime? createdAt,int? retryCount,Value<DateTime?> lastRetryAt = const Value.absent()}) => PendingMessage(id: id ?? this.id,senderId: senderId ?? this.senderId,recipientId: recipientId.present ? recipientId.value : this.recipientId,type: type ?? this.type,payload: payload ?? this.payload,ttl: ttl ?? this.ttl,createdAt: createdAt ?? this.createdAt,retryCount: retryCount ?? this.retryCount,lastRetryAt: lastRetryAt.present ? lastRetryAt.value : this.lastRetryAt,);PendingMessage copyWithCompanion(PendingMessagesCompanion data) {
return PendingMessage(
id: data.id.present ? data.id.value : this.id,senderId: data.senderId.present ? data.senderId.value : this.senderId,recipientId: data.recipientId.present ? data.recipientId.value : this.recipientId,type: data.type.present ? data.type.value : this.type,payload: data.payload.present ? data.payload.value : this.payload,ttl: data.ttl.present ? data.ttl.value : this.ttl,createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,retryCount: data.retryCount.present ? data.retryCount.value : this.retryCount,lastRetryAt: data.lastRetryAt.present ? data.lastRetryAt.value : this.lastRetryAt,);
}
@override
String toString() {return (StringBuffer('PendingMessage(')..write('id: $id, ')..write('senderId: $senderId, ')..write('recipientId: $recipientId, ')..write('type: $type, ')..write('payload: $payload, ')..write('ttl: $ttl, ')..write('createdAt: $createdAt, ')..write('retryCount: $retryCount, ')..write('lastRetryAt: $lastRetryAt')..write(')')).toString();}
@override
 int get hashCode => Object.hash(id, senderId, recipientId, type, payload, ttl, createdAt, retryCount, lastRetryAt);@override
bool operator ==(Object other) => identical(this, other) || (other is PendingMessage && other.id == this.id && other.senderId == this.senderId && other.recipientId == this.recipientId && other.type == this.type && other.payload == this.payload && other.ttl == this.ttl && other.createdAt == this.createdAt && other.retryCount == this.retryCount && other.lastRetryAt == this.lastRetryAt);
}class PendingMessagesCompanion extends UpdateCompanion<PendingMessage> {
final Value<String> id;
final Value<String> senderId;
final Value<String?> recipientId;
final Value<String> type;
final Value<String> payload;
final Value<int> ttl;
final Value<DateTime> createdAt;
final Value<int> retryCount;
final Value<DateTime?> lastRetryAt;
final Value<int> rowid;
const PendingMessagesCompanion({this.id = const Value.absent(),this.senderId = const Value.absent(),this.recipientId = const Value.absent(),this.type = const Value.absent(),this.payload = const Value.absent(),this.ttl = const Value.absent(),this.createdAt = const Value.absent(),this.retryCount = const Value.absent(),this.lastRetryAt = const Value.absent(),this.rowid = const Value.absent(),});
PendingMessagesCompanion.insert({this.id = const Value.absent(),required String senderId,this.recipientId = const Value.absent(),required String type,required String payload,this.ttl = const Value.absent(),this.createdAt = const Value.absent(),this.retryCount = const Value.absent(),this.lastRetryAt = const Value.absent(),this.rowid = const Value.absent(),}): senderId = Value(senderId), type = Value(type), payload = Value(payload);
static Insertable<PendingMessage> custom({Expression<String>? id, 
Expression<String>? senderId, 
Expression<String>? recipientId, 
Expression<String>? type, 
Expression<String>? payload, 
Expression<int>? ttl, 
Expression<DateTime>? createdAt, 
Expression<int>? retryCount, 
Expression<DateTime>? lastRetryAt, 
Expression<int>? rowid, 
}) {
return RawValuesInsertable({if (id != null)'id': id,if (senderId != null)'sender_id': senderId,if (recipientId != null)'recipient_id': recipientId,if (type != null)'type': type,if (payload != null)'payload': payload,if (ttl != null)'ttl': ttl,if (createdAt != null)'created_at': createdAt,if (retryCount != null)'retry_count': retryCount,if (lastRetryAt != null)'last_retry_at': lastRetryAt,if (rowid != null)'rowid': rowid,});
}PendingMessagesCompanion copyWith({Value<String>? id, Value<String>? senderId, Value<String?>? recipientId, Value<String>? type, Value<String>? payload, Value<int>? ttl, Value<DateTime>? createdAt, Value<int>? retryCount, Value<DateTime?>? lastRetryAt, Value<int>? rowid}) {
return PendingMessagesCompanion(id: id ?? this.id,senderId: senderId ?? this.senderId,recipientId: recipientId ?? this.recipientId,type: type ?? this.type,payload: payload ?? this.payload,ttl: ttl ?? this.ttl,createdAt: createdAt ?? this.createdAt,retryCount: retryCount ?? this.retryCount,lastRetryAt: lastRetryAt ?? this.lastRetryAt,rowid: rowid ?? this.rowid,);
}
@override
Map<String, Expression> toColumns(bool nullToAbsent) {
final map = <String, Expression> {};if (id.present) {
map['id'] = Variable<String>(id.value);}
if (senderId.present) {
map['sender_id'] = Variable<String>(senderId.value);}
if (recipientId.present) {
map['recipient_id'] = Variable<String>(recipientId.value);}
if (type.present) {
map['type'] = Variable<String>(type.value);}
if (payload.present) {
map['payload'] = Variable<String>(payload.value);}
if (ttl.present) {
map['ttl'] = Variable<int>(ttl.value);}
if (createdAt.present) {
map['created_at'] = Variable<DateTime>(createdAt.value);}
if (retryCount.present) {
map['retry_count'] = Variable<int>(retryCount.value);}
if (lastRetryAt.present) {
map['last_retry_at'] = Variable<DateTime>(lastRetryAt.value);}
if (rowid.present) {
map['rowid'] = Variable<int>(rowid.value);}
return map; 
}
@override
String toString() {return (StringBuffer('PendingMessagesCompanion(')..write('id: $id, ')..write('senderId: $senderId, ')..write('recipientId: $recipientId, ')..write('type: $type, ')..write('payload: $payload, ')..write('ttl: $ttl, ')..write('createdAt: $createdAt, ')..write('retryCount: $retryCount, ')..write('lastRetryAt: $lastRetryAt, ')..write('rowid: $rowid')..write(')')).toString();}
}
abstract class _$VaultDatabase extends GeneratedDatabase{
_$VaultDatabase(QueryExecutor e): super(e);
$VaultDatabaseManager get managers => $VaultDatabaseManager(this);
late final $StoredFilesTable storedFiles = $StoredFilesTable(this);
late final $FileChunksTable fileChunks = $FileChunksTable(this);
late final $PendingMessagesTable pendingMessages = $PendingMessagesTable(this);
@override
Iterable<TableInfo<Table, Object?>> get allTables => allSchemaEntities.whereType<TableInfo<Table, Object?>>();
@override
List<DatabaseSchemaEntity> get allSchemaEntities => [storedFiles, fileChunks, pendingMessages];
}
typedef $$StoredFilesTableCreateCompanionBuilder = StoredFilesCompanion Function({Value<int> id,required String fileName,required String fileHash,required int totalChunks,Value<bool> isComplete,});
typedef $$StoredFilesTableUpdateCompanionBuilder = StoredFilesCompanion Function({Value<int> id,Value<String> fileName,Value<String> fileHash,Value<int> totalChunks,Value<bool> isComplete,});
      final class $$StoredFilesTableReferences extends BaseReferences<
        _$VaultDatabase,
        $StoredFilesTable,
        StoredFile> {
        $$StoredFilesTableReferences(super.$_db, super.$_table, super.$_typedResult);

                          static MultiTypedResultKey<
          $FileChunksTable,
          List<FileChunk>
        > _fileChunksRefsTable(_$VaultDatabase db) =>
          MultiTypedResultKey.fromTable(
          db.fileChunks,
          aliasName: $_aliasNameGenerator(
            db.storedFiles.id,
            db.fileChunks.fileId)
        );

          $$FileChunksTableProcessedTableManager get fileChunksRefs {
        final manager = $$FileChunksTableTableManager(
            $_db, $_db.fileChunks
            ).filter(
              (f) => f.fileId.id.sqlEquals(
                $_itemColumn<int>('id')!
            )
          );

          final cache = $_typedResult.readTableOrNull(_fileChunksRefsTable($_db));
          return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
        }
        

      }class $$StoredFilesTableFilterComposer extends Composer<
        _$VaultDatabase,
        $StoredFilesTable> {
        $$StoredFilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
          ColumnFilters<int> get id => $composableBuilder(
      column: $table.id,
      builder: (column) =>
      ColumnFilters(column));
      
ColumnFilters<String> get fileName => $composableBuilder(
      column: $table.fileName,
      builder: (column) =>
      ColumnFilters(column));
      
ColumnFilters<String> get fileHash => $composableBuilder(
      column: $table.fileHash,
      builder: (column) =>
      ColumnFilters(column));
      
ColumnFilters<int> get totalChunks => $composableBuilder(
      column: $table.totalChunks,
      builder: (column) =>
      ColumnFilters(column));
      
ColumnFilters<bool> get isComplete => $composableBuilder(
      column: $table.isComplete,
      builder: (column) =>
      ColumnFilters(column));
      
        Expression<bool> fileChunksRefs(
          Expression<bool> Function( $$FileChunksTableFilterComposer f) f
        ) {
                final $$FileChunksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.fileChunks,
      getReferencedColumn: (t) => t.fileId,
      builder: (joinBuilder,{$addJoinBuilderToRootComposer,$removeJoinBuilderFromRootComposer }) =>
      $$FileChunksTableFilterComposer(
              $db: $db,
              $table: $db.fileChunks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
        ));
          return f(composer);
        }

        }
      class $$StoredFilesTableOrderingComposer extends Composer<
        _$VaultDatabase,
        $StoredFilesTable> {
        $$StoredFilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
          ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id,
      builder: (column) =>
      ColumnOrderings(column));
      
ColumnOrderings<String> get fileName => $composableBuilder(
      column: $table.fileName,
      builder: (column) =>
      ColumnOrderings(column));
      
ColumnOrderings<String> get fileHash => $composableBuilder(
      column: $table.fileHash,
      builder: (column) =>
      ColumnOrderings(column));
      
ColumnOrderings<int> get totalChunks => $composableBuilder(
      column: $table.totalChunks,
      builder: (column) =>
      ColumnOrderings(column));
      
ColumnOrderings<bool> get isComplete => $composableBuilder(
      column: $table.isComplete,
      builder: (column) =>
      ColumnOrderings(column));
      
        }
      class $$StoredFilesTableAnnotationComposer extends Composer<
        _$VaultDatabase,
        $StoredFilesTable> {
        $$StoredFilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
          GeneratedColumn<int> get id => $composableBuilder(
      column: $table.id,
      builder: (column) => column);
      
GeneratedColumn<String> get fileName => $composableBuilder(
      column: $table.fileName,
      builder: (column) => column);
      
GeneratedColumn<String> get fileHash => $composableBuilder(
      column: $table.fileHash,
      builder: (column) => column);
      
GeneratedColumn<int> get totalChunks => $composableBuilder(
      column: $table.totalChunks,
      builder: (column) => column);
      
GeneratedColumn<bool> get isComplete => $composableBuilder(
      column: $table.isComplete,
      builder: (column) => column);
      
        Expression<T> fileChunksRefs<T extends Object>(
          Expression<T> Function( $$FileChunksTableAnnotationComposer a) f
        ) {
                final $$FileChunksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.fileChunks,
      getReferencedColumn: (t) => t.fileId,
      builder: (joinBuilder,{$addJoinBuilderToRootComposer,$removeJoinBuilderFromRootComposer }) =>
      $$FileChunksTableAnnotationComposer(
              $db: $db,
              $table: $db.fileChunks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
        ));
          return f(composer);
        }

        }
      class $$StoredFilesTableTableManager extends RootTableManager    <_$VaultDatabase,
    $StoredFilesTable,
    StoredFile,
    $$StoredFilesTableFilterComposer,
    $$StoredFilesTableOrderingComposer,
    $$StoredFilesTableAnnotationComposer,
    $$StoredFilesTableCreateCompanionBuilder,
    $$StoredFilesTableUpdateCompanionBuilder,
    (StoredFile,$$StoredFilesTableReferences),
    StoredFile,
    PrefetchHooks Function({bool fileChunksRefs})
    > {
    $$StoredFilesTableTableManager(_$VaultDatabase db, $StoredFilesTable table) : super(
      TableManagerState(
        db: db,
        table: table,
        createFilteringComposer: () => $$StoredFilesTableFilterComposer($db: db,$table:table),
        createOrderingComposer: () => $$StoredFilesTableOrderingComposer($db: db,$table:table),
        createComputedFieldComposer: () => $$StoredFilesTableAnnotationComposer($db: db,$table:table),
        updateCompanionCallback: ({Value<int> id = const Value.absent(),Value<String> fileName = const Value.absent(),Value<String> fileHash = const Value.absent(),Value<int> totalChunks = const Value.absent(),Value<bool> isComplete = const Value.absent(),})=> StoredFilesCompanion(id: id,fileName: fileName,fileHash: fileHash,totalChunks: totalChunks,isComplete: isComplete,),
        createCompanionCallback: ({Value<int> id = const Value.absent(),required String fileName,required String fileHash,required int totalChunks,Value<bool> isComplete = const Value.absent(),})=> StoredFilesCompanion.insert(id: id,fileName: fileName,fileHash: fileHash,totalChunks: totalChunks,isComplete: isComplete,),
        withReferenceMapper: (p0) => p0
              .map(
                  (e) =>
                     (e.readTable(table), $$StoredFilesTableReferences(db, table, e))
                  )
              .toList(),
        prefetchHooksCallback:         ({fileChunksRefs = false}){
          return PrefetchHooks(
            db: db,
            explicitlyWatchedTables: [
             if (fileChunksRefs) db.fileChunks
            ],
            addJoins: null,
            getPrefetchedDataCallback: (items) async {
            return [
                      if (fileChunksRefs) await $_getPrefetchedData
            <StoredFile, $StoredFilesTable, FileChunk>(
                  currentTable: table,
                  referencedTable:
                      $$StoredFilesTableReferences._fileChunksRefsTable(db),
                  managerFromTypedResult: (p0) =>
                      $$StoredFilesTableReferences(db, table, p0).fileChunksRefs,
                  referencedItemsForCurrentItem: (item, referencedItems) =>
                      referencedItems.where((e) => e.fileId == item.id),
                  typedResults: items)
            
                ];
              },
          );
        }
,
        ));
        }
    typedef $$StoredFilesTableProcessedTableManager = ProcessedTableManager    <_$VaultDatabase,
    $StoredFilesTable,
    StoredFile,
    $$StoredFilesTableFilterComposer,
    $$StoredFilesTableOrderingComposer,
    $$StoredFilesTableAnnotationComposer,
    $$StoredFilesTableCreateCompanionBuilder,
    $$StoredFilesTableUpdateCompanionBuilder,
    (StoredFile,$$StoredFilesTableReferences),
    StoredFile,
    PrefetchHooks Function({bool fileChunksRefs})
    >;typedef $$FileChunksTableCreateCompanionBuilder = FileChunksCompanion Function({Value<int> id,required int fileId,required int chunkIndex,required Uint8List data,required String hash,});
typedef $$FileChunksTableUpdateCompanionBuilder = FileChunksCompanion Function({Value<int> id,Value<int> fileId,Value<int> chunkIndex,Value<Uint8List> data,Value<String> hash,});
      final class $$FileChunksTableReferences extends BaseReferences<
        _$VaultDatabase,
        $FileChunksTable,
        FileChunk> {
        $$FileChunksTableReferences(super.$_db, super.$_table, super.$_typedResult);

                          static $StoredFilesTable _fileIdTable(_$VaultDatabase db) =>
            db.storedFiles.createAlias($_aliasNameGenerator(
            db.fileChunks.fileId,
            db.storedFiles.id));
          

        $$StoredFilesTableProcessedTableManager get fileId {
          final $_column = $_itemColumn<int>('file_id')!;
          
          final manager = $$StoredFilesTableTableManager($_db, $_db.storedFiles).filter((f) => f.id.sqlEquals($_column));
          final item = $_typedResult.readTableOrNull(_fileIdTable($_db));
          if (item == null) return manager;
          return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
        }


      }class $$FileChunksTableFilterComposer extends Composer<
        _$VaultDatabase,
        $FileChunksTable> {
        $$FileChunksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
          ColumnFilters<int> get id => $composableBuilder(
      column: $table.id,
      builder: (column) =>
      ColumnFilters(column));
      
ColumnFilters<int> get chunkIndex => $composableBuilder(
      column: $table.chunkIndex,
      builder: (column) =>
      ColumnFilters(column));
      
ColumnFilters<Uint8List> get data => $composableBuilder(
      column: $table.data,
      builder: (column) =>
      ColumnFilters(column));
      
ColumnFilters<String> get hash => $composableBuilder(
      column: $table.hash,
      builder: (column) =>
      ColumnFilters(column));
      
        $$StoredFilesTableFilterComposer get fileId {
                final $$StoredFilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fileId,
      referencedTable: $db.storedFiles,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder,{$addJoinBuilderToRootComposer,$removeJoinBuilderFromRootComposer }) =>
      $$StoredFilesTableFilterComposer(
              $db: $db,
              $table: $db.storedFiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
        ));
          return composer;
        }
        }
      class $$FileChunksTableOrderingComposer extends Composer<
        _$VaultDatabase,
        $FileChunksTable> {
        $$FileChunksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
          ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id,
      builder: (column) =>
      ColumnOrderings(column));
      
ColumnOrderings<int> get chunkIndex => $composableBuilder(
      column: $table.chunkIndex,
      builder: (column) =>
      ColumnOrderings(column));
      
ColumnOrderings<Uint8List> get data => $composableBuilder(
      column: $table.data,
      builder: (column) =>
      ColumnOrderings(column));
      
ColumnOrderings<String> get hash => $composableBuilder(
      column: $table.hash,
      builder: (column) =>
      ColumnOrderings(column));
      
        $$StoredFilesTableOrderingComposer get fileId {
                final $$StoredFilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fileId,
      referencedTable: $db.storedFiles,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder,{$addJoinBuilderToRootComposer,$removeJoinBuilderFromRootComposer }) =>
      $$StoredFilesTableOrderingComposer(
              $db: $db,
              $table: $db.storedFiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
        ));
          return composer;
        }
        }
      class $$FileChunksTableAnnotationComposer extends Composer<
        _$VaultDatabase,
        $FileChunksTable> {
        $$FileChunksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
          GeneratedColumn<int> get id => $composableBuilder(
      column: $table.id,
      builder: (column) => column);
      
GeneratedColumn<int> get chunkIndex => $composableBuilder(
      column: $table.chunkIndex,
      builder: (column) => column);
      
GeneratedColumn<Uint8List> get data => $composableBuilder(
      column: $table.data,
      builder: (column) => column);
      
GeneratedColumn<String> get hash => $composableBuilder(
      column: $table.hash,
      builder: (column) => column);
      
        $$StoredFilesTableAnnotationComposer get fileId {
                final $$StoredFilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fileId,
      referencedTable: $db.storedFiles,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder,{$addJoinBuilderToRootComposer,$removeJoinBuilderFromRootComposer }) =>
      $$StoredFilesTableAnnotationComposer(
              $db: $db,
              $table: $db.storedFiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
        ));
          return composer;
        }
        }
      class $$FileChunksTableTableManager extends RootTableManager    <_$VaultDatabase,
    $FileChunksTable,
    FileChunk,
    $$FileChunksTableFilterComposer,
    $$FileChunksTableOrderingComposer,
    $$FileChunksTableAnnotationComposer,
    $$FileChunksTableCreateCompanionBuilder,
    $$FileChunksTableUpdateCompanionBuilder,
    (FileChunk,$$FileChunksTableReferences),
    FileChunk,
    PrefetchHooks Function({bool fileId})
    > {
    $$FileChunksTableTableManager(_$VaultDatabase db, $FileChunksTable table) : super(
      TableManagerState(
        db: db,
        table: table,
        createFilteringComposer: () => $$FileChunksTableFilterComposer($db: db,$table:table),
        createOrderingComposer: () => $$FileChunksTableOrderingComposer($db: db,$table:table),
        createComputedFieldComposer: () => $$FileChunksTableAnnotationComposer($db: db,$table:table),
        updateCompanionCallback: ({Value<int> id = const Value.absent(),Value<int> fileId = const Value.absent(),Value<int> chunkIndex = const Value.absent(),Value<Uint8List> data = const Value.absent(),Value<String> hash = const Value.absent(),})=> FileChunksCompanion(id: id,fileId: fileId,chunkIndex: chunkIndex,data: data,hash: hash,),
        createCompanionCallback: ({Value<int> id = const Value.absent(),required int fileId,required int chunkIndex,required Uint8List data,required String hash,})=> FileChunksCompanion.insert(id: id,fileId: fileId,chunkIndex: chunkIndex,data: data,hash: hash,),
        withReferenceMapper: (p0) => p0
              .map(
                  (e) =>
                     (e.readTable(table), $$FileChunksTableReferences(db, table, e))
                  )
              .toList(),
        prefetchHooksCallback:         ({fileId = false}){
          return PrefetchHooks(
            db: db,
            explicitlyWatchedTables: [
             
            ],
            addJoins: <T extends TableManagerState<dynamic,dynamic,dynamic,dynamic,dynamic,dynamic,dynamic,dynamic,dynamic,dynamic,dynamic>>(state) {

                                  if (fileId){
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.fileId,
                    referencedTable:
                        $$FileChunksTableReferences._fileIdTable(db),
                    referencedColumn:
                        $$FileChunksTableReferences._fileIdTable(db).id,
                  ) as T;
               }

                return state;
              }
,
            getPrefetchedDataCallback: (items) async {
            return [
            
                ];
              },
          );
        }
,
        ));
        }
    typedef $$FileChunksTableProcessedTableManager = ProcessedTableManager    <_$VaultDatabase,
    $FileChunksTable,
    FileChunk,
    $$FileChunksTableFilterComposer,
    $$FileChunksTableOrderingComposer,
    $$FileChunksTableAnnotationComposer,
    $$FileChunksTableCreateCompanionBuilder,
    $$FileChunksTableUpdateCompanionBuilder,
    (FileChunk,$$FileChunksTableReferences),
    FileChunk,
    PrefetchHooks Function({bool fileId})
    >;typedef $$PendingMessagesTableCreateCompanionBuilder = PendingMessagesCompanion Function({Value<String> id,required String senderId,Value<String?> recipientId,required String type,required String payload,Value<int> ttl,Value<DateTime> createdAt,Value<int> retryCount,Value<DateTime?> lastRetryAt,Value<int> rowid,});
typedef $$PendingMessagesTableUpdateCompanionBuilder = PendingMessagesCompanion Function({Value<String> id,Value<String> senderId,Value<String?> recipientId,Value<String> type,Value<String> payload,Value<int> ttl,Value<DateTime> createdAt,Value<int> retryCount,Value<DateTime?> lastRetryAt,Value<int> rowid,});
class $$PendingMessagesTableFilterComposer extends Composer<
        _$VaultDatabase,
        $PendingMessagesTable> {
        $$PendingMessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
          ColumnFilters<String> get id => $composableBuilder(
      column: $table.id,
      builder: (column) =>
      ColumnFilters(column));
      
ColumnFilters<String> get senderId => $composableBuilder(
      column: $table.senderId,
      builder: (column) =>
      ColumnFilters(column));
      
ColumnFilters<String> get recipientId => $composableBuilder(
      column: $table.recipientId,
      builder: (column) =>
      ColumnFilters(column));
      
ColumnFilters<String> get type => $composableBuilder(
      column: $table.type,
      builder: (column) =>
      ColumnFilters(column));
      
ColumnFilters<String> get payload => $composableBuilder(
      column: $table.payload,
      builder: (column) =>
      ColumnFilters(column));
      
ColumnFilters<int> get ttl => $composableBuilder(
      column: $table.ttl,
      builder: (column) =>
      ColumnFilters(column));
      
ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt,
      builder: (column) =>
      ColumnFilters(column));
      
ColumnFilters<int> get retryCount => $composableBuilder(
      column: $table.retryCount,
      builder: (column) =>
      ColumnFilters(column));
      
ColumnFilters<DateTime> get lastRetryAt => $composableBuilder(
      column: $table.lastRetryAt,
      builder: (column) =>
      ColumnFilters(column));
      
        }
      class $$PendingMessagesTableOrderingComposer extends Composer<
        _$VaultDatabase,
        $PendingMessagesTable> {
        $$PendingMessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
          ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id,
      builder: (column) =>
      ColumnOrderings(column));
      
ColumnOrderings<String> get senderId => $composableBuilder(
      column: $table.senderId,
      builder: (column) =>
      ColumnOrderings(column));
      
ColumnOrderings<String> get recipientId => $composableBuilder(
      column: $table.recipientId,
      builder: (column) =>
      ColumnOrderings(column));
      
ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type,
      builder: (column) =>
      ColumnOrderings(column));
      
ColumnOrderings<String> get payload => $composableBuilder(
      column: $table.payload,
      builder: (column) =>
      ColumnOrderings(column));
      
ColumnOrderings<int> get ttl => $composableBuilder(
      column: $table.ttl,
      builder: (column) =>
      ColumnOrderings(column));
      
ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt,
      builder: (column) =>
      ColumnOrderings(column));
      
ColumnOrderings<int> get retryCount => $composableBuilder(
      column: $table.retryCount,
      builder: (column) =>
      ColumnOrderings(column));
      
ColumnOrderings<DateTime> get lastRetryAt => $composableBuilder(
      column: $table.lastRetryAt,
      builder: (column) =>
      ColumnOrderings(column));
      
        }
      class $$PendingMessagesTableAnnotationComposer extends Composer<
        _$VaultDatabase,
        $PendingMessagesTable> {
        $$PendingMessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
          GeneratedColumn<String> get id => $composableBuilder(
      column: $table.id,
      builder: (column) => column);
      
GeneratedColumn<String> get senderId => $composableBuilder(
      column: $table.senderId,
      builder: (column) => column);
      
GeneratedColumn<String> get recipientId => $composableBuilder(
      column: $table.recipientId,
      builder: (column) => column);
      
GeneratedColumn<String> get type => $composableBuilder(
      column: $table.type,
      builder: (column) => column);
      
GeneratedColumn<String> get payload => $composableBuilder(
      column: $table.payload,
      builder: (column) => column);
      
GeneratedColumn<int> get ttl => $composableBuilder(
      column: $table.ttl,
      builder: (column) => column);
      
GeneratedColumn<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt,
      builder: (column) => column);
      
GeneratedColumn<int> get retryCount => $composableBuilder(
      column: $table.retryCount,
      builder: (column) => column);
      
GeneratedColumn<DateTime> get lastRetryAt => $composableBuilder(
      column: $table.lastRetryAt,
      builder: (column) => column);
      
        }
      class $$PendingMessagesTableTableManager extends RootTableManager    <_$VaultDatabase,
    $PendingMessagesTable,
    PendingMessage,
    $$PendingMessagesTableFilterComposer,
    $$PendingMessagesTableOrderingComposer,
    $$PendingMessagesTableAnnotationComposer,
    $$PendingMessagesTableCreateCompanionBuilder,
    $$PendingMessagesTableUpdateCompanionBuilder,
    (PendingMessage,BaseReferences<_$VaultDatabase,$PendingMessagesTable,PendingMessage>),
    PendingMessage,
    PrefetchHooks Function()
    > {
    $$PendingMessagesTableTableManager(_$VaultDatabase db, $PendingMessagesTable table) : super(
      TableManagerState(
        db: db,
        table: table,
        createFilteringComposer: () => $$PendingMessagesTableFilterComposer($db: db,$table:table),
        createOrderingComposer: () => $$PendingMessagesTableOrderingComposer($db: db,$table:table),
        createComputedFieldComposer: () => $$PendingMessagesTableAnnotationComposer($db: db,$table:table),
        updateCompanionCallback: ({Value<String> id = const Value.absent(),Value<String> senderId = const Value.absent(),Value<String?> recipientId = const Value.absent(),Value<String> type = const Value.absent(),Value<String> payload = const Value.absent(),Value<int> ttl = const Value.absent(),Value<DateTime> createdAt = const Value.absent(),Value<int> retryCount = const Value.absent(),Value<DateTime?> lastRetryAt = const Value.absent(),Value<int> rowid = const Value.absent(),})=> PendingMessagesCompanion(id: id,senderId: senderId,recipientId: recipientId,type: type,payload: payload,ttl: ttl,createdAt: createdAt,retryCount: retryCount,lastRetryAt: lastRetryAt,rowid: rowid,),
        createCompanionCallback: ({Value<String> id = const Value.absent(),required String senderId,Value<String?> recipientId = const Value.absent(),required String type,required String payload,Value<int> ttl = const Value.absent(),Value<DateTime> createdAt = const Value.absent(),Value<int> retryCount = const Value.absent(),Value<DateTime?> lastRetryAt = const Value.absent(),Value<int> rowid = const Value.absent(),})=> PendingMessagesCompanion.insert(id: id,senderId: senderId,recipientId: recipientId,type: type,payload: payload,ttl: ttl,createdAt: createdAt,retryCount: retryCount,lastRetryAt: lastRetryAt,rowid: rowid,),
        withReferenceMapper: (p0) => p0
              .map(
                  (e) =>
                     (e.readTable(table), BaseReferences(db, table, e))
                  )
              .toList(),
        prefetchHooksCallback: null,
        ));
        }
    typedef $$PendingMessagesTableProcessedTableManager = ProcessedTableManager    <_$VaultDatabase,
    $PendingMessagesTable,
    PendingMessage,
    $$PendingMessagesTableFilterComposer,
    $$PendingMessagesTableOrderingComposer,
    $$PendingMessagesTableAnnotationComposer,
    $$PendingMessagesTableCreateCompanionBuilder,
    $$PendingMessagesTableUpdateCompanionBuilder,
    (PendingMessage,BaseReferences<_$VaultDatabase,$PendingMessagesTable,PendingMessage>),
    PendingMessage,
    PrefetchHooks Function()
    >;class $VaultDatabaseManager {
final _$VaultDatabase _db;
$VaultDatabaseManager(this._db);
$$StoredFilesTableTableManager get storedFiles => $$StoredFilesTableTableManager(_db, _db.storedFiles);
$$FileChunksTableTableManager get fileChunks => $$FileChunksTableTableManager(_db, _db.fileChunks);
$$PendingMessagesTableTableManager get pendingMessages => $$PendingMessagesTableTableManager(_db, _db.pendingMessages);
}
