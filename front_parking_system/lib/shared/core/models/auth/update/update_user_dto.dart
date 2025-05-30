class UpdateUserDTO {
  final String username;
  final String role;

  UpdateUserDTO({required this.username, required this.role});

  Map<String, dynamic> toJson() => {
    'username': username,
    'role': role,
  };
}