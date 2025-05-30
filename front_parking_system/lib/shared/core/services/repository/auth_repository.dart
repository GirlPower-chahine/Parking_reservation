import '../../models/auth/login/login_dto.dart';
import '../../models/auth/login/login_response_dto.dart';
import '../../models/auth/register/register_dto.dart';
import '../../models/auth/register/register_response_dto.dart';
import '../api/api_service.dart';
import '../storage/local_storage.dart';

class AuthRepository {
  final ApiService apiService;

  AuthRepository(this.apiService);

  Future<LoginResponseDTO> login(LoginDTO loginDTO) async {
    final response = await apiService.post('/auth/login', loginDTO.toJson());
    final loginResponse = LoginResponseDTO.fromJson(response.data);

    await LocalStorage.saveToken(loginResponse.token);
    await LocalStorage.saveUser(loginResponse.user);

    return loginResponse;
  }

  Future<RegisterResponseDTO> register(RegisterDTO registerDTO) async {
    final response = await apiService.post('/auth/register', registerDTO.toJson());
    return RegisterResponseDTO.fromJson(response.data);
  }
}
