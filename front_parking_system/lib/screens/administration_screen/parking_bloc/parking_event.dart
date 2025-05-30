part of 'parking_bloc.dart';

@immutable
sealed class ParkingEvent {}

class LoadParkingSpots extends ParkingEvent {}