class RankedRider {
  final String riderId;
  final double distanceKm;
  final double score;

  RankedRider({
    required this.riderId,
    required this.distanceKm,
    required this.score,
  });

  factory RankedRider.fromJson(Map<String, dynamic> json) {
    return RankedRider(
      riderId: json['riderId'] ?? '',
      distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 0.0,
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'riderId': riderId,
      'distanceKm': distanceKm,
      'score': score,
    };
  }
}
