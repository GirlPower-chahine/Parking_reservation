import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../administration_screen/dashboard/dashboard_screen.dart';
import '../login_screen/login_bloc/login_bloc.dart';
import '../login_screen/login_screen.dart';
import 'reservations_list/reservation_list_widget.dart';
import '../../shared/core/services/api/api_service.dart';
import '../../shared/core/services/repository/parking_repository.dart';
import 'my_reservations/reservation_screen.dart';

class EmployeePanel extends StatefulWidget {
  final bool isManager;

  const EmployeePanel({
    super.key,
    this.isManager = false,
  });

  @override
  State<EmployeePanel> createState() => _EmployeePanelState();
}

class _EmployeePanelState extends State<EmployeePanel> {
  int _selectedIndex = 0;
  late List<String> _titles;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // Set titles based on whether user is manager or not
    _titles = widget.isManager
        ? ['Places de Parking', 'Réservations', 'Tableau de Bord']
        : ['Places de Parking', 'Réservations'];
  }

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => ParkingRepository(ApiService()),
      child: Scaffold(
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
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: () {
                context.read<LoginBloc>().add(LogoutRequested());
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                );
              },
              tooltip: 'Déconnexion',
            ),
            const SizedBox(width: 10),
          ],
        ),
        drawer: _buildLeftDrawer(),
        body: _buildBody(),
        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    List<BottomNavigationBarItem> items = [
      const BottomNavigationBarItem(
        icon: Icon(Icons.local_parking),
        label: 'Places',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.event_seat),
        label: 'Réservations',
      ),
    ];

    // Add dashboard tab only for managers
    if (widget.isManager) {
      items.add(
        const BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
      );
    }

    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF1E3A8A),
      unselectedItemColor: Colors.grey,
      items: items,
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildParkingSpotsScreen();
      case 1:
        return _buildReservationsScreen();
      case 2:
      // Dashboard tab (only available for managers)
        if (widget.isManager) {
          return _buildDashboardScreen();
        }
        return const Center(child: Text('Écran non trouvé'));
      default:
        return const Center(child: Text('Écran non trouvé'));
    }
  }

  Widget _buildParkingSpotsScreen() {
    return const ReservationListWidget();
  }

  Widget _buildReservationsScreen() {
    return const ReservationScreen();
  }

  Widget _buildDashboardScreen() {
    return const DashboardScreen();
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
                  'ParkingApp',
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

            // Add dashboard menu item for managers
            if (widget.isManager)
              _buildMenuItem(Icons.dashboard, 'Tableau de Bord', 2),

            // Additional analytics menu items for managers
            if (widget.isManager) ...[
              const SizedBox(height: 15),
              const Padding(
                padding: EdgeInsets.only(left: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'ANALYTICS AVANCÉS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              _buildAnalyticsMenuItem(
                Icons.bar_chart,
                'Statistiques',
                onTap: () => _showComingSoon('Statistiques détaillées'),
              ),
            ],

            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: Text(
                      widget.isManager ? 'MG' : 'EM',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.isManager ? 'Manager Parking' : 'Employee Parking',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.isManager ? 'manager@parking.com' : 'employee@parking.com',
                        style: const TextStyle(color: Colors.white70),
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

  Widget _buildAnalyticsMenuItem(IconData icon, String title, {required VoidCallback onTap}) {
    return InkWell(
      onTap: () {
        Navigator.pop(context); // Ferme le drawer
        onTap(); // Exécute l'action
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 15),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(String feature) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.info, color: Color(0xFF1E3A8A)),
              SizedBox(width: 10),
              Text('Fonctionnalité à venir'),
            ],
          ),
          content: Text('$feature sera disponible dans une prochaine version.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'OK',
                style: TextStyle(color: Color(0xFF1E3A8A)),
              ),
            ),
          ],
        );
      },
    );
  }
}