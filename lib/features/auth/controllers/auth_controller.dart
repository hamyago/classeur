import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/user_model.dart';
import '../../../core/models/provider_model.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/services/firestore_service.dart';

enum AuthState { unknown, unauthenticated, authenticated }

class AuthController extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  final NotificationService _notificationService = NotificationService();

  AuthState _state = AuthState.unknown;
  String? _verificationId;
  int? _resendToken;
  String? _role;
  UserModel? _user;
  ProviderModel? _provider;
  bool _isLoading = false;
  String? _error;

  AuthState get state => _state;
  String? get role => _role;
  UserModel? get user => _user;
  ProviderModel? get provider => _provider;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isUser => _role == AppConstants.roleUser;
  bool get isProvider => _role == AppConstants.roleProvider;

  AuthController() {
    _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _state = AuthState.unauthenticated;
      _role = null;
      _user = null;
      _provider = null;
    } else {
      _role = await _authService.getUserRole(firebaseUser.uid);
      if (_role == AppConstants.roleUser) {
        _user = await _authService.getUser(firebaseUser.uid);
      } else if (_role == AppConstants.roleProvider) {
        _provider = await _authService.getProvider(firebaseUser.uid);
      }
      _state = AuthState.authenticated;

      // Update FCM token
      final token = await _notificationService.getToken();
      if (token != null && _role != null) {
        final collection = _role == AppConstants.roleUser
            ? AppConstants.usersCollection
            : AppConstants.providersCollection;
        await _firestoreService.updateUser(
          firebaseUser.uid,
          {'fcm_token': token},
        );
      }
    }
    notifyListeners();
  }

  Future<void> sendOtp(String phoneNumber) async {
    _setLoading(true);
    _error = null;
    await _authService.verifyPhone(
      phoneNumber: phoneNumber,
      onAutoVerify: (credential) async {
        await _authService.signInWithOtp(
          verificationId: credential.verificationId ?? '',
          otp: credential.smsCode ?? '',
        );
      },
      onCodeSent: (verificationId, resendToken) {
        _verificationId = verificationId;
        _resendToken = resendToken;
        _setLoading(false);
      },
      onError: (e) {
        _error = _friendlyAuthError(e.code);
        _setLoading(false);
      },
    );
  }

  Future<bool> verifyOtp(String otp) async {
    if (_verificationId == null) return false;
    _setLoading(true);
    _error = null;
    try {
      await _authService.signInWithOtp(
        verificationId: _verificationId!,
        otp: otp,
      );
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _friendlyAuthError(e.code);
      _setLoading(false);
      return false;
    }
  }

  Future<void> resendOtp(String phoneNumber) => sendOtp(phoneNumber);

  Future<void> completeUserProfile({
    required String name,
    required String phone,
  }) async {
    final uid = _authService.currentUser?.uid;
    if (uid == null) return;
    await _authService.createUserProfile(
      uid: uid,
      phone: phone,
      name: name,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.prefUserRole, AppConstants.roleUser);
    _role = AppConstants.roleUser;
    _user = await _authService.getUser(uid);
    notifyListeners();
  }

  Future<void> completeProviderProfile({
    required String name,
    required String phone,
    required List<String> serviceTypes,
    required double latitude,
    required double longitude,
  }) async {
    final uid = _authService.currentUser?.uid;
    if (uid == null) return;
    await _authService.createProviderProfile(
      uid: uid,
      phone: phone,
      name: name,
      serviceTypes: serviceTypes,
      latitude: latitude,
      longitude: longitude,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        AppConstants.prefUserRole, AppConstants.roleProvider);
    _role = AppConstants.roleProvider;
    _provider = await _authService.getProvider(uid);
    notifyListeners();
  }

  Future<void> signOut() async {
    await _authService.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.prefUserRole);
  }

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  String _friendlyAuthError(String code) {
    switch (code) {
      case 'invalid-phone-number':
        return 'Numéro de téléphone invalide.';
      case 'invalid-verification-code':
        return 'Code incorrect. Vérifiez et réessayez.';
      case 'session-expired':
        return 'Session expirée. Renvoyez le code.';
      case 'too-many-requests':
        return 'Trop de tentatives. Réessayez plus tard.';
      default:
        return 'Une erreur est survenue. Réessayez.';
    }
  }
}
