import 'package:cloud_firestore/cloud_firestore.dart';
import 'vehicle_model.dart';

class UserModel {
  final String id;
  final String phone;
  final String? whatsapp;
  final String? name;
  final String? photoUrl;
  final List<VehicleModel> vehicles;
  final bool hasActiveSubscription;
  final DateTime? subscriptionExpiry;
  final double rating;
  final int totalInterventions;
  final bool isBlocked;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.phone,
    this.whatsapp,
    this.name,
    this.photoUrl,
    this.vehicles = const [],
    this.hasActiveSubscription = false,
    this.subscriptionExpiry,
    this.rating = 5.0,
    this.totalInterventions = 0,
    this.isBlocked = false,
    required this.createdAt,
  });

  bool get hasSubscription =>
      hasActiveSubscription &&
      subscriptionExpiry != null &&
      subscriptionExpiry!.isAfter(DateTime.now());

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      phone: data['phone'] as String,
      whatsapp: data['whatsapp'] as String?,
      name: data['name'] as String?,
      photoUrl: data['photo_url'] as String?,
      vehicles: ((data['vehicles'] as List<dynamic>?) ?? [])
          .map((v) => VehicleModel.fromMap(v as Map<String, dynamic>))
          .toList(),
      hasActiveSubscription:
          data['has_active_subscription'] as bool? ?? false,
      subscriptionExpiry: data['subscription_expiry'] != null
          ? (data['subscription_expiry'] as Timestamp).toDate()
          : null,
      rating: (data['rating'] as num?)?.toDouble() ?? 5.0,
      totalInterventions: data['total_interventions'] as int? ?? 0,
      isBlocked: data['is_blocked'] as bool? ?? false,
      createdAt: (data['created_at'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'phone': phone,
        'whatsapp': whatsapp,
        'name': name,
        'photo_url': photoUrl,
        'vehicles': vehicles.map((v) => v.toMap()).toList(),
        'has_active_subscription': hasActiveSubscription,
        'subscription_expiry': subscriptionExpiry != null
            ? Timestamp.fromDate(subscriptionExpiry!)
            : null,
        'rating': rating,
        'total_interventions': totalInterventions,
        'is_blocked': isBlocked,
        'created_at': Timestamp.fromDate(createdAt),
      };

  UserModel copyWith({
    String? name,
    String? photoUrl,
    String? whatsapp,
    List<VehicleModel>? vehicles,
    bool? hasActiveSubscription,
    DateTime? subscriptionExpiry,
    double? rating,
    int? totalInterventions,
    bool? isBlocked,
  }) =>
      UserModel(
        id: id,
        phone: phone,
        whatsapp: whatsapp ?? this.whatsapp,
        name: name ?? this.name,
        photoUrl: photoUrl ?? this.photoUrl,
        vehicles: vehicles ?? this.vehicles,
        hasActiveSubscription:
            hasActiveSubscription ?? this.hasActiveSubscription,
        subscriptionExpiry: subscriptionExpiry ?? this.subscriptionExpiry,
        rating: rating ?? this.rating,
        totalInterventions: totalInterventions ?? this.totalInterventions,
        isBlocked: isBlocked ?? this.isBlocked,
        createdAt: createdAt,
      );
}
