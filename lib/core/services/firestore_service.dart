import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/app_constants.dart';
import '../models/intervention_model.dart';
import '../models/provider_model.dart';
import '../models/user_model.dart';
import '../models/review_model.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;

  // ── Providers ──────────────────────────────────────────────────────────────

  Stream<List<ProviderModel>> nearbyProviders({
    required double latitude,
    required double longitude,
    required double radiusKm,
    String? serviceTypeFilter,
  }) {
    Query<Map<String, dynamic>> query = _db
        .collection(AppConstants.providersCollection)
        .where('is_available', isEqualTo: true)
        .where('is_active', isEqualTo: true)
        .where('is_verified', isEqualTo: true);

    if (serviceTypeFilter != null) {
      query =
          query.where('service_types', arrayContains: serviceTypeFilter);
    }

    return query.snapshots().map((snap) {
      return snap.docs
          .map(ProviderModel.fromFirestore)
          .where((p) {
            final dist = _haversine(
              latitude, longitude, p.latitude, p.longitude,
            );
            if (dist <= radiusKm) {
              p.distanceKm = dist;
              return true;
            }
            return false;
          })
          .toList()
        ..sort((a, b) =>
            (a.distanceKm ?? 0).compareTo(b.distanceKm ?? 0));
    });
  }

  Future<void> updateProviderLocation(
    String uid,
    double lat,
    double lng,
  ) =>
      _db.collection(AppConstants.providersCollection).doc(uid).update({
        'latitude': lat,
        'longitude': lng,
        'last_seen': FieldValue.serverTimestamp(),
      });

  Future<void> updateProviderAvailability(String uid, bool available) =>
      _db.collection(AppConstants.providersCollection).doc(uid).update({
        'is_available': available,
        'last_seen': FieldValue.serverTimestamp(),
      });

  // ── Interventions ───────────────────────────────────────────────────────────

  Future<String> createIntervention(InterventionModel intervention) async {
    final ref = await _db
        .collection(AppConstants.interventionsCollection)
        .add(intervention.toFirestore());
    return ref.id;
  }

  Stream<InterventionModel?> watchIntervention(String id) => _db
      .collection(AppConstants.interventionsCollection)
      .doc(id)
      .snapshots()
      .map((s) => s.exists ? InterventionModel.fromFirestore(s) : null);

  Future<void> updateInterventionStatus(
    String id,
    String status, {
    String? providerId,
    String? providerName,
    String? providerPhone,
  }) async {
    final updates = <String, dynamic>{'status': status};
    if (providerId != null) updates['provider_id'] = providerId;
    if (providerName != null) updates['provider_name'] = providerName;
    if (providerPhone != null) updates['provider_phone'] = providerPhone;

    switch (status) {
      case AppConstants.statusAccepted:
        updates['accepted_at'] = FieldValue.serverTimestamp();
      case AppConstants.statusInProgress:
        updates['started_at'] = FieldValue.serverTimestamp();
      case AppConstants.statusCompleted:
        updates['completed_at'] = FieldValue.serverTimestamp();
    }

    await _db
        .collection(AppConstants.interventionsCollection)
        .doc(id)
        .update(updates);
  }

  Future<void> updateProviderLocationInIntervention(
    String interventionId,
    double lat,
    double lng,
  ) =>
      _db
          .collection(AppConstants.interventionsCollection)
          .doc(interventionId)
          .update({
        'provider_latitude': lat,
        'provider_longitude': lng,
      });

  Stream<List<InterventionModel>> userInterventions(String userId) => _db
      .collection(AppConstants.interventionsCollection)
      .where('user_id', isEqualTo: userId)
      .orderBy('created_at', descending: true)
      .snapshots()
      .map((s) => s.docs.map(InterventionModel.fromFirestore).toList());

  Stream<List<InterventionModel>> providerInterventions(
    String providerId,
  ) =>
      _db
          .collection(AppConstants.interventionsCollection)
          .where('provider_id', isEqualTo: providerId)
          .orderBy('created_at', descending: true)
          .snapshots()
          .map((s) => s.docs.map(InterventionModel.fromFirestore).toList());

  Stream<List<InterventionModel>> pendingInterventions(
    String serviceType,
  ) =>
      _db
          .collection(AppConstants.interventionsCollection)
          .where('status', isEqualTo: AppConstants.statusPending)
          .where('service_type_id', isEqualTo: serviceType)
          .orderBy('created_at', descending: true)
          .snapshots()
          .map((s) => s.docs.map(InterventionModel.fromFirestore).toList());

  // ── Reviews ─────────────────────────────────────────────────────────────────

  Future<void> submitReview(ReviewModel review) =>
      _db.collection(AppConstants.reviewsCollection).add(review.toFirestore());

  Stream<List<ReviewModel>> providerReviews(String providerId) => _db
      .collection(AppConstants.reviewsCollection)
      .where('to_user_id', isEqualTo: providerId)
      .orderBy('created_at', descending: true)
      .limit(20)
      .snapshots()
      .map((s) => s.docs.map(ReviewModel.fromFirestore).toList());

  // ── Users ────────────────────────────────────────────────────────────────────

  Stream<UserModel> watchUser(String uid) => _db
      .collection(AppConstants.usersCollection)
      .doc(uid)
      .snapshots()
      .map(UserModel.fromFirestore);

  Future<void> updateUser(String uid, Map<String, dynamic> data) =>
      _db.collection(AppConstants.usersCollection).doc(uid).update(data);

  // ── Helpers ──────────────────────────────────────────────────────────────────

  double _haversine(double lat1, double lng1, double lat2, double lng2) {
    const r = 6371.0;
    final dLat = (lat2 - lat1) * 3.14159265358979 / 180;
    final dLng = (lng2 - lng1) * 3.14159265358979 / 180;
    final a = (dLat / 2) * (dLat / 2) +
        _cosDeg(lat1) * _cosDeg(lat2) * (dLng / 2) * (dLng / 2);
    return r * 2 * _atan2(a);
  }

  double _cosDeg(double deg) =>
      // simplified cos approximation for short distances
      1 - (deg * 3.14159265358979 / 180) * (deg * 3.14159265358979 / 180) / 2;

  double _atan2(double a) => (a < 1) ? a : 1;
}
