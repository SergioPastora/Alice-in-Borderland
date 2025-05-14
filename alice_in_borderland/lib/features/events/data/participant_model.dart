import 'package:alice_in_borderland/features/events/domain/entities/participant_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ParticipantModel extends ParticipantEntity {
  ParticipantModel({required String uid, required DateTime joinedAt})
      : super(uid: uid, joinedAt: joinedAt);

  factory ParticipantModel.fromSnapshot(DocumentSnapshot snap) {
    final data = snap.data()! as Map<String, dynamic>;
    return ParticipantModel(
      uid: snap.id,
      joinedAt: (data['joinedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() => {
        'joinedAt': Timestamp.fromDate(joinedAt),
      };

  ParticipantEntity toEntity() {
    return ParticipantEntity(
      uid: uid,
      joinedAt: joinedAt,
    );
  }
}
