import 'package:flutter/material.dart';

import '../../shared/core/models/user.dart';
import '../../shared/core/services/api/api_service.dart';
import '../../shared/core/services/repository/user_repository.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  List<User> users = [];
  String? message;
  String? currentRole;
  final userRepository = UserRepository(ApiService());

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers({String? role}) async {
    final fetchedUsers = await userRepository.fetchUsers(role: role);

    setState(() {
      currentRole = role;
      if (fetchedUsers.isEmpty) {
        message = 'Aucun ${_getRoleLabel(role)} trouvé.';
        users = [];
      } else {
        message = null;
        users = fetchedUsers;
      }
    });
  }

  String _getRoleLabel(String? role) {
    switch (role) {
      case 'managers':
        return 'manager';
      case 'employees':
        return 'employé';
      case 'secretaries':
        return 'secrétaire';
      default:
        return 'utilisateur';
    }
  }

  Color _getRoleColor(String role) {
    switch (role.toUpperCase()) {
      case 'MANAGER':
        return Colors.purple;
      case 'SECRETARY':
        return Colors.orange;
      case 'EMPLOYEE':
      default:
        return const Color(0xFF1E3A8A);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            spacing: 8,
            children: [
              ElevatedButton(onPressed: () => _loadUsers(), child: const Text('Tous')),
              ElevatedButton(onPressed: () => _loadUsers(role: 'employees'), child: const Text('Employés')),
              ElevatedButton(onPressed: () => _loadUsers(role: 'secretaries'), child: const Text('Secrétaires')),
              ElevatedButton(onPressed: () => _loadUsers(role: 'managers'), child: const Text('Managers')),
            ],
          ),
        ),
        Expanded(
          child: Container(
            color: Colors.grey[100],
            child: message != null
                ? Center(child: Text(message!, style: const TextStyle(fontSize: 16)))
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                final roleColor = _getRoleColor(user.role);

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: roleColor,
                      child: Text(
                        user.username.substring(0, 2).toUpperCase() ?? '',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(user.username),
                    subtitle: Text(user.username),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: roleColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: roleColor.withOpacity(0.3)),
                      ),
                      child: Text(
                        user.role ?? '',
                        style: TextStyle(
                          color: roleColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
