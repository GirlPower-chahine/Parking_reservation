import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:parking_system/screens/administration_screen/admin_panel.dart';
import 'package:parking_system/screens/employee_screen/employee_panel.dart';
import 'package:parking_system/screens/login_screen/login_bloc/login_bloc.dart';
import 'package:parking_system/screens/login_screen/login_screen.dart';
import 'package:parking_system/shared/core/services/api/api_service.dart';
import 'package:parking_system/shared/core/services/repository/auth_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const storage = FlutterSecureStorage();
  final token = await storage.read(key: 'auth_token');
  final role = await storage.read(key: 'user_role');

  final apiService = ApiService();
  final authRepository = AuthRepository(apiService);

  if (token != null) {
    apiService.setAuthToken(token);
  }

  runApp(
    RepositoryProvider<AuthRepository>.value(
      value: authRepository,
      child: MyApp(token: token, role: role, apiService: apiService),
    ),
  );
}

class MyApp extends StatelessWidget {
  final String? token;
  final String? role;
  final ApiService apiService;

  const MyApp({
    super.key,
    this.token,
    this.role,
    required this.apiService,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LoginBloc>(
      create: (context) => LoginBloc(
        authRepository: RepositoryProvider.of<AuthRepository>(context),
      ),
      child: MaterialApp(
        title: 'Parking Reservation',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          primarySwatch: Colors.blue,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1E3A8A),
            primary: const Color(0xFF1E3A8A),
            secondary: const Color(0xFF3B82F6),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF1E3A8A),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
        ),
        home: BlocBuilder<LoginBloc, LoginState>(
          builder: (context, state) {
            if (state.status == LoginStatus.success && state.user?.role != null) {
              return _getScreenForRole(state.user!.role);
            }

            if (token != null && role != null) {
              return _getScreenForRole(role!);
            }

            return const LoginScreen();
          },
        ),
      ),
    );
  }

  Widget _getScreenForRole(String role) {
    switch (role.toUpperCase()) {
      case 'MANAGER':
        return const EmployeePanel(isManager: true);
      case 'EMPLOYEE':
        return const EmployeePanel(isManager: false);
      case 'SECRETARY':
        return const AdminPanel();
      default:
        return const LoginScreen();
    }
  }
}