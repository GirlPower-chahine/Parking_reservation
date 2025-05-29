import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:parking_system/screens/administration_screen/admin_panel.dart';
import 'package:parking_system/screens/login_screen/login_bloc/login_bloc.dart';
import 'package:parking_system/screens/login_screen/login_screen.dart';
import 'package:parking_system/shared/core/services/api/api_service.dart';
import 'package:parking_system/shared/core/services/repository/auth_repository.dart';
import 'package:parking_system/shared/core/services/storage/local_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorage.clearAll();


  final storage = const FlutterSecureStorage();
  final token = await storage.read(key: 'auth_token');
  final role = await storage.read(key: 'user_role');

  final apiService = ApiService(baseUrl: 'http://192.168.1.165:8080/api');
  final authRepository = AuthRepository(apiService);

  if (token != null) {
    apiService.setAuthToken(token);
  }

  runApp(MyApp(
    authRepository: authRepository,
    token: token,
    role: role,
  ));
}

class MyApp extends StatelessWidget {
  final AuthRepository authRepository;
  final String? token;
  final String? role;

  const MyApp({
    super.key,
    required this.authRepository,
    this.token,
    this.role,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LoginBloc>(
      create: (context) => LoginBloc(authRepository: authRepository),
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
        home: _getInitialScreen(),
      ),
    );
  }

  Widget _getInitialScreen() {
    if (token != null && role == 'MANAGER') {
      return AdminPanel();
    }

    return const LoginScreen();
  }
}
