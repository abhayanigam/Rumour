import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_identity_model.dart';

/// Manages anonymous user identities stored locally per room.
/// Uses SharedPreferences so identities persist across app restarts.
class IdentityStorageService {
  static const String _prefix = 'rumour_identity_';

  final SharedPreferences _prefs;

  IdentityStorageService(this._prefs);

  String _key(String roomCode) => '$_prefix$roomCode';

  /// Retrieve stored identity for [roomCode], or null if none.
  UserIdentityModel? getIdentity(String roomCode) {
    final json = _prefs.getString(_key(roomCode));
    if (json == null) return null;
    try {
      return UserIdentityModel.fromMap(
          jsonDecode(json) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  /// Persist [identity] locally for its roomCode.
  Future<void> saveIdentity(UserIdentityModel identity) async {
    await _prefs.setString(_key(identity.roomCode), jsonEncode(identity.toMap()));
  }

  // ── Name generation ──────────────────────────────────────────

  /// Generates a random "Adjective Animal" display name (e.g. "Brave Badger").
  static String generateAnonymousName() {
    final rng = Random();
    final adj = _adjectives[rng.nextInt(_adjectives.length)];
    final animal = _animals[rng.nextInt(_animals.length)];
    return '$adj $animal';
  }

  static const List<String> _adjectives = [
    'Brave', 'Silent', 'Wild', 'Swift', 'Quiet', 'Bold', 'Dark', 'Clever',
    'Fierce', 'Noble', 'Sly', 'Mighty', 'Mystic', 'Golden', 'Silver', 'Iron',
    'Crimson', 'Azure', 'Storm', 'Phantom', 'Lunar', 'Solar', 'Cosmic',
    'Shadow', 'Radiant', 'Frosty', 'Ancient', 'Blazing', 'Crystal', 'Amber',
    'Rusty', 'Lucky', 'Witty', 'Sleek', 'Shiny', 'Dusty', 'Fuzzy', 'Grumpy',
  ];

  static const List<String> _animals = [
    'Badger', 'Panther', 'Fox', 'Wolf', 'Eagle', 'Hawk', 'Bear', 'Tiger',
    'Lion', 'Raven', 'Falcon', 'Cobra', 'Viper', 'Jaguar', 'Lynx', 'Otter',
    'Puma', 'Shark', 'Drake', 'Phoenix', 'Griffin', 'Hyena', 'Bison', 'Boar',
    'Crane', 'Dolphin', 'Gecko', 'Heron', 'Iguana', 'Jackal', 'Kestrel',
    'Lemur', 'Mink', 'Newt', 'Osprey', 'Quail', 'Rhino', 'Sloth', 'Tapir',
  ];
}
