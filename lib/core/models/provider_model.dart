import 'package:cloud_firestore/cloud_firestore.dart';

class ProviderModel {
  final String id;
  final String phone;
  final String name;
  final String? photoUrl;
  final List<String> serviceTypes;
  final double latitude;
  final double longitude;
  final bool isAvailable;
  final bool isVerified;
  final bool isActive;
  final double rating;
  final int totalInterventions;
  final double totalEarnings;
  final String? idCardUrl;
  final String? proLicenseUrl;
  final bool hasActiveSubscription;
  final DateTime? subscriptionExpiry;
  final String? fcmToken;
  final DateTime createdAt;
  final DateTime? lastSeen;

  // computed in UI
  double? distanceKm;

  ProviderModel({
    required this.id,
    required this.phone,
    required this.name,
    this.photoUrl,
    required this.serviceTypes,
    required this.latitude,
    required this.longitude,
    this.isAvailable = true,
    this.isVerified = false,
    this.isActive = true,
    this.rating = 5.0,
    this.totalInterventions = 0,
    this.totalEarnings = 0,
    this.idCardUrl,
    this.proLicenseUrl,
    this.hasActiveSubscription = false,
    this.subscriptionExpiry,
    this.fcmToken,
    required this.createdAt,
    this.lastSeen,
    this.distanceKm,
  });

  bool get isOnline =>
      lastSeen != null &&
      DateTime.now().difference(lastSeen!).inMinutes < 10;

  factory ProviderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProviderModel(
      id: doc.id,
      phone: data['phone'] as String,
      name: data['name'] as String,
      photoUrl: data['photo_url'] as String?,
      serviceTypes: List<String>.from(data['service_types'] as List? ?? []),
      latitude: (data['latitude'] as num).toDouble(),
      longitude: (data['longitude'] as num).toDouble(),
      isAvailable: data['is_available'] as bool? ?? true,
      isVerified: data['is_verified'] as bool? ?? false,
      isActive: data['is_active'] as bool? ?? true,
      rating: (data['rating'] as num?)?.toDouble() ?? 5.0,
      totalInterventions: data['total_interventions'] as int? ?? 0,
      totalEarnings: (data['total_earnings'] as num?)?.toDouble() ?? 0,
      idCardUrl: data['id_card_url'] as String?,
      proLicenseUrl: data['pro_license_url'] as String?,
      hasActiveSubscription:
          data['has_active_subscription'] as bool? ?? false,
      subscriptionExpiry: data['subscription_expiry'] != null
          ? (data['subscription_expiry'] as Timestamp).toDate()
          : null,
      fcmToken: data['fcm_token'] as String?,
      createdAt: (data['created_at'] as Timestamp).toDate(),
      lastSeen: data['last_seen'] != null
          ? (data['last_seen'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'phone': phone,
        'name': name,
        'photo_url': photoUrl,
        'service_types': serviceTypes,
        'latitude': latitude,
        'longitude': longitude,
        'is_available': isAvailable,
        'is_verified': isVerified,
        'is_active': isActive,
        'rating': rating,
        'total_interventions': totalInterventions,
        'total_earnings': totalEarnings,
        'id_card_url': idCardUrl,
        'pro_license_url': proLicenseUrl,
        'has_active_subscription': hasActiveSubscription,
        'subscription_expiry': subscriptionExpiry != null
            ? Timestamp.fromDate(subscriptionExpiry!)
            : null,
        'fcm_token': fcmToken,
        'created_at': Timestamp.fromDate(createdAt),
        'last_seen': lastSeen != null ? Timestamp.fromDate(lastSeen!) : null,
      };

  ProviderModel copyWith({
    bool? isAvailable,
    double? latitude,
    double? longitude,
    double? rating,
    int? totalInterventions,
    double? totalEarnings,
    DateTime? lastSeen,
    String? fcmToken,
  }) =>
      ProviderModel(
        id: id,
        phone: phone,
        name: name,
        photoUrl: photoUrl,
        serviceTypes: serviceTypes,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        isAvailable: isAvailable ?? this.isAvailable,
        isVerified: isVerified,
        isActive: isActive,
        rating: rating ?? this.rating,
        totalInterventions: totalInterventions ?? this.totalInterventions,
        totalEarnings: totalEarnings ?? this.totalEarnings,
        idCardUrl: idCardUrl,
        proLicenseUrl: proLicenseUrl,
        hasActiveSubscription: hasActiveSubscription,
        subscriptionExpiry: subscriptionExpiry,
        fcmToken: fcmToken ?? this.fcmToken,
        createdAt: createdAt,
        lastSeen: lastSeen ?? this.lastSeen,
      );
}
