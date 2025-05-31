import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:parking_system/screens/administration_screen/reservation_history_bloc/reservation_history_bloc.dart';

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
          _buildFilterChip('CANCELLED_BY_USER', 'Annulées', Icons.cancel),
          _buildFilterChip('CHECKED_IN', 'Arrivées', Icons.login),
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
          case 'today':
            context.read<ReservationHistoryBloc>().add(LoadCompletedReservationsToday());
            break;
          case 'week':
            context.read<ReservationHistoryBloc>().add(LoadCancelledReservationsThisWeek());
            break;
          case 'month':
            context.read<ReservationHistoryBloc>().add(LoadLastMonthHistory());
            break;
          case 'year':
            context.read<ReservationHistoryBloc>().add(LoadYearlyReservations());
            break;
        }
      },
      padding: EdgeInsets.zero,
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'today', child: Text('Complétées aujourd\'hui')),
        const PopupMenuItem(value: 'week', child: Text('Annulées cette semaine')),
        const PopupMenuItem(value: 'month', child: Text('Mois dernier')),
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

  // ... (garder le reste des méthodes _buildReservationCard, etc. mais avec des tailles optimisées)

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

  // Méthodes utilitaires (garder les mêmes)
  Color _getStatusColor(String status) {
    switch (status) {
      case 'ACTIVE': return Colors.green;
      case 'COMPLETED': return Colors.blue;
      case 'CANCELLED_BY_USER': return Colors.red;
      case 'CHECKED_IN': return Colors.orange;
      default: return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'ACTIVE': return Icons.check_circle;
      case 'COMPLETED': return Icons.done_all;
      case 'CANCELLED_BY_USER': return Icons.cancel;
      case 'CHECKED_IN': return Icons.login;
      default: return Icons.help;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'ACTIVE': return 'Active';
      case 'COMPLETED': return 'Terminée';
      case 'CANCELLED_BY_USER': return 'Annulée';
      case 'CHECKED_IN': return 'Arrivée';
      default: return 'Inconnu';
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
    switch (timeSlot) {
      case 'MORNING': return 'Matin';
      case 'AFTERNOON': return 'A-midi';
      case 'EVENING': return 'Soir';
      case 'FULL_DAY': return 'Journée';
      default: return timeSlot;
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
}