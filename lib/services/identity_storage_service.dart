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

  /// Generates a funky & creative Indian display name
  /// (e.g. "Bindaas Sher", "Baahubali Bandar", "Desi Garuda", "Jhakkas Naagin").
  /// Has a 20% chance to pick a fully creative standalone name instead.
  static String generateAnonymousName() {
    final rng = Random();
    // 20% chance: return a fully creative standalone name
    if (rng.nextInt(5) == 0) {
      return _creativeNames[rng.nextInt(_creativeNames.length)];
    }
    final adj = _adjectives[rng.nextInt(_adjectives.length)];
    final animal = _animals[rng.nextInt(_animals.length)];
    return '$adj $animal';
  }

  // ── Desi street-style adjectives ──────────────────────────────
  static const List<String> _adjectives = [
    // 'Brave', 'Silent', 'Wild', 'Swift', 'Quiet', 'Bold', 'Dark', 'Clever',
    // 'Fierce', 'Noble', 'Sly', 'Mighty', 'Mystic', 'Golden', 'Silver', 'Iron',
    // 'Crimson', 'Azure', 'Storm', 'Phantom', 'Lunar', 'Solar', 'Cosmic',
    // 'Shadow', 'Radiant', 'Frosty', 'Ancient', 'Blazing', 'Crystal', 'Amber',
    // 'Rusty', 'Lucky', 'Witty', 'Sleek', 'Shiny', 'Dusty', 'Fuzzy', 'Grumpy',

    // Classic desi slang
    'Bindaas', 'Jugaadu', 'Tapori', 'Jhakaas', 'Dhinchak', 'Fattu',
    'Lafanga', 'Bawla', 'Ghatak', 'Mast', 'Ullu', 'Dhamaal', 'Bakaiti',
    'Shandaar', 'Zabardast', 'Luchha', 'Khatarnak', 'Fauji', 'Besharam',
    'Gunda', 'Chhichhora', 'Desi', 'Chaalu', 'Tofani', 'Ghamandi',
    'Pagal', 'Badmaash', 'Bhaukali', 'Kamina', 'Nakli', 'Dhasu', 'Makkaar',
    'Awaara', 'Kadak', 'Chillar', 'Pataka', 'Bawaal', 'Ghanchakkar',
    // Bollywood / pop culture inspired
    'Baahubali', 'Rowdy', 'Jhakkas', 'Dilwala', 'Dabangg', 'Bhai',
    'Singham', 'Khiladi', 'Gabbar', 'Mogambo', 'Don', 'Munna',
    // Mythology & legends
    'Veera', 'Arjuna', 'Bheem', 'Ravan', 'Hanumaan', 'Kali',
    // Quirky & creative
    'Chutkila', 'Rocket', 'Bijlee', 'Masaledar', 'Chatpata', 'Spicy',
    'Ulti', 'Seedha', 'Random', 'Viral', 'Trending', 'OG',
  ];

  // ── Indian animals + mythological creatures ────────────────────
  static const List<String> _animals = [
    // 'Badger', 'Panther', 'Fox', 'Wolf', 'Eagle', 'Hawk', 'Bear', 'Tiger',
    // 'Lion', 'Raven', 'Falcon', 'Cobra', 'Viper', 'Jaguar', 'Lynx', 'Otter',
    // 'Puma', 'Shark', 'Drake', 'Phoenix', 'Griffin', 'Hyena', 'Bison', 'Boar',
    // 'Crane', 'Dolphin', 'Gecko', 'Heron', 'Iguana', 'Jackal', 'Kestrel',
    // 'Lemur', 'Mink', 'Newt', 'Osprey', 'Quail', 'Rhino', 'Sloth', 'Tapir',

    // Real Indian animals
    'Sher', 'Bhaalu', 'Bandar', 'Saanp', 'Haathi', 'Cheetah', 'Nilgai',
    'Bagheera', 'Langur', 'Bhediya', 'Murga', 'Gadha',
    'Ghoda', 'Billi', 'Kauwa', 'Tota', 'Maina', 'Naagin',
    'Bakra', 'Bhains', 'Gidh', 'Titli', 'Chuhaa', 'Khargosh',
    'Bagh', 'Genda', 'Girgit', 'Magarmach', 'Peacock', 'Bulbul',
    'Kabootar', 'Chipkali', 'Macchar',
    // Mythological & creative creatures
    'Garuda', 'Nandi', 'Airavat', 'Sheshnaag', 'Jalparee', 'Yaksha',
    'Pisaach', 'Vetal', 'Rakshasa', 'Devdoot',
    // Street food (for extra desi chaos 😄)
    'VadaPav', 'PaniPuri', 'Jalebi', 'Samosa', 'Chaatwala', 'Lassi',
    'Dhokla', 'Puchka', 'Kachori', 'Bhajiya',
    // Cricket legends (as nouns)
    'Sachin', 'Dhoni', 'Kohli', 'Bumrah', 'Jadeja',
  ];

  // ── Fully creative standalone names (used 20% of the time) ─────
  static const List<String> _creativeNames = [
    'Chai Pe Charcha', 'Jugaad King', 'Biryani Boss', 'Ghee Wala Ghost',
    'Thali Thakur', 'Masala Mama', 'Pani Puri Punk', 'Dosa Don',
    'Rickshaw Rider', 'Lassi Launda', 'Mirchi Maharaj', 'Nimbu Ninja',
    'Kadak Chai', 'Ulti Seedhi', 'Aam Aadmi', 'Chai Sutta Bhai',
    'Bhai Log', 'Pappu Passing', 'Lallan Top', 'Gappu Groot',
    'Zero Figure', 'Ek Number', 'Dus Baje', 'Sab Changa Si',
    'Aloo Paratha', 'Butter Chicken', 'Rajma Chawal', 'Dal Makhani',
    'Midnight Maggi', 'Cutting Chai', 'Tapri Talks', 'Jugaadu Genius',
  ];
}
