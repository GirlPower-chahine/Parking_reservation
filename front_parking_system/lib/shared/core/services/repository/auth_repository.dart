import 'package:dio/dio.dart';
import '../../models/auth/login/login_dto.dart';
import '../../models/auth/login/login_response_dto.dart';
import '../../models/auth/register/register_dto.dart';
import '../../models/auth/register/register_response_dto.dart';

class AuthRepository {
  final Dio _dio;
  final String baseUrl = 'http://localhost:8081/api';

  AuthRepository() : _dio = Dio() {
    _dio.options.headers = {
      'Content-Type': 'application/json',
    };
    _dio.interceptors.add(LogInterceptor(
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
        logPrint: (object) {
          // TODO: Implémenter le logging
        }));
  }

  Future<LoginResponseDTO> login(LoginDTO loginDTO) async {
    // TODO: Implémenter la logique de connexion
    throw UnimplementedError('Login not implemented yet');
  }

  Future<RegisterResponseDTO> register(RegisterDTO registerDTO) async {
    // TODO: Implémenter la logique d'inscription
    throw UnimplementedError('Register not implemented yet');
  }
}
