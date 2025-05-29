import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parking_system/screens/administration_screen/register_bloc/register_bloc.dart';
import '../../shared/core/services/repository/auth_repository.dart';
import '../login_screen/login_bloc/login_bloc.dart';
import '../login_screen/login_screen.dart';
import 'add_user_screen.dart';

class AdminPanel extends StatefulWidget {
  // final String token;
  //
  // const AdminPanel({
  //   super.key,
  //   required this.token,
  // });

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}


class _AdminPanelState extends State<AdminPanel> {
  int _selectedIndex = 0;
  final List<String> _titles = ['Places de Parking', 'Réservations', 'Utilisateurs', 'Ajouter un utilisateur'];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFF1E3A8A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E3A8A),
        elevation: 0,
        title: Text(
          _titles[_selectedIndex],
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            _scaffoldKey.currentState!.openDrawer();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics, color: Colors.white),
            onPressed: () {
              _showAnalytics();
            },
          ),
          const SizedBox(width: 10),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: () {
                context.read<LoginBloc>().add(LogoutRequested());
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                );
              }
          ),
          const SizedBox(width: 10),
        ],
      ),
      drawer: _buildLeftDrawer(),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1E3A8A),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.local_parking),
            label: 'Places',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_seat),
            label: 'Réservations',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Utilisateurs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Ajouter',
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildParkingSpotsScreen();
      case 1:
        return _buildReservationsScreen();
      case 2:
        return _buildUsersScreen();
      case 3:
        return _buildAddUserScreen();
      default:
        return const Center(child: Text('Écran non trouvé'));
    }
  }

  Widget _buildParkingSpotsScreen() {
    return Container(
      color: Colors.grey[100],
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatCard(title: 'Total Places', value: '60', color: Color(0xFF1E3A8A)),
                _StatCard(title: 'Disponibles', value: '42', color: Colors.green),
                _StatCard(title: 'Occupées', value: '18', color: Colors.orange),
              ],
            ),
          ),
          // Liste des places
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 10,
              itemBuilder: (context, index) {
                final spots = ['A01', 'A02', 'A03', 'B01', 'B02', 'C01', 'C02', 'D01', 'D02', 'E01'];
                final isOccupied = index % 3 == 0;
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Icon(
                      Icons.local_parking,
                      color: isOccupied ? Colors.red : Colors.green,
                    ),
                    title: Text('Place ${spots[index]}'),
                    subtitle: Text(
                      isOccupied ? 'Occupée - John Doe' : 'Disponible',
                      style: TextStyle(
                        color: isOccupied ? Colors.red : Colors.green,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.qr_code),
                      onPressed: () => _showQRCode(spots[index]),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReservationsScreen() {
    return Container(
      color: Colors.grey[100],
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 8, // Walking Skeleton: 8 réservations d'exemple
        itemBuilder: (context, index) {
          final reservations = [
            {'user': 'Alice Martin', 'spot': 'A01', 'time': '09:00 - 17:00'},
            {'user': 'Bob Dupont', 'spot': 'B03', 'time': '08:30 - 16:30'},
            {'user': 'Claire Leroy', 'spot': 'C02', 'time': '10:00 - 18:00'},
            {'user': 'David Chen', 'spot': 'A05', 'time': '07:45 - 15:45'},
            {'user': 'Emma Wilson', 'spot': 'D01', 'time': '09:15 - 17:15'},
            {'user': 'Frank Miller', 'spot': 'B07', 'time': '08:00 - 16:00'},
            {'user': 'Grace Kim', 'spot': 'E03', 'time': '10:30 - 18:30'},
            {'user': 'Henry Brown', 'spot': 'C06', 'time': '09:30 - 17:30'},
          ];
          
          final reservation = reservations[index];
          
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFF1E3A8A),
                child: Icon(Icons.person, color: Colors.white),
              ),
              title: Text(reservation['user']!),
              subtitle: Text('Place ${reservation['spot']} • ${reservation['time']}'),
              trailing: PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('Modifier')),
                  const PopupMenuItem(value: 'cancel', child: Text('Annuler')),
                ],
                onSelected: (value) => _handleReservationAction(value, reservation['user']!),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAddUserScreen() {
    return BlocProvider(
      create: (_) => RegisterBloc(authRepository: RepositoryProvider.of<AuthRepository>(context),),
      child: const AddUserScreen(),
    );
  }

  Widget _buildUsersScreen() {
    return Container(
      color: Colors.grey[100],
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 12, // Walking Skeleton: 12 utilisateurs d'exemple
        itemBuilder: (context, index) {
          final users = [
            {'name': 'Alice Martin', 'role': 'EMPLOYEE', 'email': 'alice@company.com'},
            {'name': 'Bob Dupont', 'role': 'MANAGER', 'email': 'bob@company.com'},
            {'name': 'Claire Leroy', 'role': 'SECRETARY', 'email': 'claire@company.com'},
            {'name': 'David Chen', 'role': 'EMPLOYEE', 'email': 'david@company.com'},
            {'name': 'Emma Wilson', 'role': 'EMPLOYEE', 'email': 'emma@company.com'},
            {'name': 'Frank Miller', 'role': 'MANAGER', 'email': 'frank@company.com'},
            {'name': 'Grace Kim', 'role': 'EMPLOYEE', 'email': 'grace@company.com'},
            {'name': 'Henry Brown', 'role': 'EMPLOYEE', 'email': 'henry@company.com'},
            {'name': 'Isabelle Durand', 'role': 'SECRETARY', 'email': 'isabelle@company.com'},
            {'name': 'Jack Thompson', 'role': 'EMPLOYEE', 'email': 'jack@company.com'},
            {'name': 'Karen Lee', 'role': 'MANAGER', 'email': 'karen@company.com'},
            {'name': 'Louis Garcia', 'role': 'EMPLOYEE', 'email': 'louis@company.com'},
          ];
          
          final user = users[index];
          final roleColor = _getRoleColor(user['role']!);
          
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: roleColor,
                child: Text(
                  user['name']!.substring(0, 2).toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(user['name']!),
              subtitle: Text(user['email']!),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: roleColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: roleColor.withOpacity(0.3)),
                ),
                child: Text(
                  user['role']!,
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
    );
  }

  Widget _buildLeftDrawer() {
    return Drawer(
      width: 300,
      child: Container(
        color: const Color(0xFF1E3A8A),
        child: Column(
          children: [
            const SizedBox(height: 60),
            Row(
              children: [
                const SizedBox(width: 20),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.local_parking, color: Color(0xFF1E3A8A)),
                ),
                const SizedBox(width: 15),
                const Text(
                  'ParkingAdmin',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 10),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Rechercher...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                  prefixIcon: const Icon(Icons.search, color: Colors.white),
                  border: InputBorder.none,
                ),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 25),
            const Padding(
              padding: EdgeInsets.only(left: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'GESTION PARKING',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            _buildMenuItem(Icons.local_parking, 'Places de Parking', 0, badge: 60),
            _buildMenuItem(Icons.event_seat, 'Réservations', 1, badge: 18),
            _buildMenuItem(Icons.people, 'Utilisateurs', 2, badge: 12),
            _buildMenuItem(Icons.person_add, 'Ajouter un utilisateur', 3),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: const Text('AD', style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(width: 15),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Admin Parking',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'admin@parking.com',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const Icon(Icons.more_vert, color: Colors.white),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, int index, {int? badge}) {
    bool isSelected = _selectedIndex == index;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
          border: isSelected
              ? const Border(
                  left: BorderSide(color: Colors.white, width: 3),
                )
              : null,
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 15),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            const Spacer(),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$badge',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'MANAGER':
        return Colors.purple;
      case 'SECRETARY':
        return Colors.orange;
      case 'EMPLOYEE':
      default:
        return const Color(0xFF1E3A8A);
    }
  }

  void _showQRCode(String spotId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('QR Code - Place $spotId'),
        content: Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Icon(Icons.qr_code, size: 100, color: Colors.grey),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showAnalytics() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Analytics à venir...')),
    );
  }

  void _handleReservationAction(String action, String userName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$action pour $userName')),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}