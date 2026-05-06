class ServiceTypeModel {
  final String id;
  final String name;
  final String description;
  final String icon;
  final double basePrice;
  final String color;

  const ServiceTypeModel({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.basePrice,
    required this.color,
  });

  factory ServiceTypeModel.fromMap(Map<String, dynamic> map) =>
      ServiceTypeModel(
        id: map['id'] as String,
        name: map['name'] as String,
        description: map['description'] as String,
        icon: map['icon'] as String,
        basePrice: (map['base_price'] as num).toDouble(),
        color: map['color'] as String,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'description': description,
        'icon': icon,
        'base_price': basePrice,
        'color': color,
      };

  // Predefined service types for Côte d'Ivoire market
  static List<ServiceTypeModel> get defaults => [
        const ServiceTypeModel(
          id: 'mechanic',
          name: 'Mécanicien',
          description: 'Panne moteur, freins, transmission',
          icon: '🔧',
          basePrice: 5000,
          color: '#FF6B35',
        ),
        const ServiceTypeModel(
          id: 'towing',
          name: 'Remorquage',
          description: 'Transport de véhicule immobilisé',
          icon: '🚛',
          basePrice: 10000,
          color: '#4299E1',
        ),
        const ServiceTypeModel(
          id: 'tire',
          name: 'Vulcanisateur',
          description: 'Crevaison, changement de pneu',
          icon: '🔩',
          basePrice: 3000,
          color: '#48BB78',
        ),
        const ServiceTypeModel(
          id: 'electrical',
          name: 'Électricien auto',
          description: 'Problèmes électriques, alternateur',
          icon: '⚡',
          basePrice: 6000,
          color: '#F6AD55',
        ),
        const ServiceTypeModel(
          id: 'battery',
          name: 'Batterie',
          description: 'Batterie à plat, démarrage',
          icon: '🔋',
          basePrice: 4000,
          color: '#9F7AEA',
        ),
        const ServiceTypeModel(
          id: 'fuel',
          name: 'Carburant',
          description: 'Livraison de carburant d\'urgence',
          icon: '⛽',
          basePrice: 2000,
          color: '#FC8181',
        ),
        const ServiceTypeModel(
          id: 'locksmith',
          name: 'Serrurier auto',
          description: 'Clé perdue, portière bloquée',
          icon: '🔑',
          basePrice: 5000,
          color: '#68D391',
        ),
        const ServiceTypeModel(
          id: 'other',
          name: 'Autre',
          description: 'Tout autre type de dépannage',
          icon: '🛠️',
          basePrice: 5000,
          color: '#63B3ED',
        ),
      ];
}
