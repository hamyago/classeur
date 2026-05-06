import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/app_constants.dart';
import '../models/user_model.dart';
import '../models/provider_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Step 1 — send OTP
  Future<void> verifyPhone({
    required String phoneNumber,
    required void Function(PhoneAuthCredential) onAutoVerify,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(FirebaseAuthException) onError,
    int? resendToken,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: onAutoVerify,
      verificationFailed: onError,
      codeSent: onCodeSent,
      codeAutoRetrievalTimeout: (_) {},
      forceResendingToken: resendToken,
      timeout: const Duration(seconds: 60),
    );
  }

  // Step 2 — verify OTP
  Future<UserCredential> signInWithOtp({
    required String verificationId,
    required String otp,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: otp,
    );
    return _auth.signInWithCredential(credential);
  }

  Future<void> signOut() => _auth.signOut();

  // Determine role after login
  Future<String?> getUserRole(String uid) async {
    final userDoc =
        await _db.collection(AppConstants.usersCollection).doc(uid).get();
    if (userDoc.exists) return AppConstants.roleUser;

    final providerDoc =
        await _db.collection(AppConstants.providersCollection).doc(uid).get();
    if (providerDoc.exists) return AppConstants.roleProvider;

    return null;
  }

  // Create user profile
  Future<void> createUserProfile({
    required String uid,
    required String phone,
    required String name,
  }) async {
    await _db.collection(AppConstants.usersCollection).doc(uid).set(
          UserModel(
            id: uid,
            phone: phone,
            name: name,
            createdAt: DateTime.now(),
          ).toFirestore(),
        );
  }

  // Create provider profile
  Future<void> createProviderProfile({
    required String uid,
    required String phone,
    required String name,
    required List<String> serviceTypes,
    required double latitude,
    required double longitude,
  }) async {
    await _db.collection(AppConstants.providersCollection).doc(uid).set(
          ProviderModel(
            id: uid,
            phone: phone,
            name: name,
            serviceTypes: serviceTypes,
            latitude: latitude,
            longitude: longitude,
            createdAt: DateTime.now(),
          ).toFirestore(),
        );
  }

  Future<UserModel?> getUser(String uid) async {
    final doc =
        await _db.collection(AppConstants.usersCollection).doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  Future<ProviderModel?> getProvider(String uid) async {
    final doc = await _db
        .collection(AppConstants.providersCollection)
        .doc(uid)
        .get();
    if (!doc.exists) return null;
    return ProviderModel.fromFirestore(doc);
  }
}
