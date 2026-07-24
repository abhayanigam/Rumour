import 'package:cloud_firestore/cloud_firestore.dart';

class RoomModel {
  final String code;
  final DateTime createdAt;
  final int memberCount;

  const RoomModel({
    required this.code,
    required this.createdAt,
    required this.memberCount,
  });

  factory RoomModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return RoomModel(
      code: doc.id,
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      memberCount: (data['memberCount'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
        'createdAt': FieldValue.serverTimestamp(),
        'memberCount': memberCount,
      };
}
