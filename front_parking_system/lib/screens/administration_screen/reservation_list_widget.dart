import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../shared/core/services/repository/parking_repository.dart';
import 'parking_bloc/parking_bloc.dart';

class ReservationListWidget extends StatelessWidget {
  const ReservationListWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ParkingBloc(
        repository: context.read<ParkingRepository>(),
      )..add(LoadParkingSpots()),
      child: const ReservationListView(),
    );
  }
}

class ReservationListView extends StatelessWidget {
  const ReservationListView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ParkingBloc, ParkingState>(
      builder: (context, state) {
        int totalPlaces = state.parkingSpots.length;
        int availablePlaces =
            state.parkingSpots.where((spot) => spot.isAvailable).length;
        int occupiedPlaces = totalPlaces - availablePlaces;

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
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.grey,
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatCard(
                        title: 'Total Places',
                        value: totalPlaces.toString(),
                        color: const Color(0xFF1E3A8A)),
                    _StatCard(
                        title: 'Disponibles',
                        value: availablePlaces.toString(),
                        color: Colors.green),
                    _StatCard(
                        title: 'Occupées',
                        value: occupiedPlaces.toString(),
                        color: Colors.orange),
                  ],
                ),
              ),
              Expanded(
                child: switch (state.status) {
                  ParkingStatus.initial => const SizedBox.shrink(),
                  ParkingStatus.loading => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  ParkingStatus.error => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Erreur : ${state.error}',
                          style: const TextStyle(color: Colors.red),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            context.read<ParkingBloc>().add(LoadParkingSpots());
                          },
                          child: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  ),
                  ParkingStatus.success => ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: state.parkingSpots.length,
                    itemBuilder: (context, index) {
                      final spot = state.parkingSpots[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: Icon(
                            Icons.local_parking,
                            color: spot.isAvailable ? Colors.green : Colors.red,
                          ),
                          title: Text('Place ${spot.spotId}'),
                          subtitle: Text(
                            'Rangée: ${spot.rowIdentifier} - N°${spot.spotNumber}\n'
                                'Disponible: ${spot.isAvailable ? "Oui" : "Non"}',
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.qr_code),
                            onPressed: () => _showQRCode(spot.spotId, context),
                          ),
                        ),
                      );
                    },
                  ),
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showQRCode(String spotId, BuildContext context) {
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