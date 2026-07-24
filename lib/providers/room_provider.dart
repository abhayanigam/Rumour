import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_identity_model.dart';
import '../services/firestore_service.dart';
import '../services/identity_storage_service.dart';
import '../services/random_user_service.dart';
import 'providers.dart';

// ── State ────────────────────────────────────────────────────────

enum JoinStatus { idle, loading, success, error }

/// Represents the outcome of a join/create room action.
class JoinRoomState {
  final JoinStatus status;
  final bool isNewIdentity; // true → show identity reveal screen
  final UserIdentityModel? identity;
  final String? error;

  const JoinRoomState({
    this.status = JoinStatus.idle,
    this.isNewIdentity = false,
    this.identity,
    this.error,
  });

  JoinRoomState copyWith({
    JoinStatus? status,
    bool? isNewIdentity,
    UserIdentityModel? identity,
    String? error,
  }) =>
      JoinRoomState(
        status: status ?? this.status,
        isNewIdentity: isNewIdentity ?? this.isNewIdentity,
        identity: identity ?? this.identity,
        error: error ?? this.error,
      );
}

// ── Notifier ─────────────────────────────────────────────────────

class JoinRoomNotifier extends StateNotifier<JoinRoomState> {
  final FirestoreService _firestore;
  final IdentityStorageService _identityStorage;
  final RandomUserService _randomUser;

  JoinRoomNotifier({
    required FirestoreService firestore,
    required IdentityStorageService identityStorage,
    required RandomUserService randomUser,
  })  : _firestore = firestore,
        _identityStorage = identityStorage,
        _randomUser = randomUser,
        super(const JoinRoomState());

  Future<void> joinRoom(String roomCode) async {
    state = state.copyWith(status: JoinStatus.loading);
    try {
      // 1. Check for existing local identity
      final existing = _identityStorage.getIdentity(roomCode);
      if (existing != null) {
        // Ensure room exists (create if somehow missing)
        await _ensureRoomExists(roomCode);
        // Re-register member in Firestore (idempotent)
        await _firestore.joinRoom(existing);
        state = state.copyWith(
          status: JoinStatus.success,
          isNewIdentity: false,
          identity: existing,
        );
        return;
      }

      // 2. New identity flow
      await _ensureRoomExists(roomCode);
      final userId = await _randomUser.fetchRandomUserId();
      final name = IdentityStorageService.generateAnonymousName();
      final identity = UserIdentityModel(
        userId: userId,
        name: name,
        roomCode: roomCode,
      );
      await _identityStorage.saveIdentity(identity);
      await _firestore.joinRoom(identity);

      state = state.copyWith(
        status: JoinStatus.success,
        isNewIdentity: true,
        identity: identity,
      );
    } catch (e) {
      state = state.copyWith(
        status: JoinStatus.error,
        error: 'Could not join room. Please try again.',
      );
    }
  }

  Future<void> _ensureRoomExists(String code) async {
    if (!await _firestore.roomExists(code)) {
      await _firestore.createRoom(code);
    }
  }

  void reset() => state = const JoinRoomState();
}

// ── Provider ─────────────────────────────────────────────────────

final joinRoomProvider =
    StateNotifierProvider.autoDispose<JoinRoomNotifier, JoinRoomState>((ref) {
  return JoinRoomNotifier(
    firestore: ref.read(firestoreServiceProvider),
    identityStorage: ref.read(identityStorageServiceProvider),
    randomUser: ref.read(randomUserServiceProvider),
  );
});
