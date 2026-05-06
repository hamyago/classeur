class AppConstants {
  AppConstants._();

  static const String appName = 'Auto-SOS';
  static const String companyName = 'Oyop MT';
  static const String supportPhone = '+2250700000000';
  static const String supportWhatsapp = '+2250700000000';

  // Tarification
  static const double commissionRate = 0.15; // 15%
  static const double kmRate = 300.0; // 300 FCFA/km
  static const double searchRadiusKm = 3.0; // 3 km

  // Prix de base par service (FCFA)
  static const Map<String, double> baseServicePrices = {
    'mechanic': 5000,
    'towing': 10000,
    'tire': 3000,
    'electrical': 6000,
    'battery': 4000,
    'fuel': 2000,
    'locksmith': 5000,
    'other': 5000,
  };

  // Firestore collections
  static const String usersCollection = 'users';
  static const String providersCollection = 'providers';
  static const String interventionsCollection = 'interventions';
  static const String serviceTypesCollection = 'service_types';
  static const String reviewsCollection = 'reviews';
  static const String transactionsCollection = 'transactions';
  static const String configCollection = 'config';

  // SharedPreferences keys
  static const String prefUserRole = 'user_role';
  static const String prefOnboardingDone = 'onboarding_done';
  static const String prefFcmToken = 'fcm_token';

  // Intervention statuses
  static const String statusPending = 'pending';
  static const String statusAccepted = 'accepted';
  static const String statusInProgress = 'in_progress';
  static const String statusCompleted = 'completed';
  static const String statusCancelled = 'cancelled';

  // User roles
  static const String roleUser = 'user';
  static const String roleProvider = 'provider';
}
