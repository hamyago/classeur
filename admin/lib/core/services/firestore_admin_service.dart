import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreAdminService {
  final _db = FirebaseFirestore.instance;

  // ── Stats ──────────────────────────────────────────────────────────────────

  Stream<Map<String, dynamic>> dashboardStats() async* {
    await for (final _ in Stream.periodic(const Duration(seconds: 30))
        .startWith(null)) {
      final results = await Future.wait([
        _db.collection('users').count().get(),
        _db.collection('providers').count().get(),
        _db.collection('interventions').count().get(),
        _db.collection('interventions')
            .where('status', isEqualTo: 'completed')
            .count()
            .get(),
        _db.collection('interventions')
            .where('status', whereIn: ['pending', 'accepted', 'in_progress'])
            .count()
            .get(),
        _db.collection('transactions').get(),
      ]);

      final txSnap = results[5] as QuerySnapshot;
      double totalGross = 0;
      double totalCommission = 0;
      for (final doc in txSnap.docs) {
        final d = doc.data() as Map<String, dynamic>;
        totalGross += (d['gross_amount'] as num?)?.toDouble() ?? 0;
        totalCommission += (d['commission'] as num?)?.toDouble() ?? 0;
      }

      yield {
        'total_users': (results[0] as AggregateQuerySnapshot).count ?? 0,
        'total_providers': (results[1] as AggregateQuerySnapshot).count ?? 0,
        'total_interventions': (results[2] as AggregateQuerySnapshot).count ?? 0,
        'completed_interventions': (results[3] as AggregateQuerySnapshot).count ?? 0,
        'active_interventions': (results[4] as AggregateQuerySnapshot).count ?? 0,
        'total_gross': totalGross,
        'total_commission': totalCommission,
        'total_net': totalGross - totalCommission,
      };
    }
  }

  // ── Providers ──────────────────────────────────────────────────────────────

  Stream<QuerySnapshot> providers() =>
      _db.collection('providers').orderBy('created_at', descending: true).snapshots();

  Future<void> verifyProvider(String uid) =>
      _db.collection('providers').doc(uid).update({'is_verified': true});

  Future<void> toggleProviderBlock(String uid, bool block) =>
      _db.collection('providers').doc(uid).update({
        'is_active': !block,
        'is_available': !block,
      });

  // ── Users ──────────────────────────────────────────────────────────────────

  Stream<QuerySnapshot> users() =>
      _db.collection('users').orderBy('created_at', descending: true).snapshots();

  Future<void> toggleUserBlock(String uid, bool block) =>
      _db.collection('users').doc(uid).update({'is_blocked': block});

  // ── Interventions ──────────────────────────────────────────────────────────

  Stream<QuerySnapshot> interventions({String? statusFilter}) {
    Query q = _db.collection('interventions').orderBy('created_at', descending: true);
    if (statusFilter != null) q = q.where('status', isEqualTo: statusFilter);
    return q.limit(100).snapshots();
  }

  // ── Transactions ───────────────────────────────────────────────────────────

  Stream<QuerySnapshot> transactions() =>
      _db.collection('transactions').orderBy('created_at', descending: true).snapshots();
}

extension StreamX<T> on Stream<T> {
  Stream<T> startWith(T value) async* {
    yield value;
    yield* this;
  }
}
