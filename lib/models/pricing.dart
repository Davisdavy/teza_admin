class PricingConfiguration {
  final String id;
  final double baseFee;
  final double pricePerKilometer;
  final double pricePerMinute;
  final double minimumDeliveryFee;
  final double maximumDeliveryFee;
  final bool surgeEnabled;
  final double peakHourMultiplier;
  final double weekendMultiplier;
  final double nightMultiplier;
  final String? updatedBy;
  final DateTime updatedAt;

  PricingConfiguration({
    required this.id,
    required this.baseFee,
    required this.pricePerKilometer,
    required this.pricePerMinute,
    required this.minimumDeliveryFee,
    required this.maximumDeliveryFee,
    required this.surgeEnabled,
    required this.peakHourMultiplier,
    required this.weekendMultiplier,
    required this.nightMultiplier,
    this.updatedBy,
    required this.updatedAt,
  });

  factory PricingConfiguration.fromJson(Map<String, dynamic> json) {
    return PricingConfiguration(
      id: json['id'] ?? '',
      baseFee: (json['baseFee'] as num?)?.toDouble() ?? 0.0,
      pricePerKilometer: (json['pricePerKilometer'] as num?)?.toDouble() ?? 0.0,
      pricePerMinute: (json['pricePerMinute'] as num?)?.toDouble() ?? 0.0,
      minimumDeliveryFee: (json['minimumDeliveryFee'] as num?)?.toDouble() ?? 0.0,
      maximumDeliveryFee: (json['maximumDeliveryFee'] as num?)?.toDouble() ?? 0.0,
      surgeEnabled: json['surgeEnabled'] ?? false,
      peakHourMultiplier: (json['peakHourMultiplier'] as num?)?.toDouble() ?? 1.0,
      weekendMultiplier: (json['weekendMultiplier'] as num?)?.toDouble() ?? 1.0,
      nightMultiplier: (json['nightMultiplier'] as num?)?.toDouble() ?? 1.0,
      updatedBy: json['updatedBy'],
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'baseFee': baseFee,
      'pricePerKilometer': pricePerKilometer,
      'pricePerMinute': pricePerMinute,
      'minimumDeliveryFee': minimumDeliveryFee,
      'maximumDeliveryFee': maximumDeliveryFee,
      'surgeEnabled': surgeEnabled,
      'peakHourMultiplier': peakHourMultiplier,
      'weekendMultiplier': weekendMultiplier,
      'nightMultiplier': nightMultiplier,
    };
  }
}

class PricingEstimate {
  final double baseFee;
  final double distanceFee;
  final double timeFee;
  final double multiplier;
  final double finalFee;

  PricingEstimate({
    required this.baseFee,
    required this.distanceFee,
    required this.timeFee,
    required this.multiplier,
    required this.finalFee,
  });

  factory PricingEstimate.fromJson(Map<String, dynamic> json) {
    return PricingEstimate(
      baseFee: (json['baseFee'] as num?)?.toDouble() ?? 0.0,
      distanceFee: (json['distanceFee'] as num?)?.toDouble() ?? 0.0,
      timeFee: (json['timeFee'] as num?)?.toDouble() ?? 0.0,
      multiplier: (json['multiplier'] as num?)?.toDouble() ?? 1.0,
      finalFee: (json['finalFee'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
