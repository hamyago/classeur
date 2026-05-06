class VehicleModel {
  final String id;
  final String brand;
  final String model;
  final String year;
  final String licensePlate;
  final String? color;

  const VehicleModel({
    required this.id,
    required this.brand,
    required this.model,
    required this.year,
    required this.licensePlate,
    this.color,
  });

  factory VehicleModel.fromMap(Map<String, dynamic> map) => VehicleModel(
        id: map['id'] as String,
        brand: map['brand'] as String,
        model: map['model'] as String,
        year: map['year'] as String,
        licensePlate: map['license_plate'] as String,
        color: map['color'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'brand': brand,
        'model': model,
        'year': year,
        'license_plate': licensePlate,
        'color': color,
      };

  String get displayName => '$brand $model ($year)';
}
