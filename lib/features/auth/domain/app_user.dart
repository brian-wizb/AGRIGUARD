class AppUser {
  const AppUser({
    required this.id,
    required this.username,
    required this.preferredLanguage,
    required this.createdAt,
  });

  final int id;
  final String username;
  final String preferredLanguage;
  final DateTime createdAt;

  AppUser copyWith({String? preferredLanguage}) {
    return AppUser(
      id: id,
      username: username,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      createdAt: createdAt,
    );
  }
}
