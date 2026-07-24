import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message_model.dart';
import '../models/user_identity_model.dart';

class FirestoreService {
  final FirebaseFirestore _db;

  FirestoreService(this._db);

  // ── Collection References ────────────────────────────────────

  CollectionReference<Map<String, dynamic>> get _rooms =>
      _db.collection('rooms');

  DocumentReference<Map<String, dynamic>> _room(String code) =>
      _rooms.doc(code);

  CollectionReference<Map<String, dynamic>> _messages(String roomCode) =>
      _room(roomCode).collection('messages');

  CollectionReference<Map<String, dynamic>> _members(String roomCode) =>
      _room(roomCode).collection('members');

  // ── Rooms ────────────────────────────────────────────────────

  /// Check if a room document exists
  Future<bool> roomExists(String code) async {
    final doc = await _room(code).get();
    return doc.exists;
  }

  /// Create a new room document
  Future<void> createRoom(String code) async {
    await _room(code).set({
      'createdAt': FieldValue.serverTimestamp(),
      'memberCount': 0,
    });
  }

  /// Join a room: add member document + increment member count (idempotent)
  Future<void> joinRoom(UserIdentityModel identity) async {
    final memberRef = _members(identity.roomCode).doc(identity.userId);
    final snap = await memberRef.get();
    if (!snap.exists) {
      final batch = _db.batch();
      batch.set(memberRef, {
        'userId': identity.userId,
        'name': identity.name,
        'joinedAt': FieldValue.serverTimestamp(),
      });
      batch.update(_room(identity.roomCode), {
        'memberCount': FieldValue.increment(1),
      });
      await batch.commit();
    }
  }

  /// Real-time stream of member count
  Stream<int> watchMemberCount(String roomCode) {
    return _room(roomCode)
        .snapshots()
        .map((snap) {
      if (!snap.exists) return 0;
      return (snap.data()?['memberCount'] as num?)?.toInt() ?? 0;
    });
  }

  // ── Messages ─────────────────────────────────────────────────

  /// Load the most recent [limit] messages (newest → oldest)
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> loadInitialDocs(
    String roomCode, {
    int limit = 20,
  }) async {
    final snap = await _messages(roomCode)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .get();
    return snap.docs;
  }

  /// Load [limit] messages older than [beforeDoc]
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> loadMoreDocs(
    String roomCode,
    QueryDocumentSnapshot<Map<String, dynamic>> beforeDoc, {
    int limit = 20,
  }) async {
    final snap = await _messages(roomCode)
        .orderBy('timestamp', descending: true)
        .startAfterDocument(beforeDoc)
        .limit(limit)
        .get();
    return snap.docs;
  }

  /// Stream of messages arriving AFTER [afterTimestamp]
  Stream<List<MessageModel>> watchNewMessages(
    String roomCode,
    DateTime afterTimestamp,
  ) {
    return _messages(roomCode)
        .where('timestamp',
            isGreaterThan: Timestamp.fromDate(afterTimestamp))
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snap) => snap.docs.map(MessageModel.fromDoc).toList());
  }

  /// Send a message
  Future<void> sendMessage(
      String roomCode, MessageModel message) async {
    await _messages(roomCode).add(message.toFirestore());
  }
}
