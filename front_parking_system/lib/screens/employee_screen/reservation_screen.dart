import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parking_system/screens/employee_screen/reservation_bloc/reservation_bloc.dart';
import 'package:parking_system/screens/employee_screen/reservation_list_bloc/reservation_list_bloc.dart';
import '../../shared/core/models/reservation/reservation_dto.dart';
import '../../shared/core/services/repository/parking_repository.dart';

class ReservationScreen extends StatelessWidget {
  const ReservationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ReservationListBloc(
            repository: RepositoryProvider.of<ParkingRepository>(context),
          )..add(LoadReservations()),
        ),
        BlocProvider(
          create: (context) => ReservationBloc(
            repository: RepositoryProvider.of<ParkingRepository>(context),
          ),
        ),
      ],
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: Container(
              color: Colors.white,
              child: const TabBar(
                tabs: [
                  Tab(text: 'Actives'),
                  Tab(text: 'Historique'),
                ],
                labelColor: Color(0xFF1E3A8A),
                unselectedLabelColor: Colors.grey,
                indicatorColor: Color(0xFF1E3A8A),
              ),
            ),
          ),
          body: BlocConsumer<ReservationBloc, ReservationState>(
            listener: (context, reservationState) {
              if (reservationState.status == ReservationStatus.success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Réservation annulée avec succès')),
                );
                context.read<ReservationListBloc>().add(LoadReservations());
              } else if (reservationState.status == ReservationStatus.error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erreur: ${reservationState.error}')),
                );
              }
            },
            builder: (context, reservationState) {
              return const TabBarView(
                children: [
                  _ReservationList(status: 'ACTIVE'),
                  _ReservationList(status: 'OTHER'),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ReservationList extends StatelessWidget {
  final String status;

  const _ReservationList({required this.status});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReservationListBloc, ReservationListState>(
      builder: (context, state) {
        if (state.status == ReservationListStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.status == ReservationListStatus.error) {
          return Center(
            child: Text('Erreur: ${state.error}'),
          );
        }

        final filteredReservations = state.reservations.where((reservation) =>
        status == 'ACTIVE' ? reservation.status == 'ACTIVE' : reservation.status != 'ACTIVE'
        ).toList();

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredReservations.length,
          itemBuilder: (context, index) {
            final reservation = filteredReservations[index];
            return _buildReservationCard(context, reservation);
          },
        );
      },
    );
  }

  Widget _buildReservationCard(BuildContext context, ReservationDTO reservation) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text('Place ${reservation.spotId}'),
        subtitle: Text(
          'Date: ${reservation.reservationDate}\n'
              'Créneau: ${reservation.timeSlot}',
        ),
        trailing: status == 'ACTIVE' ?
        IconButton(
          icon: const Icon(Icons.cancel, color: Colors.red),
          onPressed: () => _showCancelConfirmation(context, reservation.reservationId),
        ) : null,
      ),
    );
  }

  void _showCancelConfirmation(BuildContext context, String reservationId) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmer l\'annulation'),
          content: const Text('Voulez-vous vraiment annuler cette réservation ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Non'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                context.read<ReservationBloc>().add(CancelReservation(reservationId));
                Navigator.pop(dialogContext);
              },
              child: const Text('Oui, annuler'),
            ),
          ],
        );
      },
    );
  }
}
