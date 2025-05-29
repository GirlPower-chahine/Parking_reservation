import '../../user.dart';

class LoginResponseDTO {
  final String token;
  final String type;
  final String role;
  final String userId;
  final User user;

  LoginResponseDTO({
    required this.token,
    required this.type,
    required this.role,
    required this.userId,
    required this.user,
  });

  factory LoginResponseDTO.fromJson(Map<String, dynamic> json) {
    return LoginResponseDTO(
      token: json['token'] ?? '',
      type: json['type'] ?? '',
      role: json['role'] ?? '',
      userId: json['userId'] ?? '',
      user: User.fromJson(json),
    );
  }
}