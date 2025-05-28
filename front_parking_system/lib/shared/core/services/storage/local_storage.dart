import '../../models/user.dart';

class LocalStorage {
  static Future<void> saveToken(String token) async {}

  static Future<String?> getToken() async {
    return null;
  }

  static Future<void> saveUser(User user) async {}

  static Future<User?> getUser() async {
    return null;
  }

  static Future<void> clearAll() async {}
}
