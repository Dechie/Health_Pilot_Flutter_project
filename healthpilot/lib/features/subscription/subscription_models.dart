import 'package:flutter/foundation.dart';

@immutable
class SubscriptionPlan {
  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.priceMonthly,
    required this.features,
    required this.isPremium,
  });

  final String id;
  final String name;
  final double priceMonthly;
  final List<String> features;
  final bool isPremium;

  String get formattedPrice =>
      priceMonthly == 0 ? 'Free' : '\$${priceMonthly.toStringAsFixed(2)}/month';

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) =>
      SubscriptionPlan(
        id: json['id'] as String,
        name: json['name'] as String,
        priceMonthly: (json['price_monthly'] as num).toDouble(),
        features: (json['features'] as List<dynamic>)
            .map((e) => e as String)
            .toList(),
        isPremium: json['is_premium'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price_monthly': priceMonthly,
        'features': features,
        'is_premium': isPremium,
      };
}

@immutable
class SubscriptionStatus {
  const SubscriptionStatus({
    required this.planId,
    required this.isActive,
    this.expiresAt,
  });

  final String planId;
  final bool isActive;
  final DateTime? expiresAt;

  factory SubscriptionStatus.fromJson(Map<String, dynamic> json) =>
      SubscriptionStatus(
        planId: json['plan_id'] as String,
        isActive: json['is_active'] as bool? ?? false,
        expiresAt: json['expires_at'] != null
            ? DateTime.parse(json['expires_at'] as String)
            : null,
      );
}
