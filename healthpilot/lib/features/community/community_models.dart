import 'package:flutter/foundation.dart';

/// A community support group — `/community/groups/`.
@immutable
class CommunityGroup {
  const CommunityGroup({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.conditionTags = const [],
    this.memberCount = 0,
    this.isMember = false,
    this.isActive = true,
  });

  final int id;
  final String name;
  final String slug;
  final String? description;
  final List<String> conditionTags;
  final int memberCount;
  final bool isMember;
  final bool isActive;

  CommunityGroup copyWith({bool? isMember, int? memberCount}) => CommunityGroup(
        id: id,
        name: name,
        slug: slug,
        description: description,
        conditionTags: conditionTags,
        memberCount: memberCount ?? this.memberCount,
        isMember: isMember ?? this.isMember,
        isActive: isActive,
      );

  factory CommunityGroup.fromJson(Map<String, dynamic> json) => CommunityGroup(
        id: (json['id'] as num).toInt(),
        name: json['name'] as String? ?? '',
        slug: json['slug'] as String? ?? '',
        description: json['description'] as String?,
        conditionTags: (json['condition_tags'] as List<dynamic>? ?? [])
            .map((e) => e.toString())
            .toList(),
        memberCount: (json['member_count'] as num?)?.toInt() ?? 0,
        isMember: json['is_member'] as bool? ?? false,
        isActive: json['is_active'] as bool? ?? true,
      );
}

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
  final String toUserFullName;
  final String status;
  final DateTime createdAt;

  const ConnectionRequest({
    required this.id,
    required this.fromUserId,
    required this.fromUserFullName,
    required this.toUserId,
    required this.toUserFullName,
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
      toUserFullName:
          receiver?['full_name'] as String? ?? json['to_user_full_name'] as String? ?? '',
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// The other person's user ID from the perspective of [currentUserId].
  int peerIdOf(String currentUserId) =>
      fromUserId.toString() == currentUserId ? toUserId : fromUserId;

  /// The other person's full name from the perspective of [currentUserId].
  String peerNameOf(String currentUserId) =>
      fromUserId.toString() == currentUserId ? toUserFullName : fromUserFullName;
}

enum CommunityStatus { idle, loading, loaded, error }
