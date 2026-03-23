class User {
  final int? userId;
  final String username;
  final String name;
  final String password;
  final String role;

  User({
    this.userId,
    required this.username,
    required this.name,
    required this.password,
    required this.role,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'username': username,
      'name': name,
      'password': password,
      'role': role,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      userId: map['userId'],
      username: map['username'],
      name: map['name'],
      password: map['password'],
      role: map['role'],
    );
  }
}
