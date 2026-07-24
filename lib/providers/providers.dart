import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/firestore_service.dart';
import '../services/identity_storage_service.dart';
import '../services/random_user_service.dart';

// ── Foundational providers ────────────────────────────────────────

/// Overridden in main.dart after SharedPreferences.getInstance() resolves.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden');
});

/// Singleton FirestoreService wired to the default Firebase instance.
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService(FirebaseFirestore.instance);
});

/// IdentityStorageService backed by SharedPreferences.
final identityStorageServiceProvider =
    Provider<IdentityStorageService>((ref) {
  return IdentityStorageService(ref.read(sharedPreferencesProvider));
});

/// RandomUserService for fetching UUIDs from randomuser.me.
final randomUserServiceProvider = Provider<RandomUserService>((ref) {
  return RandomUserService();
});

// ── Real-time member count ────────────────────────────────────────

/// Streams the live member count for [roomCode].
final memberCountStreamProvider =
    StreamProvider.autoDispose.family<int, String>((ref, roomCode) {
  return ref.read(firestoreServiceProvider).watchMemberCount(roomCode);
});
