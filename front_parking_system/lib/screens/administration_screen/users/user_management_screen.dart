import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parking_system/screens/administration_screen/users/user_management_bloc/user_management_bloc.dart';


import '../../../shared/core/models/user.dart';
import '../../../shared/core/services/api/api_service.dart';
import '../../../shared/core/services/repository/user_repository.dart';


class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UserManagementBloc(
        userRepository: UserRepository(ApiService()),
      )..add(LoadUsersRequested()),
      child: const UserManagementView(),
    );
  }
}

class UserManagementView extends StatelessWidget {
  const UserManagementView({super.key});

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

  void _showEditUserDialog(BuildContext context, User user) {
    final usernameController = TextEditingController(text: user.username);
    String selectedRole = user.role;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Modifier l\'utilisateur'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: 'Nom d\'utilisateur',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedRole,
              decoration: const InputDecoration(
                labelText: 'Rôle',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'EMPLOYEE', child: Text('Employé')),
                DropdownMenuItem(value: 'SECRETARY', child: Text('Secrétaire')),
                DropdownMenuItem(value: 'MANAGER', child: Text('Manager')),
              ],
              onChanged: (value) {
                if (value != null) {
                  selectedRole = value;
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              if (usernameController.text.isNotEmpty) {
                context.read<UserManagementBloc>().add(
                  UpdateUserRequested(
                    userId: user.id,
                    data: {
                      'username': usernameController.text,
                      'role': selectedRole,
                    },
                  ),
                );
                Navigator.of(dialogContext).pop();
              }
            },
            child: const Text('Modifier'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, User user) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Êtes-vous sûr de vouloir supprimer l\'utilisateur "${user.username}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context.read<UserManagementBloc>().add(
                DeleteUserRequested(userId: user.id),
              );
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () => context.read<UserManagementBloc>().add(LoadUsersRequested()),
                  child: const Text('Tous'),
                ),
                ElevatedButton(
                  onPressed: () => context.read<UserManagementBloc>().add(LoadUsersRequested(role: 'employees')),
                  child: const Text('Employés'),
                ),
                ElevatedButton(
                  onPressed: () => context.read<UserManagementBloc>().add(LoadUsersRequested(role: 'secretaries')),
                  child: const Text('Secrétaires'),
                ),
                ElevatedButton(
                  onPressed: () => context.read<UserManagementBloc>().add(LoadUsersRequested(role: 'managers')),
                  child: const Text('Managers'),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.grey[100],
              child: BlocConsumer<UserManagementBloc, UserManagementState>(
                listener: (context, state) {
                  if (state.status == UserManagementStatus.error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.exception?.message ?? 'Une erreur est survenue'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state.status == UserManagementStatus.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state.message != null) {
                    return Center(
                      child: Text(
                        state.message!,
                        style: const TextStyle(fontSize: 16),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.users.length,
                    itemBuilder: (context, index) {
                      final user = state.users[index];
                      final roleColor = _getRoleColor(user.role);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: roleColor,
                            child: Text(
                              user.username.substring(0, 2).toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(user.username),
                          subtitle: Text(user.username),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: roleColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: roleColor.withOpacity(0.3)),
                                ),
                                child: Text(
                                  user.role,
                                  style: TextStyle(
                                    color: roleColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    _showEditUserDialog(context, user);
                                  } else if (value == 'delete') {
                                    _showDeleteConfirmationDialog(context, user);
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit, size: 18),
                                        SizedBox(width: 8),
                                        Text('Modifier'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete, color: Colors.red, size: 18),
                                        SizedBox(width: 8),
                                        Text('Supprimer', style: TextStyle(color: Colors.red)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}