import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/models/intervention_model.dart';
import '../../../core/models/provider_model.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/services/location_service.dart';

class ProviderController extends ChangeNotifier {
  final FirestoreService _db = FirestoreService();
  final LocationService _location = LocationService();

  ProviderModel? _provider;
  List<InterventionModel> _pendingRequests = [];
  List<InterventionModel> _myInterventions = [];
  bool _isAvailable = true;
  bool _isLoading = false;
  StreamSubscription<Position>? _locationSub;
  StreamSubscription? _pendingSub;
  StreamSubscription? _mySub;

  ProviderModel? get provider => _provider;
  List<InterventionModel> get pendingRequests => _pendingRequests;
  List<InterventionModel> get myInterventions => _myInterventions;
  bool get isAvailable => _isAvailable;
  bool get isLoading => _isLoading;

  InterventionModel? get activeIntervention => _myInterventions
      .where((i) => i.isActive)
      .firstOrNull;

  double get todayEarnings {
    final today = DateTime.now();
    return _myInterventions
        .where((i) =>
            i.isCompleted &&
            i.completedAt != null &&
            i.completedAt!.day == today.day &&
            i.completedAt!.month == today.month &&
            i.completedAt!.year == today.year)
        .fold(0.0, (sum, i) => sum + (i.totalPrice * 0.85));
  }

  double get totalEarnings =>
      _myInterventions
          .where((i) => i.isCompleted)
          .fold(0.0, (sum, i) => sum + (i.totalPrice * 0.85));

  void initialize(ProviderModel provider) {
    _provider = provider;
    _isAvailable = provider.isAvailable;
    _startLocationUpdates();
    _listenPendingRequests();
    _listenMyInterventions();
  }

  void _startLocationUpdates() {
    _locationSub = _location.positionStream().listen((pos) {
      if (_provider != null) {
        _db.updateProviderLocation(_provider!.id, pos.latitude, pos.longitude);
        _provider = _provider!.copyWith(
          latitude: pos.latitude,
          longitude: pos.longitude,
        );
        notifyListeners();
      }
    });
  }

  void _listenPendingRequests() {
    if (_provider == null) return;
    // Listen to pending interventions matching at least one of provider's service types
    if (_provider!.serviceTypes.isEmpty) return;
    _pendingSub = _db
        .pendingInterventions(_provider!.serviceTypes.first)
        .listen((list) {
      _pendingRequests = list
          .where((i) => _provider!.serviceTypes.contains(i.serviceTypeId))
          .toList();
      notifyListeners();
    });
  }

  void _listenMyInterventions() {
    if (_provider == null) return;
    _mySub = _db.providerInterventions(_provider!.id).listen((list) {
      _myInterventions = list;
      notifyListeners();
    });
  }

  Future<void> toggleAvailability() async {
    if (_provider == null) return;
    _isAvailable = !_isAvailable;
    notifyListeners();
    await _db.updateProviderAvailability(_provider!.id, _isAvailable);
  }

  Future<void> acceptIntervention(String interventionId) async {
    if (_provider == null) return;
    _isLoading = true;
    notifyListeners();
    await _db.updateInterventionStatus(
      interventionId,
      'accepted',
      providerId: _provider!.id,
      providerName: _provider!.name,
      providerPhone: _provider!.phone,
    );
    _isLoading = false;
    notifyListeners();
  }

  Future<void> startIntervention(String id) =>
      _db.updateInterventionStatus(id, 'in_progress');

  Future<void> completeIntervention(String id) =>
      _db.updateInterventionStatus(id, 'completed');

  Future<void> declineIntervention(String id) =>
      _db.updateInterventionStatus(id, 'cancelled');

  @override
  void dispose() {
    _locationSub?.cancel();
    _pendingSub?.cancel();
    _mySub?.cancel();
    super.dispose();
  }
}
