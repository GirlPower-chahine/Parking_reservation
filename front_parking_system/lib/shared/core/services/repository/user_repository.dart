
import '../../models/user.dart';
import '../api/api_service.dart';

class UserRepository {
  final ApiService apiService;

  UserRepository(this.apiService);

  Future<List<User>> fetchUsers({String? role}) async {
    final path = role == null ? '/users' : '/users/$role';

    try {
      final response = await apiService.get(path);
      final data = response.data as List;

      if (data.isEmpty) {
        return [];
      }

      return data.map((e) => User.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }
}
