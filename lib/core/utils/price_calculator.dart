import '../constants/app_constants.dart';

class PriceCalculator {
  PriceCalculator._();

  static PriceEstimate calculate({
    required String serviceTypeId,
    required double distanceKm,
    required bool hasSubscription,
  }) {
    final basePrice =
        AppConstants.baseServicePrices[serviceTypeId] ?? 5000.0;
    final kmCostFull = distanceKm * AppConstants.kmRate;
    final kmCostCharged = hasSubscription ? 0.0 : kmCostFull;
    final subtotal = basePrice + kmCostCharged;
    final commission = subtotal * AppConstants.commissionRate;
    final total = subtotal;

    return PriceEstimate(
      basePrice: basePrice,
      distanceKm: distanceKm,
      kmCostFull: kmCostFull,
      kmCostCharged: kmCostCharged,
      kmCostWaived: hasSubscription,
      subtotal: subtotal,
      commission: commission,
      total: total,
    );
  }

  static String formatFcfa(double amount) {
    final formatted = amount
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+$)'),
          (m) => '${m[1]} ',
        );
    return '$formatted FCFA';
  }
}

class PriceEstimate {
  final double basePrice;
  final double distanceKm;
  final double kmCostFull;
  final double kmCostCharged;
  final bool kmCostWaived;
  final double subtotal;
  final double commission;
  final double total;

  const PriceEstimate({
    required this.basePrice,
    required this.distanceKm,
    required this.kmCostFull,
    required this.kmCostCharged,
    required this.kmCostWaived,
    required this.subtotal,
    required this.commission,
    required this.total,
  });
}
