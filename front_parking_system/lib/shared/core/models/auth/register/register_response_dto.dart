class RegisterResponseDTO {
  final String message;

  RegisterResponseDTO({required this.message});

  factory RegisterResponseDTO.fromJson(Map<String, dynamic> json) {
    return RegisterResponseDTO(
      message: json['message'] ?? 'Inscription réussie',
    );
  }
}
