import 'package:cloud_firestore/cloud_firestore.dart';

class InterventionModel {
  final String id;
  final String userId;
  final String? providerId;
  final String serviceTypeId;
  final String serviceTypeName;
  final String status;
  final double userLatitude;
  final double userLongitude;
  final String? userAddress;
  final double? providerLatitude;
  final double? providerLongitude;
  final String? description;
  final double basePrice;
  final double distanceKm;
  final double kmCost;
  final double subtotal;
  final double commission;
  final double totalPrice;
  final bool kmCostWaived; // abonnement utilisateur actif
  final String paymentMethod;
  final String paymentStatus;
  final String? paymentReference;
  final double? userRating;
  final double? providerRating;
  final String? userReview;
  final String? providerReview;
  final DateTime createdAt;
  final DateTime? acceptedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;

  // Joined data
  final String? userName;
  final String? userPhone;
  final String? providerName;
  final String? providerPhone;

  const InterventionModel({
    required this.id,
    required this.userId,
    this.providerId,
    required this.serviceTypeId,
    required this.serviceTypeName,
    required this.status,
    required this.userLatitude,
    required this.userLongitude,
    this.userAddress,
    this.providerLatitude,
    this.providerLongitude,
    this.description,
    required this.basePrice,
    required this.distanceKm,
    required this.kmCost,
    required this.subtotal,
    required this.commission,
    required this.totalPrice,
    required this.kmCostWaived,
    required this.paymentMethod,
    this.paymentStatus = 'pending',
    this.paymentReference,
    this.userRating,
    this.providerRating,
    this.userReview,
    this.providerReview,
    required this.createdAt,
    this.acceptedAt,
    this.startedAt,
    this.completedAt,
    this.userName,
    this.userPhone,
    this.providerName,
    this.providerPhone,
  });

  factory InterventionModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return InterventionModel(
      id: doc.id,
      userId: d['user_id'] as String,
      providerId: d['provider_id'] as String?,
      serviceTypeId: d['service_type_id'] as String,
      serviceTypeName: d['service_type_name'] as String,
      status: d['status'] as String,
      userLatitude: (d['user_latitude'] as num).toDouble(),
      userLongitude: (d['user_longitude'] as num).toDouble(),
      userAddress: d['user_address'] as String?,
      providerLatitude: (d['provider_latitude'] as num?)?.toDouble(),
      providerLongitude: (d['provider_longitude'] as num?)?.toDouble(),
      description: d['description'] as String?,
      basePrice: (d['base_price'] as num).toDouble(),
      distanceKm: (d['distance_km'] as num).toDouble(),
      kmCost: (d['km_cost'] as num).toDouble(),
      subtotal: (d['subtotal'] as num).toDouble(),
      commission: (d['commission'] as num).toDouble(),
      totalPrice: (d['total_price'] as num).toDouble(),
      kmCostWaived: d['km_cost_waived'] as bool? ?? false,
      paymentMethod: d['payment_method'] as String,
      paymentStatus: d['payment_status'] as String? ?? 'pending',
      paymentReference: d['payment_reference'] as String?,
      userRating: (d['user_rating'] as num?)?.toDouble(),
      providerRating: (d['provider_rating'] as num?)?.toDouble(),
      userReview: d['user_review'] as String?,
      providerReview: d['provider_review'] as String?,
      createdAt: (d['created_at'] as Timestamp).toDate(),
      acceptedAt: d['accepted_at'] != null
          ? (d['accepted_at'] as Timestamp).toDate()
          : null,
      startedAt: d['started_at'] != null
          ? (d['started_at'] as Timestamp).toDate()
          : null,
      completedAt: d['completed_at'] != null
          ? (d['completed_at'] as Timestamp).toDate()
          : null,
      userName: d['user_name'] as String?,
      userPhone: d['user_phone'] as String?,
      providerName: d['provider_name'] as String?,
      providerPhone: d['provider_phone'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'user_id': userId,
        'provider_id': providerId,
        'service_type_id': serviceTypeId,
        'service_type_name': serviceTypeName,
        'status': status,
        'user_latitude': userLatitude,
        'user_longitude': userLongitude,
        'user_address': userAddress,
        'provider_latitude': providerLatitude,
        'provider_longitude': providerLongitude,
        'description': description,
        'base_price': basePrice,
        'distance_km': distanceKm,
        'km_cost': kmCost,
        'subtotal': subtotal,
        'commission': commission,
        'total_price': totalPrice,
        'km_cost_waived': kmCostWaived,
        'payment_method': paymentMethod,
        'payment_status': paymentStatus,
        'payment_reference': paymentReference,
        'user_rating': userRating,
        'provider_rating': providerRating,
        'user_review': userReview,
        'provider_review': providerReview,
        'created_at': Timestamp.fromDate(createdAt),
        'accepted_at':
            acceptedAt != null ? Timestamp.fromDate(acceptedAt!) : null,
        'started_at':
            startedAt != null ? Timestamp.fromDate(startedAt!) : null,
        'completed_at':
            completedAt != null ? Timestamp.fromDate(completedAt!) : null,
        'user_name': userName,
        'user_phone': userPhone,
        'provider_name': providerName,
        'provider_phone': providerPhone,
      };

  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isInProgress => status == 'in_progress';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';
  bool get isActive =>
      status == 'pending' || status == 'accepted' || status == 'in_progress';
}
