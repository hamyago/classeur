import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/models/intervention_model.dart';
import '../../../core/models/provider_model.dart';
import '../../../core/models/service_type_model.dart';
import '../../../core/models/user_model.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/services/location_service.dart';
import '../../../core/utils/price_calculator.dart';

enum RequestStep { selectService, selectProvider, confirm }

class RequestController extends ChangeNotifier {
  final FirestoreService _db = FirestoreService();
  final LocationService _location = LocationService();

  RequestStep _step = RequestStep.selectService;
  ServiceTypeModel? _selectedService;
  ProviderModel? _selectedProvider;
  PriceEstimate? _estimate;
  String _paymentMethod = 'orange_money';
  bool _isLoading = false;
  String? _error;
  String? _createdInterventionId;

  LatLng? _userPosition;
  String? _userAddress;

  RequestStep get step => _step;
  ServiceTypeModel? get selectedService => _selectedService;
  ProviderModel? get selectedProvider => _selectedProvider;
  PriceEstimate? get estimate => _estimate;
  String get paymentMethod => _paymentMethod;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get createdInterventionId => _createdInterventionId;
  LatLng? get userPosition => _userPosition;
  String? get userAddress => _userAddress;

  List<ServiceTypeModel> get services => ServiceTypeModel.defaults;

  Future<void> initialize({ProviderModel? preselectedProvider}) async {
    final pos = await _location.getCurrentPosition();
    if (pos != null) {
      _userPosition = LatLng(pos.latitude, pos.longitude);
      _userAddress = await _location.getAddressFromCoords(
          pos.latitude, pos.longitude);
    }
    if (preselectedProvider != null) {
      _selectedProvider = preselectedProvider;
    }
    notifyListeners();
  }

  void selectService(ServiceTypeModel service) {
    _selectedService = service;
    _step = RequestStep.selectProvider;
    notifyListeners();
  }

  void selectProvider(ProviderModel provider) {
    _selectedProvider = provider;
    _updateEstimate(hasSubscription: false);
    _step = RequestStep.confirm;
    notifyListeners();
  }

  void setPaymentMethod(String method) {
    _paymentMethod = method;
    notifyListeners();
  }

  void _updateEstimate({required bool hasSubscription}) {
    if (_selectedService == null || _selectedProvider == null) return;
    final dist = _location.distanceBetween(
      _userPosition?.latitude ?? 0,
      _userPosition?.longitude ?? 0,
      _selectedProvider!.latitude,
      _selectedProvider!.longitude,
    );
    _estimate = PriceCalculator.calculate(
      serviceTypeId: _selectedService!.id,
      distanceKm: dist,
      hasSubscription: hasSubscription,
    );
  }

  void refreshEstimate(UserModel? user) {
    _updateEstimate(hasSubscription: user?.hasSubscription ?? false);
    notifyListeners();
  }

  void goBack() {
    if (_step == RequestStep.selectProvider) {
      _step = RequestStep.selectService;
    } else if (_step == RequestStep.confirm) {
      _step = RequestStep.selectProvider;
    }
    notifyListeners();
  }

  Future<bool> submitRequest({
    required UserModel user,
  }) async {
    if (_selectedService == null || _selectedProvider == null ||
        _estimate == null || _userPosition == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final intervention = InterventionModel(
        id: '',
        userId: user.id,
        providerId: _selectedProvider!.id,
        serviceTypeId: _selectedService!.id,
        serviceTypeName: _selectedService!.name,
        status: 'pending',
        userLatitude: _userPosition!.latitude,
        userLongitude: _userPosition!.longitude,
        userAddress: _userAddress,
        description: null,
        basePrice: _estimate!.basePrice,
        distanceKm: _estimate!.distanceKm,
        kmCost: _estimate!.kmCostFull,
        subtotal: _estimate!.subtotal,
        commission: _estimate!.commission,
        totalPrice: _estimate!.total,
        kmCostWaived: _estimate!.kmCostWaived,
        paymentMethod: _paymentMethod,
        createdAt: DateTime.now(),
        userName: user.name,
        userPhone: user.phone,
        providerName: _selectedProvider!.name,
        providerPhone: _selectedProvider!.phone,
      );

      _createdInterventionId = await _db.createIntervention(intervention);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Erreur lors de la création de la demande. Réessayez.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
