import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/models/provider_model.dart';
import '../../../core/models/service_type_model.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/services/location_service.dart';
import '../../../core/constants/app_constants.dart';

class HomeController extends ChangeNotifier {
  final FirestoreService _db = FirestoreService();
  final LocationService _location = LocationService();

  LatLng? _userPosition;
  List<ProviderModel> _providers = [];
  String? _selectedServiceFilter;
  StreamSubscription? _providersSub;
  bool _isLoading = true;
  String? _error;

  LatLng? get userPosition => _userPosition;
  List<ProviderModel> get providers => _providers;
  String? get selectedServiceFilter => _selectedServiceFilter;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<ServiceTypeModel> get serviceTypes => ServiceTypeModel.defaults;

  Set<Marker> get markers {
    final markers = <Marker>{};
    for (final p in _providers) {
      markers.add(Marker(
        markerId: MarkerId(p.id),
        position: LatLng(p.latitude, p.longitude),
        infoWindow: InfoWindow(
          title: p.name,
          snippet:
              '${p.rating.toStringAsFixed(1)}★ — ${p.distanceKm?.toStringAsFixed(1)} km',
        ),
      ));
    }
    return markers;
  }

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    final pos = await _location.getCurrentPosition();
    if (pos == null) {
      _error = 'Impossible d\'obtenir votre position. Activez le GPS.';
      _isLoading = false;
      notifyListeners();
      return;
    }

    _userPosition = LatLng(pos.latitude, pos.longitude);
    _listenToProviders();
    _isLoading = false;
    notifyListeners();
  }

  void setServiceFilter(String? id) {
    _selectedServiceFilter = id;
    _listenToProviders();
    notifyListeners();
  }

  void _listenToProviders() {
    if (_userPosition == null) return;
    _providersSub?.cancel();
    _providersSub = _db
        .nearbyProviders(
          latitude: _userPosition!.latitude,
          longitude: _userPosition!.longitude,
          radiusKm: AppConstants.searchRadiusKm,
          serviceTypeFilter: _selectedServiceFilter,
        )
        .listen((list) {
      _providers = list;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _providersSub?.cancel();
    super.dispose();
  }
}
