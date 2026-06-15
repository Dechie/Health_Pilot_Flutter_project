import 'package:flutter/foundation.dart';

@immutable
class SuggestedPeer {
  final int id;
  final String fullName;
  final int? age;
  final int score;
  final String reason;

  const SuggestedPeer({
    required this.id,
    required this.fullName,
    required this.age,
    required this.score,
    required this.reason,
  });

  factory SuggestedPeer.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>;
    return SuggestedPeer(
      id: user['id'] as int,
      fullName: user['full_name'] as String,
      age: user['age'] as int?,
      score: json['score'] as int,
      reason: json['reason'] as String? ?? '',
    );
  }
}

class ConnectionRequest {
  final int id;
  final int fromUserId;
  final String fromUserFullName;
  final int toUserId;
  final String status;
  final DateTime createdAt;

  const ConnectionRequest({
    required this.id,
    required this.fromUserId,
    required this.fromUserFullName,
    required this.toUserId,
    required this.status,
    required this.createdAt,
  });

  factory ConnectionRequest.fromJson(Map<String, dynamic> json) {
    final requester = json['requester'] as Map<String, dynamic>?;
    final receiver = json['receiver'] as Map<String, dynamic>?;
    return ConnectionRequest(
      id: json['id'] as int,
      fromUserId: requester?['id'] as int? ?? json['from_user_id'] as int,
      fromUserFullName:
          requester?['full_name'] as String? ?? json['from_user_full_name'] as String? ?? '',
      toUserId: receiver?['id'] as int? ?? json['to_user_id'] as int,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

enum CommunityStatus { idle, loading, loaded, error }
