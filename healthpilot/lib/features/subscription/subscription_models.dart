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

/// Valid `payment_method` values accepted by `POST /subscriptions/payment/`.
const List<String> kPaymentMethods = [
  'bank',
  'paypal',
  'credit_card',
  'stripe',
  'other',
];

/// A payment record — `/subscriptions/payment/...`.
class Payment {
  const Payment({
    required this.id,
    required this.amount,
    required this.currency,
    required this.paymentMethod,
    required this.status,
    this.externalRef,
    this.membershipDays,
    this.createdAt,
  });

  final int id;
  final double amount;
  final String currency;
  final String paymentMethod;
  final String status; // pending | succeeded | failed | …
  final String? externalRef;
  final int? membershipDays;
  final DateTime? createdAt;

  static double _toDouble(dynamic v) => v is num
      ? v.toDouble()
      : double.tryParse('${v ?? ''}') ?? 0;

  factory Payment.fromJson(Map<String, dynamic> json) => Payment(
        id: (json['id'] as num?)?.toInt() ?? 0,
        amount: _toDouble(json['amount']),
        currency: json['currency'] as String? ?? 'USD',
        paymentMethod: json['payment_method'] as String? ?? '',
        status: json['status'] as String? ?? '',
        externalRef: json['external_ref'] as String?,
        membershipDays: (json['membership_days'] as num?)?.toInt(),
        createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
      );
}
