class UserIdentityModel {
  final String userId;
  final String name;
  final String roomCode;

  const UserIdentityModel({
    required this.userId,
    required this.name,
    required this.roomCode,
  });

  factory UserIdentityModel.fromMap(Map<String, dynamic> map) =>
      UserIdentityModel(
        userId: map['userId'] as String,
        name: map['name'] as String,
        roomCode: map['roomCode'] as String,
      );

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'name': name,
        'roomCode': roomCode,
      };

  /// First letter of name (e.g. "B" for "Brave Badger")
  String get initial => name.isNotEmpty ? name[0].toUpperCase() : '?';
}
