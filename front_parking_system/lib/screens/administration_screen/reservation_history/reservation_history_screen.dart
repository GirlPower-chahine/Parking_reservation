import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:parking_system/screens/administration_screen/reservation_history/reservation_history_bloc/reservation_history_bloc.dart';


import '../../../shared/core/models/reservation/reservation_history_dto.dart';
import '../../../shared/core/services/api/api_service.dart';
import '../../../shared/core/services/repository/reservation_history_repository.dart';



class ReservationHistoryScreen extends StatelessWidget {
  const ReservationHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ReservationHistoryBloc(
        repository: ReservationHistoryRepository(ApiService()),
      )..add(LoadYearlyReservations()),
      child: const ReservationHistoryView(),
    );
  }
}

class ReservationHistoryView extends StatefulWidget {
  const ReservationHistoryView({super.key});

  @override
  State<ReservationHistoryView> createState() => _ReservationHistoryViewState();
}

class _ReservationHistoryViewState extends State<ReservationHistoryView> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'ALL';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildFilters(),
            _buildStatistics(),
            Expanded(child: _buildReservationsList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.history, color: Color(0xFF1E3A8A), size: 28),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Historique des Réservations',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: Color(0xFF1E3A8A)),
                onPressed: () {
                  context.read<ReservationHistoryBloc>().add(LoadYearlyReservations());
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Rechercher...',
              prefixIcon: const Icon(Icons.search, size: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              isDense: true,
            ),
            onChanged: (value) {
              context.read<ReservationHistoryBloc>().add(
                SearchReservations(searchTerm: value),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterChip('ALL', 'Toutes', Icons.list),
          _buildFilterChip('ACTIVE', 'Actives', Icons.check_circle),
          _buildFilterChip('COMPLETED', 'Terminées', Icons.done_all),
          _buildFilterChip('CHECKED_IN', 'Arrivées', Icons.login),
          _buildFilterChip('CANCELLED_BY_USER', 'Annulées', Icons.cancel),
          _buildFilterChip('EXPIRED', 'Expirées', Icons.schedule),
          const SizedBox(width: 8),
          _buildDateRangeButton(),
          _buildQuickFilters(),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label, IconData icon) {
    final isSelected = _selectedFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
        onSelected: (selected) {
          setState(() {
            _selectedFilter = value;
          });

          if (value == 'ALL') {
            context.read<ReservationHistoryBloc>().add(ResetFilters());
          } else {
            context.read<ReservationHistoryBloc>().add(
              FilterReservationsByStatus(status: value),
            );
          }
        },
        selectedColor: const Color(0xFF1E3A8A).withOpacity(0.2),
        checkmarkColor: const Color(0xFF1E3A8A),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  Widget _buildDateRangeButton() {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        avatar: const Icon(Icons.date_range, size: 14),
        label: const Text('Période', style: TextStyle(fontSize: 12)),
        onPressed: () => _showDateRangePicker(),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  Widget _buildQuickFilters() {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.filter_list, size: 20),
      onSelected: (value) {
        switch (value) {
          case 'active':
            context.read<ReservationHistoryBloc>().add(LoadActiveReservations());
            break;
          case 'completed':
            context.read<ReservationHistoryBloc>().add(LoadCompletedReservations());
            break;
          case 'cancelled':
            context.read<ReservationHistoryBloc>().add(LoadCancelledReservations());
            break;
          case 'year':
            context.read<ReservationHistoryBloc>().add(LoadYearlyReservations());
            break;
        }
      },
      padding: EdgeInsets.zero,
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'active', child: Text('Réservations actives')),
        const PopupMenuItem(value: 'completed', child: Text('Réservations terminées')),
        const PopupMenuItem(value: 'cancelled', child: Text('Réservations annulées')),
        const PopupMenuItem(value: 'year', child: Text('Toute l\'année')),
      ],
    );
  }

  Widget _buildStatistics() {
    return BlocBuilder<ReservationHistoryBloc, ReservationHistoryState>(
      builder: (context, state) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
              ),
            ],
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                _buildStatCard('Total', state.totalReservations, Icons.receipt, Colors.blue),
                _buildVerticalDivider(),
                _buildStatCard('Actives', state.activeReservations, Icons.check_circle, Colors.green),
                _buildVerticalDivider(),
                _buildStatCard('Terminées', state.completedReservations, Icons.done_all, Colors.orange),
                _buildVerticalDivider(),
                _buildStatCard('Annulées', state.cancelledReservations, Icons.cancel, Colors.red),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: Colors.grey[300],
    );
  }

  Widget _buildStatCard(String title, int count, IconData icon, Color color) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReservationsList() {
    return BlocBuilder<ReservationHistoryBloc, ReservationHistoryState>(
      builder: (context, state) {
        if (state.status == ReservationHistoryStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.status == ReservationHistoryStatus.error) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Erreur: ${state.error}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ReservationHistoryBloc>().add(LoadYearlyReservations());
                    },
                    child: const Text('Réessayer'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => _testReservationHistoryEndpoint(),
                    child: const Text('Test API'),
                  ),
                ],
              ),
            ),
          );
        }

        if (state.filteredReservations.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.inbox, size: 48, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Aucune réservation trouvée',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: state.filteredReservations.length,
          itemBuilder: (context, index) {
            final reservation = state.filteredReservations[index];
            return _buildReservationCard(reservation);
          },
        );
      },
    );
  }

  Widget _buildReservationCard(ReservationHistoryDTO reservation) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: _getStatusColor(reservation.status),
                  child: Icon(
                    _getStatusIcon(reservation.status),
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reservation.userName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Place ${reservation.spotId}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(reservation.status),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text(
                        _formatDate(reservation.reservationDate),
                        style: const TextStyle(fontSize: 12),
                      ),
                      const Spacer(),
                      const Icon(Icons.access_time, size: 14, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text(
                        _formatTimeSlot(reservation.timeSlot),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  if (reservation.checkInTime != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.login, size: 14, color: Colors.green),
                        const SizedBox(width: 6),
                        Text(
                          'Arrivée: ${_formatDateTime(reservation.checkInTime!)}',
                          style: const TextStyle(fontSize: 10, color: Colors.green),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'Créée le ${_formatDateTime(reservation.createdAt)}',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
                const Spacer(),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 16),
                  onSelected: (value) => _handleReservationAction(value, reservation),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'details',
                      child: Row(
                        children: [
                          Icon(Icons.info, size: 16),
                          SizedBox(width: 8),
                          Text('Détails'),
                        ],
                      ),
                    ),
                    if (reservation.status.toUpperCase() == 'ACTIVE') ...[
                      const PopupMenuItem(
                        value: 'cancel',
                        child: Row(
                          children: [
                            Icon(Icons.cancel, size: 16, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Annuler', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    final color = _getStatusColor(status);
    final text = _getStatusText(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // Méthodes utilitaires avec support des vrais statuts
  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return Colors.green;
      case 'COMPLETED':
        return Colors.blue;
      case 'CHECKED_IN':
        return Colors.orange;
      case 'CANCELLED':
      case 'CANCELLED_BY_USER':
        return Colors.red;
      case 'EXPIRED':
        return Colors.grey;
      case 'CANCELLED_AUTO':
        return Colors.red.shade300;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return Icons.check_circle;
      case 'COMPLETED':
        return Icons.done_all;
      case 'CHECKED_IN':
        return Icons.login;
      case 'CANCELLED':
      case 'CANCELLED_BY_USER':
        return Icons.cancel;
      case 'EXPIRED':
        return Icons.schedule;
      case 'CANCELLED_AUTO':
        return Icons.auto_delete;
      default:
        return Icons.help;
    }
  }

  String _getStatusText(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return 'Active';
      case 'COMPLETED':
        return 'Terminée';
      case 'CHECKED_IN':
        return 'Arrivée';
      case 'CANCELLED':
        return 'Annulée';
      case 'CANCELLED_BY_USER':
        return 'Annulée par utilisateur';
      case 'EXPIRED':
        return 'Expirée';
      case 'CANCELLED_AUTO':
        return 'Annulation automatique';
      default:
        return status;
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  String _formatDateTime(String dateTimeStr) {
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      return DateFormat('dd/MM HH:mm').format(dateTime);
    } catch (e) {
      return dateTimeStr;
    }
  }

  String _formatTimeSlot(String timeSlot) {
    switch (timeSlot.toUpperCase()) {
      case 'MORNING':
        return 'Matin';
      case 'AFTERNOON':
        return 'A-midi';
      case 'EVENING':
        return 'Soir';
      case 'FULL_DAY':
        return 'Journée';
      default:
        return timeSlot;
    }
  }

  void _showDateRangePicker() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: DateTimeRange(
        start: DateTime.now().subtract(const Duration(days: 30)),
        end: DateTime.now(),
      ),
    );

    if (picked != null) {
      context.read<ReservationHistoryBloc>().add(
        FilterReservationsByDate(
          startDate: picked.start,
          endDate: picked.end,
        ),
      );
    }
  }

  void _handleReservationAction(String action, ReservationHistoryDTO reservation) {
    switch (action) {
      case 'details':
        _showReservationDetails(reservation);
        break;
      case 'cancel':
        _showCancelConfirmation(reservation);
        break;
    }
  }

  void _showReservationDetails(ReservationHistoryDTO reservation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Détails de la réservation'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('ID', reservation.reservationId),
              _buildDetailRow('Utilisateur', reservation.userName),
              _buildDetailRow('Place', reservation.spotId),
              _buildDetailRow('Date', _formatDate(reservation.reservationDate)),
              _buildDetailRow('Créneau', _formatTimeSlot(reservation.timeSlot)),
              _buildDetailRow('Statut', _getStatusText(reservation.status)),
              _buildDetailRow('Groupe', reservation.groupId),
              _buildDetailRow('Créée le', _formatDateTime(reservation.createdAt)),
              if (reservation.checkInTime != null)
                _buildDetailRow('Arrivée', _formatDateTime(reservation.checkInTime!)),
            ],
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _showCancelConfirmation(ReservationHistoryDTO reservation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Annuler la réservation'),
        content: Text(
          'Êtes-vous sûr de vouloir annuler la réservation de ${reservation.userName} pour la place ${reservation.spotId} ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Non'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fonctionnalité d\'annulation à implémenter')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Oui, annuler'),
          ),
        ],
      ),
    );
  }

  // Fonction de test pour débugger l'API
  void _testReservationHistoryEndpoint() async {
    try {
      print('🧪 Test de l\'endpoint historique...');

      final repository = ReservationHistoryRepository(ApiService());
      final reservations = await repository.getYearlyReservations();

      print('✅ Test réussi: ${reservations.length} réservations trouvées');

      if (reservations.isNotEmpty) {
        print('📋 Première réservation:');
        print('   - ID: ${reservations.first.reservationId}');
        print('   - User: ${reservations.first.userName}');
        print('   - Status: ${reservations.first.status}');
        print('   - Spot: ${reservations.first.spotId}');
      }

      // Test des statuts uniques
      final uniqueStatuses = reservations.map((r) => r.status).toSet();
      print('📊 Statuts trouvés: $uniqueStatuses');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Test API réussi: ${reservations.length} réservations'),
            backgroundColor: Colors.green,
          ),
        );
      }

    } catch (e) {
      print('❌ Erreur test: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur API: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
