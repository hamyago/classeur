import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String id;
  final String interventionId;
  final String fromUserId;
  final String toUserId;
  final String fromRole; // 'user' | 'provider'
  final double rating;
  final String? comment;
  final DateTime createdAt;

  const ReviewModel({
    required this.id,
    required this.interventionId,
    required this.fromUserId,
    required this.toUserId,
    required this.fromRole,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  factory ReviewModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return ReviewModel(
      id: doc.id,
      interventionId: d['intervention_id'] as String,
      fromUserId: d['from_user_id'] as String,
      toUserId: d['to_user_id'] as String,
      fromRole: d['from_role'] as String,
      rating: (d['rating'] as num).toDouble(),
      comment: d['comment'] as String?,
      createdAt: (d['created_at'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'intervention_id': interventionId,
        'from_user_id': fromUserId,
        'to_user_id': toUserId,
        'from_role': fromRole,
        'rating': rating,
        'comment': comment,
        'created_at': Timestamp.fromDate(createdAt),
      };
}
