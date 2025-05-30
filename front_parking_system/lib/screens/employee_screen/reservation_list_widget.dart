import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parking_system/screens/employee_screen/reservation_bloc/reservation_bloc.dart';
import '../../shared/core/services/api/api_service.dart';
import '../../shared/core/services/repository/parking_repository.dart';
import '../../shared/core/services/storage/local_storage.dart';
import '../administration_screen/parking_bloc/parking_bloc.dart';

class ReservationListWidget extends StatelessWidget {
  const ReservationListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(
          create: (context) => ParkingRepository(ApiService()),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => ParkingBloc(
              repository: context.read<ParkingRepository>(),
            )..add(LoadParkingSpots()),
          ),
        ],
        child: const ReservationListView(),
      ),
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
                    _StatCard(title: 'Total Places', value: totalPlaces.toString(), color: const Color(0xFF1E3A8A)),
                    _StatCard(title: 'Disponibles', value: availablePlaces.toString(), color: Colors.green),
                    _StatCard(title: 'Occupées', value: occupiedPlaces.toString(), color: Colors.orange),
                  ],
                ),
              ),
              Expanded(
                child: switch (state.status) {
                  ParkingStatus.initial => const SizedBox.shrink(),
                  ParkingStatus.loading => const Center(child: CircularProgressIndicator()),
                  ParkingStatus.error => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Erreur : ${state.error}', style: const TextStyle(color: Colors.red)),
                        ElevatedButton(
                          onPressed: () => context.read<ParkingBloc>().add(LoadParkingSpots()),
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
                      return GestureDetector(
                        onTap: () => _showReservationPopup(spot.spotId, context),
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: Icon(
                              Icons.local_parking,
                              color: spot.isAvailable ? Colors.green : Colors.red,
                            ),
                            title: Text('Place ${spot.spotId}'),
                            subtitle: Text(
                              'Rangée: ${spot.rowIdentifier} - N°${spot.spotNumber}\n'
                                  'Disponible: ${spot.isAvailable ? "Oui" : "Non"}'
                                  '${spot.hasElectricCharger ? " • Borne de recharge" : ""}',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (spot.hasElectricCharger)
                                  const Padding(
                                    padding: EdgeInsets.only(right: 8.0),
                                    child: Icon(Icons.electric_car, color: Colors.blue, size: 24),
                                  ),
                                IconButton(
                                  icon: const Icon(Icons.qr_code),
                                  onPressed: () => _showQRCode(spot.spotId, context),
                                ),
                              ],
                            ),
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


  void _showReservationPopup(String spotId, BuildContext context) async {
    DateTime selectedDate = DateTime.now();
    String selectedTimeSlot = 'MORNING';
    // Récupérer la place de parking sélectionnée
    final spot = context.read<ParkingBloc>().state.parkingSpots
        .firstWhere((spot) => spot.spotId == spotId);
    // La valeur needsCharge sera égale à hasElectricCharger de la place
    final needsCharge = spot.hasElectricCharger;

    final currentUser = await LocalStorage.getUser();
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur: Impossible de récupérer l\'utilisateur')),
      );
      return;
    }

    final parkingRepository = RepositoryProvider.of<ParkingRepository>(context);

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return BlocProvider(
          create: (_) => ReservationBloc(repository: parkingRepository),
          child: BlocConsumer<ReservationBloc, ReservationState>(
            listener: (context, state) {
              if (state.status == ReservationStatus.success) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Réservation effectuée avec succès\nCode de confirmation : ${state.confirmationCode}'),
                    duration: const Duration(seconds: 5),
                  ),
                );
              } else if (state.status == ReservationStatus.error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erreur: ${state.error}')),
                );
              }
            },
            builder: (context, state) {
              return StatefulBuilder(
                builder: (context, setState) {
                  return AlertDialog(
                    title: Text('Réserver la place $spotId'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('ID de la place : $spotId'),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.calendar_today),
                          label: const Text('Choisir une date'),
                          onPressed: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            if (picked != null) {
                              setState(() {
                                selectedDate = picked;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 10),
                        DropdownButton<String>(
                          value: selectedTimeSlot,
                          items: const [
                            DropdownMenuItem(value: 'MORNING', child: Text('Matin')),
                            DropdownMenuItem(value: 'AFTERNOON', child: Text('Après-midi')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              selectedTimeSlot = value!;
                            });
                          },
                        ),
                        if (spot.hasElectricCharger)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              'Cette place est équipée d\'une borne de recharge',
                              style: TextStyle(
                                color: Colors.blue,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Annuler'),
                      ),
                      ElevatedButton(
                        onPressed: state.status == ReservationStatus.loading
                            ? null
                            : () {
                          context.read<ReservationBloc>().add(
                            CreateReservation(
                              userId: currentUser.id,
                              date: selectedDate.toIso8601String().split('T')[0],
                              timeSlot: selectedTimeSlot,
                              spotId: spotId,
                              needsElectricCharge: needsCharge,
                            ),
                          );
                        },
                        child: state.status == ReservationStatus.loading
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                            : const Text('Valider'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        );
      },
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