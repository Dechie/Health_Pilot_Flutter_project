class AuthTokens {
  final String access;
  final String refresh;
  final String firstName;
  final String lastName;

  const AuthTokens({
    required this.access,
    required this.refresh,
    this.firstName = '',
    this.lastName = '',
  });

  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;
    return AuthTokens(
      access: json['access'] as String,
      refresh: json['refresh'] as String,
      firstName: user?['first_name'] as String? ?? '',
      lastName: user?['last_name'] as String? ?? '',
    );
  }
}
