class DeliveryStatusHistory {
  final String id;
  final String deliveryId;
  final String status;
  final String? changedByUserId;
  final String? reason;
  final DateTime? createdAt;

  DeliveryStatusHistory({
    required this.id,
    required this.deliveryId,
    required this.status,
    this.changedByUserId,
    this.reason,
    this.createdAt,
  });

  factory DeliveryStatusHistory.fromJson(Map<String, dynamic> json) {
    return DeliveryStatusHistory(
      id: json['id'] ?? '',
      deliveryId: json['deliveryId'] ?? '',
      status: json['status'] ?? 'PENDING',
      changedByUserId: json['changedByUserId'],
      reason: json['reason'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'deliveryId': deliveryId,
      'status': status,
      'changedByUserId': changedByUserId,
      'reason': reason,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
